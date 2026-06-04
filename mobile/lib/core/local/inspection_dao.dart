import 'package:drift/drift.dart';
import 'package:vistor_ai_mobile/core/local/database.dart';

part 'inspection_dao.g.dart';

@DriftAccessor(tables: [LocalInspections])
class InspectionDao extends DatabaseAccessor<AppDatabase> with _$InspectionDaoMixin {
  InspectionDao(super.db);

  Future<int> insertLocalInspection(LocalInspectionsCompanion companion) {
    return into(localInspections).insert(companion);
  }

  Future<List<LocalInspection>> getPendingInspections() {
    return (select(localInspections)..where((t) => t.isSynced.equals(false))).get();
  }

  Future<void> markAsSynced(int localId, String remoteId) {
    return (update(localInspections)..where((t) => t.id.equals(localId))).write(
      LocalInspectionsCompanion(
        remoteId: Value(remoteId),
        isSynced: const Value(true),
      ),
    );
  }

  Future<List<LocalInspection>> getAllLocal() {
    return select(localInspections).get();
  }

  Future<void> updateLocal(String id, String? status, String? severity, String? humanLabel) {
    if (id.startsWith('local_')) {
      final localId = int.parse(id.replaceFirst('local_', ''));
      return (update(localInspections)..where((t) => t.id.equals(localId))).write(
        LocalInspectionsCompanion(
          status: status != null ? Value(status) : const Value.absent(),
          severity: severity != null ? Value(severity) : const Value.absent(),
        ),
      );
    } else {
      return (update(localInspections)..where((t) => t.remoteId.equals(id))).write(
        LocalInspectionsCompanion(
          status: status != null ? Value(status) : const Value.absent(),
          severity: severity != null ? Value(severity) : const Value.absent(),
        ),
      );
    }
  }
}
