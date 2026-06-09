import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vistor_ai_mobile/shared/models/user.dart';
import 'package:vistor_ai_mobile/shared/models/media.dart';

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
abstract class LocationPoint with _$LocationPoint {
  const factory LocationPoint({
    required double lat,
    required double lon,
  }) = _LocationPoint;

  factory LocationPoint.fromJson(Map<String, dynamic> json) => _$LocationPointFromJson(json);
}

@freezed
abstract class Inspection with _$Inspection {
  const Inspection._();

  const factory Inspection({
    required String id,
    @JsonKey(name: 'inspector_id') required String inspectorId,
    @JsonKey(name: 'assigned_to') String? assignedTo,
    required String title,
    required String category,
    String? description,
    InspectionSeverity? severity,
    @JsonKey(name: 'ai_label') String? aiLabel,
    @JsonKey(name: 'ai_score') double? aiScore,
    @JsonKey(name: 'human_label') String? humanLabel,
    required LocationPoint location,
    @JsonKey(name: 'gps_accuracy') double? gpsAccuracy,
    String? address,
    required InspectionStatus status,
    @Default(true) @JsonKey(name: 'is_synced') bool isSynced,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    User? inspector,
    @Default([]) List<Media> media,
  }) = _Inspection;

  double get lat => location.lat;
  double get lon => location.lon;

  factory Inspection.fromJson(Map<String, dynamic> json) => _$InspectionFromJson(json);
}

@freezed
abstract class InspectionCreate with _$InspectionCreate {
  const factory InspectionCreate({
    required String title,
    required String category,
    String? description,
    required double lat,
    required double lon,
    @JsonKey(name: 'gps_accuracy') double? gpsAccuracy,
    String? address,
  }) = _InspectionCreate;

  factory InspectionCreate.fromJson(Map<String, dynamic> json) => _$InspectionCreateFromJson(json);
}

@freezed
abstract class InspectionUpdate with _$InspectionUpdate {
  const factory InspectionUpdate({
    String? category,
    String? description,
    InspectionStatus? status,
    InspectionSeverity? severity,
    @JsonKey(name: 'assigned_to') String? assignedTo,
    @JsonKey(name: 'human_label') String? humanLabel,
  }) = _InspectionUpdate;

  factory InspectionUpdate.fromJson(Map<String, dynamic> json) => _$InspectionUpdateFromJson(json);
}
