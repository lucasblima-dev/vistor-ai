import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

part 'create_inspection_state.freezed.dart';

@freezed
abstract class CreateInspectionState with _$CreateInspectionState {
  const factory CreateInspectionState({
    @Default('') String title,
    @Default('') String category,
    @Default('') String description,
    @Default('') String address,
    Position? position,
    @Default([]) List<File> photos,
    @Default(false) bool isLoadingGps,
    @Default(false) bool isUploadingMedia,
    @Default(false) bool isSubmitting,
    @Default(false) bool isCompleted,
    String? error,
    Inspection? aiResultInspection,
  }) = _CreateInspectionState;
}
