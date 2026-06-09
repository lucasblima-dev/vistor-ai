import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';
import 'package:vistor_ai_mobile/shared/models/audit_log.dart';

part 'inspection_detail_state.freezed.dart';

@freezed
class InspectionDetailState with _$InspectionDetailState {
  const factory InspectionDetailState.initial() = _Initial;
  const factory InspectionDetailState.loading() = _Loading;
  const factory InspectionDetailState.loaded({
    required Inspection inspection,
    @Default([]) List<AuditLog> history,
    @Default(false) bool isUpdatingStatus,
    @Default(false) bool isGeneratingReport,
    String? error,
  }) = _Loaded;
  const factory InspectionDetailState.error(String message) = _Error;
}
