import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vistor_ai_mobile/features/report/domain/repositories/report_repository.dart';
import 'package:vistor_ai_mobile/features/report/presentation/cubit/report_state.dart';
import 'package:vistor_ai_mobile/shared/models/report.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository _repository;
  final Dio _dio = Dio();

  ReportCubit({required ReportRepository repository})
      : _repository = repository,
        super(const ReportState.initial());

  Future<void> loadAll() async {
    emit(const ReportState.loading());
    try {
      final reports = await _repository.getAll();
      emit(ReportState.loaded(reports));
    } catch (e) {
      emit(ReportState.error(_formatError(e)));
    }
  }

  Future<Report?> generate(String inspectionId) async {
    emit(const ReportState.loading());
    try {
      final report = await _repository.generate(inspectionId);
      final reports = await _repository.getAll();
      emit(ReportState.loaded(reports));
      return report;
    } catch (e) {
      emit(ReportState.error(_formatError(e)));
      return null;
    }
  }

  Future<void> downloadForPreview(Report report) async {
    emit(const ReportState.downloading(0.0));
    try {
      final freshReport = await _repository.getById(report.id);
      final url = freshReport.downloadUrl;
      if (url == null || url.isEmpty) {
        throw Exception('URL de download não disponível.');
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/laudo_${report.id.substring(0, 8)}.pdf';
      final file = File(filePath);

      // Check if file already exists and hash is valid
      if (await file.exists()) {
        final isValid = await _validateHash(filePath, report.sha256);
        if (isValid) {
          emit(ReportState.downloaded(filePath));
          return;
        } else {
          await file.delete();
        }
      }

      // Download from server with progress
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            emit(ReportState.downloading(progress));
          }
        },
      );

      // RN-09: Revalidate hash
      final isValid = await _validateHash(filePath, report.sha256);
      if (!isValid) {
        if (await file.exists()) {
          await file.delete();
        }
        throw Exception(
          'Erro de integridade (RN-09): O hash SHA-256 do arquivo baixado diverge do registrado no laudo.',
        );
      }

      emit(ReportState.downloaded(filePath));
    } catch (e) {
      emit(ReportState.error(_formatError(e)));
    }
  }

  Future<String?> downloadToLocal(Report report) async {
    try {
      final freshReport = await _repository.getById(report.id);
      final url = freshReport.downloadUrl;
      if (url == null || url.isEmpty) {
        throw Exception('URL de download não disponível.');
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        directory ??= await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Diretório de destino não encontrado.');
      }

      final downloadDir = Directory('${directory.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final filePath = '${downloadDir.path}/laudo_${report.id.substring(0, 8)}.pdf';

      await _dio.download(url, filePath);

      // RN-09: Revalidate hash
      final isValid = await _validateHash(filePath, report.sha256);
      if (!isValid) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
        throw Exception(
          'Erro de integridade (RN-09): O hash SHA-256 do arquivo baixado diverge do registrado no laudo.',
        );
      }

      return filePath;
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  Future<void> shareReport(Report report) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/laudo_${report.id.substring(0, 8)}.pdf';
      final file = File(filePath);

      bool fileExists = await file.exists();
      if (fileExists) {
        final isValid = await _validateHash(filePath, report.sha256);
        if (!isValid) {
          await file.delete();
          fileExists = false;
        }
      }

      if (!fileExists) {
        final freshReport = await _repository.getById(report.id);
        final url = freshReport.downloadUrl;
        if (url == null || url.isEmpty) {
          throw Exception('URL de download não disponível.');
        }
        await _dio.download(url, filePath);

        final isValid = await _validateHash(filePath, report.sha256);
        if (!isValid) {
          if (await file.exists()) {
            await file.delete();
          }
          throw Exception(
            'Erro de integridade (RN-09): O hash SHA-256 do arquivo baixado diverge do registrado no laudo.',
          );
        }
      }

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(filePath)], text: 'Laudo técnico da inspeção');
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  Future<bool> _validateHash(String filePath, String expectedHash) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final hashBytes = sha256.convert(bytes).toString();
      return hashBytes.toLowerCase() == expectedHash.toLowerCase();
    } catch (e) {
      return false;
    }
  }

  String _formatError(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Timeout de conexão com o servidor.';
      }
      return 'Erro na comunicação com o servidor: ${e.message}';
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}
