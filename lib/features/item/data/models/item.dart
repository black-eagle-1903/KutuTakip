/// Domain model for an item inside a box.
class Item {
  final int? id;
  final int boxId; // Foreign key to Box
  final String name;
  final int quantity;
  final String notes;
  final bool fragile;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    this.id,
    required this.boxId,
    required this.name,
    required this.quantity,
    required this.notes,
    required this.fragile,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with optional field updates
  Item copyWith({
    int? id,
    int? boxId,
    String? name,
    int? quantity,
    String? notes,
    bool? fragile,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      boxId: boxId ?? this.boxId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      fragile: fragile ?? this.fragile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Item(id: $id, name: $name, quantity: $quantity, fragile: $fragile)';
}
