import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log.freezed.dart';
part 'audit_log.g.dart';

@freezed
abstract class AuditLog with _$AuditLog {
  const factory AuditLog({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    required String entity,
    @JsonKey(name: 'entity_id') required String entityId,
    required String action,
    @JsonKey(name: 'old_value') Map<String, dynamic>? oldValue,
    @JsonKey(name: 'new_value') Map<String, dynamic>? newValue,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    String? userName,
  }) = _AuditLog;

  factory AuditLog.fromJson(Map<String, dynamic> json) => _$AuditLogFromJson(json);
}
