import 'package:freezed_annotation/freezed_annotation.dart';

part 'media.freezed.dart';
part 'media.g.dart';

enum MediaType {
  @JsonValue('photo')
  photo,
  @JsonValue('video')
  video,
  @JsonValue('pdf')
  pdf,
}

@freezed
class Media with _$Media {
  const factory Media({
    required String id,
    @JsonKey(name: 'inspection_id') required String inspectionId,
    required MediaType type,
    @JsonKey(name: 'minio_key') required String minioKey,
    @JsonKey(name: 'thumbnail_key') String? thumbnailKey,
    @JsonKey(name: 'mime_type') required String mimeType,
    @JsonKey(name: 'size_bytes') required int sizeBytes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Media;

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
}
