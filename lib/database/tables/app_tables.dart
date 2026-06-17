import 'package:drift/drift.dart';

/// Table for destinations (Yeni Ev, Eski Ev, Yazlık Ev, Depo, Diğer, custom)
class Destinations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

/// Table for boxes in the inventory
class Boxes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get boxNumber => text().unique()(); // e.g., "KT-001"
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get destination => text()(); // Links to Destinations.name
  TextColumn get status => text().withDefault(const Constant('Beklemede'))(); // Status
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

/// Table for items inside boxes
class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get boxId => integer().customConstraint('REFERENCES boxes(id) ON DELETE CASCADE')();
  TextColumn get name => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get fragile => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {boxId, name}, // Unique item name per box
  ];
}

/// Table for photos attached to boxes
class Photos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get boxId => integer().customConstraint('REFERENCES boxes(id) ON DELETE CASCADE')();
  TextColumn get filePath => text()(); // Relative path to photo file
  TextColumn get category => text().withDefault(const Constant('Diğer'))(); // "Dış", "İç", "Diğer"
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}
