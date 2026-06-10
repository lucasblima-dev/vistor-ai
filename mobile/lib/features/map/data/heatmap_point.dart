import 'package:vistor_ai_mobile/shared/models/inspection.dart';

class HeatmapPoint {
  final double latitude;
  final double longitude;
  final double weight;
  final InspectionSeverity severity;

  HeatmapPoint({
    required this.latitude,
    required this.longitude,
    required this.weight,
    required this.severity,
  });

  factory HeatmapPoint.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    final properties = json['properties'] as Map<String, dynamic>? ?? {};
    
    final severityStr = properties['severity'] as String?;
    final severity = InspectionSeverity.values.firstWhere(
      (e) => e.name == severityStr,
      orElse: () => InspectionSeverity.low,
    );

    // weight: critical=1.0, moderate=0.6, low=0.3
    double weight;
    switch (severity) {
      case InspectionSeverity.critical:
        weight = 1.0;
        break;
      case InspectionSeverity.moderate:
        weight = 0.6;
        break;
      case InspectionSeverity.low:
        weight = 0.3;
        break;
      default:
        weight = 0.1;
    }

    return HeatmapPoint(
      latitude: coordinates[1] as double,
      longitude: coordinates[0] as double,
      weight: weight,
      severity: severity,
    );
  }
}
