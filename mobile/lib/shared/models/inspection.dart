import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection.freezed.dart';
part 'inspection.g.dart';

enum InspectionSeverity {
  @JsonValue('critical')
  critical,
  @JsonValue('moderate')
  moderate,
  @JsonValue('low')
  low,
  @JsonValue('pending_review')
  pendingReview,
}

enum InspectionStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('open')
  open,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('resolved')
  resolved,
  @JsonValue('archived')
  archived,
}

@freezed
class Inspection with _$Inspection {
  const factory Inspection({
    required String id,
    @JsonKey(name: 'inspector_id') required String inspectorId,
    @JsonKey(name: 'assigned_to') String? assignedTo,
    required String category,
    String? description,
    InspectionSeverity? severity,
    @JsonKey(name: 'ai_label') String? aiLabel,
    @JsonKey(name: 'ai_score') double? aiScore,
    @JsonKey(name: 'human_label') String? humanLabel,
    required double lat,
    required double lon,
    @JsonKey(name: 'gps_accuracy') double? gpsAccuracy,
    String? address,
    required InspectionStatus status,
    @Default(true) @JsonKey(name: 'is_synced') bool isSynced,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Inspection;

  factory Inspection.fromJson(Map<String, dynamic> json) => _$InspectionFromJson(json);
}
