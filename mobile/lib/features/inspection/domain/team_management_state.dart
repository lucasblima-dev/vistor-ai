import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';
import 'package:vistor_ai_mobile/shared/models/user.dart';

part 'team_management_state.freezed.dart';

@freezed
class TeamManagementState with _$TeamManagementState {
  const factory TeamManagementState.initial() = _Initial;
  const factory TeamManagementState.loading() = _Loading;
  const factory TeamManagementState.loaded({
    required List<Inspection> unassignedInspections,
    @Default([]) List<User> activeInspectors,
    @Default(false) bool isAssigning,
    String? error,
  }) = _Loaded;
  const factory TeamManagementState.error(String message) = _Error;
}
