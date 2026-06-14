import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vistor_ai_mobile/core/services/gps_service.dart';
import 'package:vistor_ai_mobile/features/map/data/heatmap_point.dart';
import 'package:vistor_ai_mobile/features/map/data/map_repository.dart';
import 'package:vistor_ai_mobile/features/map/domain/map_data.dart';
import 'package:vistor_ai_mobile/features/map/domain/map_state.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

class MapCubit extends Cubit<MapState> {
  final MapRepository _repository;
  final GpsService _gpsService;

  MapCubit({
    required MapRepository repository,
    required GpsService gpsService,
  })  : _repository = repository,
        _gpsService = gpsService,
        super(const MapState.initial());

  Future<void> loadMap({double? lat, double? lon, double? radius}) async {
    final double currentRadius = radius ?? 
        state.maybeMap(
          loaded: (s) => s.data.radius,
          orElse: () => 300.0,
        );

    emit(const MapState.loading());

    try {
      double targetLat;
      double targetLon;

      if (lat == null || lon == null) {
        try {
          // Prioritize last known position for instant loading
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null) {
            targetLat = lastKnown.latitude;
            targetLon = lastKnown.longitude;
          } else {
            // Short timeout to prevent locking up the app on poor GPS signal
            final position = await _gpsService.getCurrentPosition().timeout(const Duration(seconds: 4));
            targetLat = position.latitude;
            targetLon = position.longitude;
          }
        } catch (_) {
          targetLat = -5.79448;
          targetLon = -35.2110;
        }
      } else {
        targetLat = lat;
        targetLon = lon;
      }

      final results = await Future.wait([
        _repository.getNearby(lat: targetLat, lon: targetLon, radiusM: currentRadius),
        _repository.getHeatmapData(),
      ]);

      final inspections = results[0] as List<Inspection>;
      final heatmapPoints = results[1] as List<HeatmapPoint>;

      final currentLayer = state.maybeMap(
        loaded: (s) => s.data.activeLayer,
        orElse: () => MapActiveLayer.markers,
      );

      emit(MapState.loaded(MapData(
        inspections: inspections,
        heatmapPoints: heatmapPoints,
        activeLayer: currentLayer,
        radius: currentRadius,
      )));
    } catch (e) {
      // Fallback: keep screen functional with empty list instead of showing error screen
      emit(MapState.loaded(MapData(
        inspections: const [],
        heatmapPoints: const [],
        activeLayer: MapActiveLayer.markers,
        radius: currentRadius,
      )));
    }
  }

  void toggleLayer() {
    state.maybeMap(
      loaded: (s) {
        const layers = MapActiveLayer.values;
        final nextIndex = (s.data.activeLayer.index + 1) % layers.length;
        emit(MapState.loaded(s.data.copyWith(activeLayer: layers[nextIndex])));
      },
      orElse: () {},
    );
  }

  Future<void> updateRadius(double newRadius) async {
    final currentData = state.maybeMap(
      loaded: (s) => s.data,
      orElse: () => null,
    );

    if (currentData != null) {
      await loadMap(radius: newRadius);
    } else {
      emit(MapState.loaded(MapData(
        inspections: const [],
        heatmapPoints: const [],
        radius: newRadius,
      )));
    }
  }
}
