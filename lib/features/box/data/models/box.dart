/// Domain model for a box in the inventory.
/// This represents the pure data structure before Drift serialization.
class Box {
  final int? id;
  final String boxNumber; // e.g., "KT-001"
  final String title;
  final String description;
  final String destination; // e.g., "Yeni Ev"
  final String status; // e.g., "Beklemede", "Taşındı"
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Box({
    this.id,
    required this.boxNumber,
    required this.title,
    required this.description,
    required this.destination,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with optional field updates
  Box copyWith({
    int? id,
    String? boxNumber,
    String? title,
    String? description,
    String? destination,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Box(
      id: id ?? this.id,
      boxNumber: boxNumber ?? this.boxNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      destination: destination ?? this.destination,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Box(id: $id, boxNumber: $boxNumber, title: $title, destination: $destination, status: $status)';
}
