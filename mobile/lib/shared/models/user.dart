import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserRole {
  @JsonValue('inspector')
  inspector,
  @JsonValue('manager')
  manager,
  @JsonValue('admin')
  admin,
}

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    required UserRole role,
    @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
