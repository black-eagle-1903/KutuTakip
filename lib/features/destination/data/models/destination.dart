/// Domain model for destination types.
class Destination {
  final int? id;
  final String name; // e.g., "Yeni Ev", "Depo", custom names
  final bool isDefault; // true for built-in destinations
  final DateTime createdAt;
  final DateTime updatedAt;

  Destination({
    this.id,
    required this.name,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  Destination copyWith({
    int? id,
    String? name,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Destination(id: $id, name: $name, isDefault: $isDefault)';
}
