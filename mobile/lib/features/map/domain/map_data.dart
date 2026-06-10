import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vistor_ai_mobile/features/map/data/heatmap_point.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

part 'map_data.freezed.dart';

enum MapActiveLayer { markers, heatmap, both }

@freezed
abstract class MapData with _$MapData {
  const factory MapData({
    required List<Inspection> inspections,
    required List<HeatmapPoint> heatmapPoints,
    @Default(MapActiveLayer.markers) MapActiveLayer activeLayer,
    @Default(300.0) double radius,
  }) = _MapData;
}
