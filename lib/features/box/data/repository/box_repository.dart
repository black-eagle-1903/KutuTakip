import 'package:kututakip/database/app_database.dart';
import 'package:kututakip/features/box/data/models/box.dart';

/// Repository for box operations
class BoxRepository {
  final AppDatabase _db;

  BoxRepository(this._db);

  /// Get all boxes
  Future<List<Box>> getAllBoxes() async {
    return _db.getAllBoxes();
  }

  /// Get box by ID
  Future<Box?> getBoxById(int id) async {
    return _db.getBoxById(id);
  }

  /// Get next sequential box number (KT-001, KT-002, ...)
  Future<String> getNextBoxNumber() async {
    return _db.getNextBoxNumber();
  }

  /// Create a new box
  Future<int> createBox({
    required String title,
    required String description,
    required String destination,
    required String status,
    required String notes,
  }) async {
    final boxNumber = await getNextBoxNumber();
    final now = DateTime.now();

    return _db.createBox(
      BoxesCompanion(
        boxNumber: Value(boxNumber),
        title: Value(title),
        description: Value(description),
        destination: Value(destination),
        status: Value(status),
        notes: Value(notes),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Update an existing box
  Future<bool> updateBox({
    required int id,
    required String title,
    required String description,
    required String destination,
    required String status,
    required String notes,
  }) async {
    final now = DateTime.now();

    return _db.updateBox(
      BoxesCompanion(
        id: Value(id),
        title: Value(title),
        description: Value(description),
        destination: Value(destination),
        status: Value(status),
        notes: Value(notes),
        updatedAt: Value(now),
      ),
    );
  }

  /// Delete a box (cascade deletes items and photos)
  Future<int> deleteBox(int id) async {
    return _db.deleteBox(id);
  }

  /// Search boxes by query (case-insensitive)
  /// Matches: boxNumber, title, description, destination
  Future<List<Box>> searchBoxes(String query) async {
    if (query.isEmpty) {
      return getAllBoxes();
    }
    return _db.searchBoxes(query);
  }

  /// Get box statistics for dashboard
  Future<Map<String, dynamic>> getStatistics() async {
    final allBoxes = await getAllBoxes();

    return {
      'totalBoxes': allBoxes.length,
      'movedBoxes': allBoxes.where((b) => b.status == 'Taşındı').length,
      'pendingBoxes': allBoxes.where((b) => b.status == 'Beklemede').length,
    };
  }
}
