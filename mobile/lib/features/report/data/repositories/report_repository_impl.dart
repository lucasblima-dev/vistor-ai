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
    final triggerResponse = await _apiClient.post(
      AppEndpoints.generateReport,
      data: {'inspection_id': inspectionId},
    );
    if (triggerResponse.statusCode != 200 && triggerResponse.statusCode != 202 && triggerResponse.statusCode != 201) {
      throw Exception(triggerResponse.data is Map && triggerResponse.data.containsKey('detail') 
          ? triggerResponse.data['detail'] 
          : 'Erro ao iniciar geração do laudo (${triggerResponse.statusCode})');
    }

    // Polling
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(delay);
      
      final response = await _apiClient.post(
        AppEndpoints.generateReport,
        data: {'inspection_id': inspectionId},
      );

      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 202) {
        throw Exception(response.data is Map && response.data.containsKey('detail') 
            ? response.data['detail'] 
            : 'Erro durante geração do laudo (${response.statusCode})');
      }

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
    if (response.statusCode != 200 || response.data == null) {
      throw Exception(response.data is Map && response.data.containsKey('detail') 
          ? response.data['detail'] 
          : 'Erro ao carregar detalhes do laudo (${response.statusCode})');
    }
    return Report.fromJson(response.data);
  }

  @override
  Future<List<Report>> getAll() async {
    final response = await _apiClient.get('/reports/');
    if (response.statusCode != 200 || response.data == null) {
      throw Exception(response.data is Map && response.data.containsKey('detail') 
          ? response.data['detail'] 
          : 'Erro ao carregar laudos (${response.statusCode})');
    }
    final List<dynamic> data = response.data is List ? response.data : [];
    return data.map((json) => Report.fromJson(json)).toList();
  }
}
