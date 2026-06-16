import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:vistor_ai_mobile/core/api/api_client.dart';
import 'package:vistor_ai_mobile/core/api/endpoints.dart';
import 'package:vistor_ai_mobile/core/local/database.dart';
import 'package:vistor_ai_mobile/core/local/inspection_dao.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';
import 'package:vistor_ai_mobile/shared/models/audit_log.dart';

class InspectionRepository {
  final ApiClient _apiClient;
  final InspectionDao _inspectionDao;

  InspectionRepository({
    required ApiClient apiClient,
    required InspectionDao inspectionDao,
  })  : _apiClient = apiClient,
        _inspectionDao = inspectionDao;

  Future<List<Inspection>> getAll({String? status, String? severity, String? cursor}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (severity != null) queryParams['severity'] = severity;
      if (cursor != null) queryParams['cursor'] = cursor;

      final response = await _apiClient.dio.get(
        AppEndpoints.inspections,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Inspection.fromJson(json)).toList();
      }
      throw Exception('Erro ao buscar inspeções');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {

        final localData = await _inspectionDao.getAllLocal();
        return localData.map((local) => _mapLocalToInspection(local)).toList();
      }
      rethrow;
    }
  }

  Future<Inspection> getById(String id) async {
    try {
      final response = await _apiClient.dio.get(AppEndpoints.inspectionDetail(id));
      if (response.statusCode == 200) {
        return Inspection.fromJson(response.data);
      }
      throw Exception('Erro ao buscar detalhe da inspeção');
    } on DioException catch (_) {
      // Local fallback if needed
      rethrow;
    }
  }

  Future<List<AuditLog>> getHistory(String id) async {
    try {
      final response = await _apiClient.dio.get(
        '/inspections/$id/history',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => AuditLog.fromJson(json)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> generateReport(String inspectionId) async {
    try {
      final response = await _apiClient.dio.post(
        AppEndpoints.generateReport,
        data: {'inspection_id': inspectionId},
      );
      if (response.statusCode != 202 && response.statusCode != 200) {
        throw Exception('Erro ao disparar geração de laudo');
      }
    } on DioException catch (e) {
      throw Exception(e.getErrorMessage('Erro ao disparar geração de laudo'));
    }
  }

  Future<Inspection> create(InspectionCreate payload, {required String inspectorId}) async {
    try {
      final response = await _apiClient.dio.post(
        AppEndpoints.inspections,
        data: payload.toJson(),
      );

      if (response.statusCode == 201) {
        return Inspection.fromJson(response.data);
      }
      final errorDetail = response.data['detail'] ?? 'Erro desconhecido';
      throw Exception('Erro ao criar inspeção ($errorDetail)');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {

        final localId = await _inspectionDao.insertLocalInspection(
          LocalInspectionsCompanion.insert(
            inspectorId: inspectorId,
            title: payload.title,
            category: payload.category,
            description: Value(payload.description),
            lat: payload.lat,
            lon: payload.lon,
            gpsAccuracy: Value(payload.gpsAccuracy),
            address: Value(payload.address),
            createdAt: DateTime.now(),
            isSynced: const Value(false),
            status: const Value('draft'),
          ),
        );

        return Inspection(
          id: 'local_$localId',
          inspectorId: inspectorId,
          title: payload.title,
          category: payload.category,
          description: payload.description,
          location: LocationPoint(lat: payload.lat, lon: payload.lon),
          gpsAccuracy: payload.gpsAccuracy,
          address: payload.address,
          status: InspectionStatus.draft,
          isSynced: false,
          createdAt: DateTime.now(),
        );
      }
      rethrow;
    }
  }

  Future<Inspection> update(String id, InspectionUpdate payload) async {
    try {
      final response = await _apiClient.dio.patch(
        AppEndpoints.inspectionUpdate(id),
        data: payload.toJson(),
      );

      if (response.statusCode == 200) {
        return Inspection.fromJson(response.data);
      }
      throw Exception('Erro ao atualizar inspeção');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        
        await _inspectionDao.updateLocal(
          id,
          payload.status?.name,
          payload.severity?.name,
          payload.humanLabel,
        );
      }
      rethrow;
    }
  }

  Future<Inspection> reclassify(String id) async {
    try {
      final response = await _apiClient.dio.post(
        AppEndpoints.inspectionReclassify(id),
      );

      if (response.statusCode == 200) {
        return Inspection.fromJson(response.data);
      }
      throw Exception('Erro ao reavaliar com IA');
    } on DioException catch (e) {
      throw Exception(e.getErrorMessage('Erro ao reavaliar com IA'));
    }
  }

  Future<void> saveLocalMedia(String localInspectionId, String filePath) async {
    await _inspectionDao.insertLocalMedia(
      LocalMediaCompanion.insert(
        localInspectionId: localInspectionId,
        filePath: filePath,
      ),
    );
  }

  Inspection _mapLocalToInspection(dynamic local) {
    return Inspection(
      id: local.remoteId ?? 'local_${local.id}',
      inspectorId: local.inspectorId,
      title: local.title,
      category: local.category,
      description: local.description,
      location: LocationPoint(lat: local.lat, lon: local.lon),
      gpsAccuracy: local.gpsAccuracy,
      address: local.address,
      status: _mapStatus(local.status),
      severity: _mapSeverity(local.severity),
      isSynced: local.isSynced,
      createdAt: local.createdAt,
    );
  }

  InspectionStatus _mapStatus(String status) {
    return InspectionStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => InspectionStatus.draft,
    );
  }

  InspectionSeverity? _mapSeverity(String? severity) {
    if (severity == null) return null;
    return InspectionSeverity.values.firstWhere(
      (e) => e.name == severity,
      orElse: () => InspectionSeverity.pendingReview,
    );
  }
}
