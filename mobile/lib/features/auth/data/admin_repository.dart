import 'package:dio/dio.dart';
import 'package:vistor_ai_mobile/core/api/api_client.dart';
import 'package:vistor_ai_mobile/core/api/endpoints.dart';

class AdminRepository {
  final ApiClient _apiClient;

  AdminRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> getAiSettings() async {
    try {
      final response = await _apiClient.dio.get(AppEndpoints.aiSettings);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      throw Exception('Erro ao carregar configurações de IA');
    } on DioException catch (e) {
      throw Exception(e.getErrorMessage('Erro ao carregar configurações de IA'));
    }
  }

  Future<Map<String, dynamic>> updateAiSettings({
    required String modelId,
    required double confidenceThreshold,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        AppEndpoints.aiSettings,
        data: {
          'model_id': modelId,
          'confidence_threshold': confidenceThreshold,
        },
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      throw Exception('Erro ao atualizar configurações de IA');
    } on DioException catch (e) {
      throw Exception(e.getErrorMessage('Erro ao atualizar configurações de IA'));
    }
  }

  Future<List<Map<String, dynamic>>> getAuditLogs({int limit = 50, int offset = 0}) async {
    try {
      final response = await _apiClient.dio.get(
        AppEndpoints.auditLogs,
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      throw Exception('Erro ao carregar logs de auditoria');
    } on DioException catch (e) {
      throw Exception(e.getErrorMessage('Erro ao carregar logs de auditoria'));
    }
  }
}
