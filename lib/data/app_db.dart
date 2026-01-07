import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart'; // ✅ NativeDatabase buradan gelir
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_db.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().withLength(min: 3, max: 32)();
  TextColumn get passwordHash => text()();
  TextColumn get salt => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // ✅ Drift 2.30+ için doğru imza: List<Set<Column>>?
  @override
  List<Set<Column>>? get uniqueKeys => [
        {username},
      ];
}

@DriftDatabase(tables: [Users])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'echo.sqlite'));
    return NativeDatabase(file);
  });
}
