import 'package:dio/dio.dart';
import 'package:vistor_ai_mobile/core/api/api_client.dart';
import 'package:vistor_ai_mobile/core/api/endpoints.dart';
import 'package:vistor_ai_mobile/features/map/data/heatmap_point.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

class MapRepository {
  final ApiClient _apiClient;

  MapRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Inspection>> getNearby({
    required double lat,
    required double lon,
    double radiusM = 300,
  }) async {
    final response = await _apiClient.get(
      AppEndpoints.nearby,
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'radius_m': radiusM,
      },
    );
 
    if (response.statusCode != 200 || response.data == null) {
      return [];
    }
 
    final List<dynamic> data = response.data is List ? response.data : [];
    return data.map((json) {
      final inspectionJson = json['inspection'] as Map<String, dynamic>;
      return Inspection.fromJson(inspectionJson);
    }).toList();
  }
 
  Future<List<HeatmapPoint>> getHeatmapData() async {
    final response = await _apiClient.get(AppEndpoints.heatmap);
 
    if (response.statusCode != 200 || response.data == null) {
      return [];
    }
 
    final Map<String, dynamic> geojson = response.data is Map ? response.data : {};
    final List<dynamic>? features = geojson['features'] as List<dynamic>?;
    if (features == null) {
      return [];
    }
 
    return features.map((feature) => HeatmapPoint.fromJson(feature)).toList();
  }

  Future<String> exportData({
    required String format,
    String? status,
    String? severity,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'format': format,
    };
    if (status != null) {
      queryParams['status'] = status;
    }
    if (severity != null) {
      queryParams['severity'] = severity;
    }
    if (startDate != null) {
      queryParams['start_date'] = startDate.toUtc().toIso8601String();
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toUtc().toIso8601String();
    }
 
    final response = await _apiClient.dio.get<String>(
      AppEndpoints.export,
      queryParameters: queryParams,
      options: Options(responseType: ResponseType.plain),
    );
 
    if (response.statusCode == 200 && response.data != null) {
      return response.data!;
    }
    throw Exception('Erro ao exportar dados do servidor.');
  }
}
