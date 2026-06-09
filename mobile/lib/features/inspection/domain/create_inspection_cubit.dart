import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:vistor_ai_mobile/core/services/gps_service.dart';
import 'package:vistor_ai_mobile/core/services/media_service.dart';
import 'package:vistor_ai_mobile/features/inspection/data/inspection_repository.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/create_inspection_state.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

class CreateInspectionCubit extends Cubit<CreateInspectionState> {
  final GpsService _gpsService;
  final MediaService _mediaService;
  final InspectionRepository _repository;

  CreateInspectionCubit({
    required GpsService gpsService,
    required MediaService mediaService,
    required InspectionRepository repository,
  })  : _gpsService = gpsService,
        _mediaService = mediaService,
        _repository = repository,
        super(const CreateInspectionState());

  void updateTitle(String title) => emit(state.copyWith(title: title));
  void updateCategory(String category) => emit(state.copyWith(category: category));
  void updateDescription(String description) => emit(state.copyWith(description: description));

  Future<void> captureGps() async {
    emit(state.copyWith(isLoadingGps: true, error: null));
    try {
      final position = await _gpsService.getCurrentPosition();
      
      String address = 'Endereço não encontrado';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [
            if (p.street != null && p.street!.isNotEmpty) p.street,
            if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality,
            if (p.subAdministrativeArea != null && p.subAdministrativeArea!.isNotEmpty) p.subAdministrativeArea,
            if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) p.administrativeArea,
          ];
          address = parts.isNotEmpty ? parts.join(', ') : 'Endereço identificado via GPS';
        }
      } catch (_) {
        // Reverse geocoding failed, use fallback
      }

      emit(state.copyWith(
        position: position, 
        address: address,
        isLoadingGps: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoadingGps: false));
    }
  }

  bool isAccuracyAcceptable() {
    if (state.position == null) return true;
    return _gpsService.isPrecisionAcceptable(state.position!);
  }

  void addPhoto(File photo) {
    final updatedPhotos = List<File>.from(state.photos)..add(photo);
    emit(state.copyWith(photos: updatedPhotos));
  }

  void removePhoto(int index) {
    final updatedPhotos = List<File>.from(state.photos)..removeAt(index);
    emit(state.copyWith(photos: updatedPhotos));
  }

  Future<void> submit(String inspectorId) async {
    if (state.photos.isEmpty) {
      emit(state.copyWith(error: 'Adicione pelo menos uma foto.'));
      return;
    }
    if (state.position == null) {
      emit(state.copyWith(error: 'Capture a localização GPS.'));
      return;
    }
    if (state.category.isEmpty) {
      emit(state.copyWith(error: 'Selecione uma categoria.'));
      return;
    }
    if (state.title.isEmpty) {
      emit(state.copyWith(error: 'Informe um título para a inspeção.'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      final payload = InspectionCreate(
        title: state.title,
        category: state.category,
        description: state.description,
        lat: state.position!.latitude,
        lon: state.position!.longitude,
        gpsAccuracy: state.position!.accuracy,
        address: state.address,
      );

      final inspection = await _repository.create(payload, inspectorId: inspectorId);
      
      // Upload media
      emit(state.copyWith(isUploadingMedia: true));
      for (var photo in state.photos) {
        await _mediaService.uploadMedia(inspection.id, photo);
      }
      
      // Fetch updated inspection for AI result
      // Aumentamos para 10 segundos para dar tempo do background task do backend 
      // processar a imagem e chamar a API do HuggingFace.
      await Future.delayed(const Duration(seconds: 10));
      final updatedInspection = await _repository.getById(inspection.id);
      
      emit(state.copyWith(
        isSubmitting: false, 
        isUploadingMedia: false, 
        aiResultInspection: updatedInspection,
      ));
    } catch (e) {
      String message = e.toString();
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('detail')) {
          message = data['detail'];
        } else if (e.type == DioExceptionType.connectionError) {
          message = 'Erro de conexão. Verifique o backend e o adb reverse.';
        } else {
          message = 'Erro no servidor: ${e.response?.statusCode}';
        }
      }
      emit(state.copyWith(error: message, isSubmitting: false, isUploadingMedia: false));
    }
  }

  Future<void> confirmAiLabel(String id) async {
    try {
      await _repository.update(id, const InspectionUpdate(status: InspectionStatus.open));
      emit(state.copyWith(isCompleted: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> correctAiLabel(String id, InspectionSeverity severity) async {
    try {
      await _repository.update(id, InspectionUpdate(
        status: InspectionStatus.open,
        severity: severity,
        humanLabel: 'Classificação manual pelo inspetor',
      ));
      emit(state.copyWith(isCompleted: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
