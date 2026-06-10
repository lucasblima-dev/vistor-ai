import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vistor_ai_mobile/features/map/domain/map_data.dart';

part 'map_state.freezed.dart';

@freezed
abstract class MapState with _$MapState {
  const factory MapState.initial() = _Initial;
  const factory MapState.loading() = _Loading;
  const factory MapState.loaded(MapData data) = _Loaded;
  const factory MapState.error(String message) = _Error;
}
