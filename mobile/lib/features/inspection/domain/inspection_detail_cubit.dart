import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vistor_ai_mobile/features/inspection/data/inspection_repository.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/inspection_detail_state.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

class InspectionDetailCubit extends Cubit<InspectionDetailState> {
  final InspectionRepository _repository;
  final String _inspectionId;

  InspectionDetailCubit({
    required InspectionRepository repository,
    required String inspectionId,
  })  : _repository = repository,
        _inspectionId = inspectionId,
        super(const InspectionDetailState.initial());

  Future<void> load() async {
    emit(const InspectionDetailState.loading());
    try {
      final inspection = await _repository.getById(_inspectionId);
      final history = await _repository.getHistory(_inspectionId);
      emit(InspectionDetailState.loaded(
        inspection: inspection,
        history: history,
      ));
    } catch (e) {
      emit(InspectionDetailState.error(e.toString()));
    }
  }

  Future<void> updateStatus(InspectionStatus status) async {
    final currentState = state.maybeMap(
      loaded: (s) => s,
      orElse: () => null,
    );
    if (currentState == null) return;

    emit(currentState.copyWith(isUpdatingStatus: true, error: null));
    try {
      final updated = await _repository.update(
        _inspectionId,
        InspectionUpdate(status: status),
      );
      final history = await _repository.getHistory(_inspectionId);
      emit(currentState.copyWith(
        inspection: updated,
        history: history,
        isUpdatingStatus: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isUpdatingStatus: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> confirmAiLabel() async {
    final currentState = state.maybeMap(
      loaded: (s) => s,
      orElse: () => null,
    );
    if (currentState == null || currentState.inspection.aiLabel == null) return;

    emit(currentState.copyWith(isUpdatingStatus: true, error: null));
    try {
      final updated = await _repository.update(
        _inspectionId,
        InspectionUpdate(humanLabel: currentState.inspection.aiLabel),
      );
      emit(currentState.copyWith(
        inspection: updated,
        isUpdatingStatus: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isUpdatingStatus: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> correctAiLabel(InspectionSeverity severity) async {
    final currentState = state.maybeMap(
      loaded: (s) => s,
      orElse: () => null,
    );
    if (currentState == null) return;

    emit(currentState.copyWith(isUpdatingStatus: true, error: null));
    try {
      final updated = await _repository.update(
        _inspectionId,
        InspectionUpdate(
          severity: severity,
          humanLabel: currentState.inspection.aiLabel ?? 'Manual Override',
        ),
      );
      emit(currentState.copyWith(
        inspection: updated,
        isUpdatingStatus: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isUpdatingStatus: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> generateReport() async {
    final currentState = state.maybeMap(
      loaded: (s) => s,
      orElse: () => null,
    );
    if (currentState == null) return;

    emit(currentState.copyWith(isGeneratingReport: true, error: null));
    try {
      await _repository.generateReport(_inspectionId);
      emit(currentState.copyWith(isGeneratingReport: false));
    } catch (e) {
      emit(currentState.copyWith(
        isGeneratingReport: false,
        error: e.toString(),
      ));
    }
  }
}
