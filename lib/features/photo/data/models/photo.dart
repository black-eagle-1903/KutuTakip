/// Domain model for a photo attached to a box.
class Photo {
  final int? id;
  final int boxId; // Foreign key to Box
  final String filePath; // Relative path in app documents directory
  final String category; // "Dış", "İç", "Diğer"
  final DateTime createdAt;
  final DateTime updatedAt;

  Photo({
    this.id,
    required this.boxId,
    required this.filePath,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with optional field updates
  Photo copyWith({
    int? id,
    int? boxId,
    String? filePath,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Photo(
      id: id ?? this.id,
      boxId: boxId ?? this.boxId,
      filePath: filePath ?? this.filePath,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Photo(id: $id, category: $category, filePath: $filePath)';
}
