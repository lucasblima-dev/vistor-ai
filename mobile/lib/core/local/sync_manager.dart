import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vistor_ai_mobile/core/api/api_client.dart';
import 'package:vistor_ai_mobile/core/api/endpoints.dart';
import 'package:vistor_ai_mobile/core/local/inspection_dao.dart';

class SyncManager {
  final ApiClient _apiClient;
  final InspectionDao _inspectionDao;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;

  SyncManager(this._apiClient, this._inspectionDao);

  Stream<int> get pendingCount => _inspectionDao.watchPendingCount();

  void startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        syncAll();
      }
    });
  }

  void stopListening() {
    _subscription?.cancel();
  }

  Future<void> syncAll() async {
    final pending = await _inspectionDao.getPendingInspections();
    if (pending.isEmpty) return;

    for (final insp in pending) {
      try {
        final response = await _apiClient.dio.post(
          AppEndpoints.inspections,
          data: {
            'category': insp.category,
            'description': insp.description,
            'lat': insp.lat,
            'lon': insp.lon,
            // Adicione outros campos conforme o schema InspectionCreate do backend
          },
        );

        if (response.statusCode == 201) {
          final remoteId = response.data['id'];
          await _inspectionDao.markAsSynced(insp.id, remoteId);
        }
      } catch (e) {
        // Falha silenciosa para manter na fila
        continue;
      }
    }
  }
}
