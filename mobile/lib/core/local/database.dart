import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:vistor_ai_mobile/core/local/inspection_dao.dart';

part 'database.g.dart';

class LocalInspections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get inspectorId => text()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  TextColumn get description => text().nullable()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  RealColumn get gpsAccuracy => real().nullable()();
  TextColumn get severity => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [LocalInspections], daos: [InspectionDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(localInspections, localInspections.title);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vistor_ai.sqlite'));
    return NativeDatabase(file);
  });
}
