import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vistor_ai_mobile/shared/models/user.dart';

part 'user_management_state.freezed.dart';

@freezed
class UserManagementState with _$UserManagementState {
  const factory UserManagementState.initial() = _Initial;
  const factory UserManagementState.loading() = _Loading;
  const factory UserManagementState.loaded({
    required List<User> users,
    @Default('') String searchQuery,
    @Default(false) bool isUpdating,
    String? error,
  }) = _Loaded;
  const factory UserManagementState.error(String message) = _Error;
}
