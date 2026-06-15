import 'package:freezed_annotation/freezed_annotation.dart';

part 'report.freezed.dart';
part 'report.g.dart';

@freezed
abstract class Report with _$Report {
  const factory Report({
    required String id,
    @JsonKey(name: 'inspection_id') required String inspectionId,
    @JsonKey(name: 'generated_by') required String generatedBy,
    @JsonKey(name: 'generator_name') String? generatorName,
    @JsonKey(name: 'inspection_title') String? inspectionTitle,
    @JsonKey(name: 'minio_key') required String minioKey,
    required String sha256,
    @JsonKey(name: 'signature_key') String? signatureKey,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'download_url') String? downloadUrl,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}
