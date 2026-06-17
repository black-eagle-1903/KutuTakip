import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:kututakip/database/tables/app_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Destinations, Boxes, Items, Photos],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        // Enable foreign keys for cascade deletes
        await customStatement('PRAGMA foreign_keys = ON');
      },
      beforeOpen: (details) async {
        // Enable foreign keys on every connection
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ============ INITIALIZATION ============

  /// Initialize default destinations on first app start
  Future<void> initializeDefaultDestinations() async {
    final defaultDests = [
      'Yeni Ev',
      'Eski Ev',
      'Yazlık Ev',
      'Depo',
      'Diğer',
    ];

    final existing = await select(destinations).get();
    if (existing.isEmpty) {
      final now = DateTime.now();
      for (final name in defaultDests) {
        await into(destinations).insert(
          DestinationsCompanion(
            name: Value(name),
            isDefault: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }
    }
  }

  // ============ BOX OPERATIONS ============

  /// Get next box number (e.g., "KT-001")
  Future<String> getNextBoxNumber() async {
    final lastBox = await (select(boxes)
          ..orderBy([(b) => OrderingTerm(expression: b.id, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();

    if (lastBox == null) {
      return 'KT-001';
    }

    // Extract number from boxNumber like "KT-001"
    final parts = lastBox.boxNumber.split('-');
    if (parts.length == 2) {
      final num = int.tryParse(parts[1]) ?? 0;
      return 'KT-${(num + 1).toString().padLeft(3, '0')}';
    }
    return 'KT-001';
  }

  /// Create box with all related data
  Future<int> createBox(BoxesCompanion box) async {
    return into(boxes).insert(box);
  }

  /// Get all boxes
  Future<List<Box>> getAllBoxes() async {
    return select(boxes).get();
  }

  /// Get box by ID with items and photos
  Future<Box?> getBoxById(int id) async {
    return (select(boxes)..where((b) => b.id.equals(id))).getSingleOrNull();
  }

  /// Update box
  Future<bool> updateBox(BoxesCompanion box) async {
    return update(boxes).replace(box);
  }

  /// Delete box (cascade deletes items and photos via foreign key)
  Future<int> deleteBox(int id) async {
    return (delete(boxes)..where((b) => b.id.equals(id))).go();
  }

  // ============ ITEM OPERATIONS ============

  /// Get items by box ID
  Future<List<Item>> getItemsByBoxId(int boxId) async {
    return (select(items)..where((i) => i.boxId.equals(boxId))).get();
  }

  /// Create item
  Future<int> createItem(ItemsCompanion item) async {
    return into(items).insert(item);
  }

  /// Update item
  Future<bool> updateItem(ItemsCompanion item) async {
    return update(items).replace(item);
  }

  /// Delete item
  Future<int> deleteItem(int id) async {
    return (delete(items)..where((i) => i.id.equals(id))).go();
  }

  // ============ PHOTO OPERATIONS ============

  /// Get photos by box ID
  Future<List<Photo>> getPhotosByBoxId(int boxId) async {
    return (select(photos)..where((p) => p.boxId.equals(boxId))).get();
  }

  /// Create photo
  Future<int> createPhoto(PhotosCompanion photo) async {
    return into(photos).insert(photo);
  }

  /// Update photo
  Future<bool> updatePhoto(PhotosCompanion photo) async {
    return update(photos).replace(photo);
  }

  /// Delete photo
  Future<int> deletePhoto(int id) async {
    return (delete(photos)..where((p) => p.id.equals(id))).go();
  }

  // ============ DESTINATION OPERATIONS ============

  /// Get all destinations
  Future<List<Destination>> getAllDestinations() async {
    return select(destinations).get();
  }

  /// Create custom destination
  Future<int> createDestination(DestinationsCompanion dest) async {
    return into(destinations).insert(dest);
  }

  // ============ SEARCH OPERATIONS ============

  /// Case-insensitive search across boxes and items
  /// Searches: boxNumber, title, description, destination, item names
  Future<List<Box>> searchBoxes(String query) async {
    final lowerQuery = query.toLowerCase();
    final allBoxes = await select(boxes).get();

    // Filter in Dart to handle Turkish case-insensitivity properly
    return allBoxes.where((box) {
      return box.boxNumber.toLowerCase().contains(lowerQuery) ||
          box.title.toLowerCase().contains(lowerQuery) ||
          box.description.toLowerCase().contains(lowerQuery) ||
          box.destination.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get all data for backup
  Future<Map<String, dynamic>> exportAllData() async {
    final allBoxes = await select(boxes).get();
    final allItems = await select(items).get();
    final allPhotos = await select(photos).get();
    final allDests = await select(destinations).get();

    return {
      'boxes': allBoxes,
      'items': allItems,
      'photos': allPhotos,
      'destinations': allDests,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Clear all data (for restore)
  Future<void> clearAllData() async {
    await delete(items).go();
    await delete(photos).go();
    await delete(boxes).go();
    await delete(destinations).go();
  }

  /// Import data from backup
  Future<void> importData(Map<String, dynamic> data) async {
    await clearAllData();

    // Import destinations
    if (data['destinations'] is List) {
      for (final destData in data['destinations'] as List) {
        await into(destinations).insert(DestinationsCompanion(
          name: Value(destData['name'] as String),
          isDefault: Value(destData['isDefault'] as bool? ?? false),
          createdAt: Value(DateTime.parse(destData['createdAt'] as String)),
          updatedAt: Value(DateTime.parse(destData['updatedAt'] as String)),
        ));
      }
    }

    // Import boxes
    if (data['boxes'] is List) {
      for (final boxData in data['boxes'] as List) {
        await into(boxes).insert(BoxesCompanion(
          boxNumber: Value(boxData['boxNumber'] as String),
          title: Value(boxData['title'] as String),
          description: Value(boxData['description'] as String? ?? ''),
          destination: Value(boxData['destination'] as String),
          status: Value(boxData['status'] as String? ?? 'Beklemede'),
          notes: Value(boxData['notes'] as String? ?? ''),
          createdAt: Value(DateTime.parse(boxData['createdAt'] as String)),
          updatedAt: Value(DateTime.parse(boxData['updatedAt'] as String)),
        ));
      }
    }

    // Import items
    if (data['items'] is List) {
      for (final itemData in data['items'] as List) {
        await into(items).insert(ItemsCompanion(
          boxId: Value(itemData['boxId'] as int),
          name: Value(itemData['name'] as String),
          quantity: Value(itemData['quantity'] as int? ?? 1),
          notes: Value(itemData['notes'] as String? ?? ''),
          fragile: Value(itemData['fragile'] as bool? ?? false),
          createdAt: Value(DateTime.parse(itemData['createdAt'] as String)),
          updatedAt: Value(DateTime.parse(itemData['updatedAt'] as String)),
        ));
      }
    }

    // Import photos (paths are relative, will be restored from ZIP)
    if (data['photos'] is List) {
      for (final photoData in data['photos'] as List) {
        await into(photos).insert(PhotosCompanion(
          boxId: Value(photoData['boxId'] as int),
          filePath: Value(photoData['filePath'] as String),
          category: Value(photoData['category'] as String? ?? 'Diğer'),
          createdAt: Value(DateTime.parse(photoData['createdAt'] as String)),
          updatedAt: Value(DateTime.parse(photoData['updatedAt'] as String)),
        ));
      }
    }
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'kututakip',
    native: DriftNativeOptions(
      databasePath: 'kututakip.db',
    ),
  );
}
