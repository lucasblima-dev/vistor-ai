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

    final List<dynamic> data = response.data;
    return data.map((json) {
      final inspectionJson = json['inspection'] as Map<String, dynamic>;
      return Inspection.fromJson(inspectionJson);
    }).toList();
  }

  Future<List<HeatmapPoint>> getHeatmapData() async {
    final response = await _apiClient.get(
      AppEndpoints.export,
      queryParameters: {
        'format': 'geojson',
      },
    );

    // O backend retorna um GeoJSON FeatureCollection
    final Map<String, dynamic> geojson = response.data;
    final List<dynamic> features = geojson['features'] as List<dynamic>;

    return features.map((feature) => HeatmapPoint.fromJson(feature)).toList();
  }
}
