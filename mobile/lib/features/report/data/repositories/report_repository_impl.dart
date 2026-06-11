import 'dart:async';
import 'package:vistor_ai_mobile/core/api/api_client.dart';
import 'package:vistor_ai_mobile/core/api/endpoints.dart';
import 'package:vistor_ai_mobile/features/report/domain/repositories/report_repository.dart';
import 'package:vistor_ai_mobile/shared/models/report.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ApiClient _apiClient;

  ReportRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Report> generate(String inspectionId) async {
    const maxAttempts = 15; // 30s / 2s = 15 attempts
    const delay = Duration(seconds: 2);

    // Initial trigger
    await _apiClient.post(
      AppEndpoints.generateReport,
      data: {'inspection_id': inspectionId},
    );

    // Polling
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(delay);
      
      final response = await _apiClient.post(
        AppEndpoints.generateReport,
        data: {'inspection_id': inspectionId},
      );

      final data = response.data as Map<String, dynamic>;
      
      if (data['status'] == 'exists') {
        final reportId = data['report_id'] as String;
        return getById(reportId);
      }
    }

    throw Exception('Tempo limite excedido ao gerar o laudo técnico.');
  }

  @override
  Future<Report> getById(String id) async {
    final response = await _apiClient.get(AppEndpoints.reportDetail(id));
    return Report.fromJson(response.data);
  }

  @override
  Future<List<Report>> getAll() async {
    final response = await _apiClient.get('/reports/');
    final List<dynamic> data = response.data;
    return data.map((json) => Report.fromJson(json)).toList();
  }
}
