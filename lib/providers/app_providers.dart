import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kututakip/database/app_database.dart';
import 'package:kututakip/features/box/data/models/box.dart';
import 'package:kututakip/features/box/data/repository/box_repository.dart';
import 'package:kututakip/features/item/data/models/item.dart';
import 'package:kututakip/features/item/data/repository/item_photo_repository.dart';
import 'package:kututakip/features/photo/data/models/photo.dart';
import 'package:kututakip/features/destination/data/models/destination.dart';

part 'app_providers.g.dart';

// ============ DATABASE PROVIDER ============

/// Provides the app database instance (singleton)
@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}

// ============ REPOSITORY PROVIDERS ============

/// Provides BoxRepository instance
@riverpod
BoxRepository boxRepository(BoxRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return BoxRepository(db);
}

/// Provides ItemRepository instance
@riverpod
ItemRepository itemRepository(ItemRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return ItemRepository(db);
}

/// Provides PhotoRepository instance
@riverpod
PhotoRepository photoRepository(PhotoRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return PhotoRepository(db);
}

// ============ BOX PROVIDERS ============

/// Get all boxes
@riverpod
Future<List<Box>> allBoxes(AllBoxesRef ref) async {
  final repo = ref.watch(boxRepositoryProvider);
  return repo.getAllBoxes();
}

/// Get a specific box by ID
@riverpod
Future<Box?> boxById(BoxByIdRef ref, int id) async {
  final repo = ref.watch(boxRepositoryProvider);
  return repo.getBoxById(id);
}

/// Search boxes with query string
@riverpod
Future<List<Box>> searchBoxes(SearchBoxesRef ref, String query) async {
  final repo = ref.watch(boxRepositoryProvider);
  return repo.searchBoxes(query);
}

/// Get next box number
@riverpod
Future<String> nextBoxNumber(NextBoxNumberRef ref) async {
  final repo = ref.watch(boxRepositoryProvider);
  return repo.getNextBoxNumber();
}

/// Get dashboard statistics
@riverpod
Future<Map<String, dynamic>> boxStatistics(BoxStatisticsRef ref) async {
  final repo = ref.watch(boxRepositoryProvider);
  return repo.getStatistics();
}

// ============ ITEM PROVIDERS ============

/// Get all items in a specific box
@riverpod
Future<List<Item>> itemsByBoxId(ItemsByBoxIdRef ref, int boxId) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getItemsByBoxId(boxId);
}

/// Get fragile item count for a box
@riverpod
Future<int> fragileItemCount(FragileItemCountRef ref, int boxId) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getFragileItemCountByBoxId(boxId);
}

// ============ PHOTO PROVIDERS ============

/// Get all photos for a specific box
@riverpod
Future<List<Photo>> photosByBoxId(PhotosByBoxIdRef ref, int boxId) async {
  final repo = ref.watch(photoRepositoryProvider);
  return repo.getPhotosByBoxId(boxId);
}

/// Get photos filtered by category
@riverpod
Future<List<Photo>> photosByBoxIdAndCategory(
  PhotosByBoxIdAndCategoryRef ref,
  int boxId,
  String category,
) async {
  final repo = ref.watch(photoRepositoryProvider);
  return repo.getPhotosByBoxIdAndCategory(boxId, category);
}

/// Get photo count for a box
@riverpod
Future<int> photoCount(PhotoCountRef ref, int boxId) async {
  final repo = ref.watch(photoRepositoryProvider);
  return repo.getPhotoCountByBoxId(boxId);
}

// ============ MUTATION PROVIDERS (Notifiers for state management) ============

/// Notifier to manage box mutations (create, update, delete)
class BoxMutationNotifier extends AutoDisposeAsyncNotifier<void> {
  late BoxRepository _repo;

  @override
  Future<void> build() async {
    _repo = ref.watch(boxRepositoryProvider);
  }

  Future<void> createBox({
    required String title,
    required String description,
    required String destination,
    required String status,
    required String notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.createBox(
        title: title,
        description: description,
        destination: destination,
        status: status,
        notes: notes,
      );
      // Refresh all boxes after creation
      ref.refresh(allBoxesProvider);
    });
  }

  Future<void> updateBox({
    required int id,
    required String title,
    required String description,
    required String destination,
    required String status,
    required String notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.updateBox(
        id: id,
        title: title,
        description: description,
        destination: destination,
        status: status,
        notes: notes,
      );
      ref.refresh(allBoxesProvider);
      ref.refresh(boxByIdProvider(id));
    });
  }

  Future<void> deleteBox(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteBox(id);
      ref.refresh(allBoxesProvider);
    });
  }
}

/// Provider for box mutations
@riverpod
class BoxMutation extends _$BoxMutation {
  @override
  Future<void> build() async {}

  Future<void> createBox({
    required String title,
    required String description,
    required String destination,
    required String status,
    required String notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(boxRepositoryProvider);
      await repo.createBox(
        title: title,
        description: description,
        destination: destination,
        status: status,
        notes: notes,
      );
      ref.refresh(allBoxesProvider);
    });
  }

  Future<void> updateBox({
    required int id,
    required String title,
    required String description,
    required String destination,
    required String status,
    required String notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(boxRepositoryProvider);
      await repo.updateBox(
        id: id,
        title: title,
        description: description,
        destination: destination,
        status: status,
        notes: notes,
      );
      ref.refresh(allBoxesProvider);
      ref.refresh(boxByIdProvider(id));
    });
  }

  Future<void> deleteBox(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(boxRepositoryProvider);
      await repo.deleteBox(id);
      ref.refresh(allBoxesProvider);
    });
  }
}

/// Notifier for item mutations
@riverpod
class ItemMutation extends _$ItemMutation {
  @override
  Future<void> build() async {}

  Future<void> createItem({
    required int boxId,
    required String name,
    required int quantity,
    required String notes,
    required bool fragile,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(itemRepositoryProvider);
      await repo.createItem(
        boxId: boxId,
        name: name,
        quantity: quantity,
        notes: notes,
        fragile: fragile,
      );
      ref.refresh(itemsByBoxIdProvider(boxId));
      ref.refresh(fragileItemCountProvider(boxId));
    });
  }

  Future<void> updateItem({
    required int id,
    required int boxId,
    required String name,
    required int quantity,
    required String notes,
    required bool fragile,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(itemRepositoryProvider);
      await repo.updateItem(
        id: id,
        name: name,
        quantity: quantity,
        notes: notes,
        fragile: fragile,
      );
      ref.refresh(itemsByBoxIdProvider(boxId));
      ref.refresh(fragileItemCountProvider(boxId));
    });
  }

  Future<void> deleteItem(int itemId, int boxId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(itemRepositoryProvider);
      await repo.deleteItem(itemId);
      ref.refresh(itemsByBoxIdProvider(boxId));
      ref.refresh(fragileItemCountProvider(boxId));
    });
  }
}

/// Notifier for photo mutations
@riverpod
class PhotoMutation extends _$PhotoMutation {
  @override
  Future<void> build() async {}

  Future<void> createPhoto({
    required int boxId,
    required String filePath,
    required String category,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(photoRepositoryProvider);
      await repo.createPhoto(
        boxId: boxId,
        filePath: filePath,
        category: category,
      );
      ref.refresh(photosByBoxIdProvider(boxId));
      ref.refresh(photoCountProvider(boxId));
    });
  }

  Future<void> updatePhotoCategory({
    required int photoId,
    required int boxId,
    required String category,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(photoRepositoryProvider);
      await repo.updatePhoto(id: photoId, category: category);
      ref.refresh(photosByBoxIdProvider(boxId));
    });
  }

  Future<void> deletePhoto(int photoId, int boxId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(photoRepositoryProvider);
      await repo.deletePhoto(photoId);
      ref.refresh(photosByBoxIdProvider(boxId));
      ref.refresh(photoCountProvider(boxId));
    });
  }
}
