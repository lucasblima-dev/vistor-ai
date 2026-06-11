import 'package:vistor_ai_mobile/shared/models/report.dart';

abstract class ReportRepository {
  Future<Report> generate(String inspectionId);
  Future<Report> getById(String id);
  Future<List<Report>> getAll();
}
