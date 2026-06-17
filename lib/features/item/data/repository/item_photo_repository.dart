import 'package:kututakip/database/app_database.dart';
import 'package:kututakip/features/item/data/models/item.dart';
import 'package:kututakip/features/photo/data/models/photo.dart';

/// Repository for item operations
class ItemRepository {
  final AppDatabase _db;

  ItemRepository(this._db);

  /// Get all items in a box
  Future<List<Item>> getItemsByBoxId(int boxId) async {
    return _db.getItemsByBoxId(boxId);
  }

  /// Create a new item
  Future<int> createItem({
    required int boxId,
    required String name,
    required int quantity,
    required String notes,
    required bool fragile,
  }) async {
    final now = DateTime.now();

    return _db.createItem(
      ItemsCompanion(
        boxId: Value(boxId),
        name: Value(name),
        quantity: Value(quantity),
        notes: Value(notes),
        fragile: Value(fragile),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Update an existing item
  Future<bool> updateItem({
    required int id,
    required String name,
    required int quantity,
    required String notes,
    required bool fragile,
  }) async {
    final now = DateTime.now();

    return _db.updateItem(
      ItemsCompanion(
        id: Value(id),
        name: Value(name),
        quantity: Value(quantity),
        notes: Value(notes),
        fragile: Value(fragile),
        updatedAt: Value(now),
      ),
    );
  }

  /// Delete an item
  Future<int> deleteItem(int id) async {
    return _db.deleteItem(id);
  }

  /// Get count of items in a box
  Future<int> getItemCountByBoxId(int boxId) async {
    final items = await getItemsByBoxId(boxId);
    return items.length;
  }

  /// Get count of fragile items in a box
  Future<int> getFragileItemCountByBoxId(int boxId) async {
    final items = await getItemsByBoxId(boxId);
    return items.where((i) => i.fragile).length;
  }
}

/// Repository for photo operations
class PhotoRepository {
  final AppDatabase _db;

  PhotoRepository(this._db);

  /// Get all photos for a box
  Future<List<Photo>> getPhotosByBoxId(int boxId) async {
    return _db.getPhotosByBoxId(boxId);
  }

  /// Create a new photo
  Future<int> createPhoto({
    required int boxId,
    required String filePath,
    required String category,
  }) async {
    final now = DateTime.now();

    return _db.createPhoto(
      PhotosCompanion(
        boxId: Value(boxId),
        filePath: Value(filePath),
        category: Value(category),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Update a photo's metadata
  Future<bool> updatePhoto({
    required int id,
    required String category,
  }) async {
    final now = DateTime.now();

    return _db.updatePhoto(
      PhotosCompanion(
        id: Value(id),
        category: Value(category),
        updatedAt: Value(now),
      ),
    );
  }

  /// Delete a photo
  Future<int> deletePhoto(int id) async {
    return _db.deletePhoto(id);
  }

  /// Get count of photos in a box
  Future<int> getPhotoCountByBoxId(int boxId) async {
    final photos = await getPhotosByBoxId(boxId);
    return photos.length;
  }

  /// Get photos filtered by category
  Future<List<Photo>> getPhotosByBoxIdAndCategory(int boxId, String category) async {
    final photos = await getPhotosByBoxId(boxId);
    return photos.where((p) => p.category == category).toList();
  }
}
