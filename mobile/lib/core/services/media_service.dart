import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vistor_ai_mobile/core/api/api_client.dart';
import 'package:vistor_ai_mobile/core/api/endpoints.dart';

class MediaService {
  final ApiClient _apiClient;

  MediaService(this._apiClient);

  Future<String> uploadMedia(String inspectionId, File file) async {
    // 1. Comprime se imagem > 5MB e for imagem
    File fileToUpload = file;
    final String extension = p.extension(file.path).toLowerCase();
    final bool isImage = ['.jpg', '.jpeg', '.png'].contains(extension);
    
    if (isImage && file.lengthSync() > 5 * 1024 * 1024) {
      fileToUpload = await _compressImage(file);
    }

    final String filename = p.basename(fileToUpload.path);
    final String contentType = _getContentType(extension);
    final int fileSize = fileToUpload.lengthSync();

    // 2. POST /media/presign
    final response = await _apiClient.dio.post(
      AppEndpoints.presign,
      data: {
        'inspection_id': inspectionId,
        'filename': filename,
        'content_type': contentType,
        'file_size': fileSize,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao obter URL de upload');
    }

    final String uploadUrl = response.data['upload_url'];
    final String mediaId = response.data['id'];
    final String key = response.data['key'];

    // 3. PUT na upload_url (upload direto no MinIO)
    try {
      final uploadDio = Dio();
      final uploadResponse = await uploadDio.put(
        uploadUrl,
        data: fileToUpload.openRead(),
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': fileSize,
          },
        ),
      );

      if (uploadResponse.statusCode != 200) {
        throw Exception('Erro no upload para o storage (Status: ${uploadResponse.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Erro de conexão ao enviar imagem. Verifique se o MinIO está rodando '
          'e se você executou "adb reverse tcp:9000 tcp:9000".'
        );
      }
      rethrow;
    }

    // 4. POST /media/{id}/confirm
    await _apiClient.dio.post(AppEndpoints.mediaConfirm(mediaId));

    // 5. Retorna key
    return key;
  }

  Future<File> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = p.join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
    
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
    );

    if (result == null) return file;
    return File(result.path);
  }

  String _getContentType(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.mp4':
        return 'video/mp4';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
