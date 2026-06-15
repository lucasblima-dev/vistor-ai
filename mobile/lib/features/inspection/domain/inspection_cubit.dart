import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vistor_ai_mobile/core/utils/error_handler.dart';
import 'package:vistor_ai_mobile/features/inspection/data/inspection_repository.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/inspection_state.dart';

class InspectionCubit extends Cubit<InspectionState> {
  final InspectionRepository _repository;
  String? _currentStatus;
  String? _currentSeverity;

  InspectionCubit({
    required InspectionRepository repository,
  })  : _repository = repository,
      super(const InspectionState.initial());

  Future<void> load() async {
    emit(const InspectionState.loading());
    try {
      final inspections = await _repository.getAll(
        status: _currentStatus,
        severity: _currentSeverity,
      );
      if (inspections.isEmpty) {
        emit(const InspectionState.empty());
      } else {
        emit(InspectionState.loaded(inspections));
      }
    } catch (e) {
      emit(InspectionState.error(ErrorHandler.handle(e, 'Não foi possível carregar as inspeções.')));
    }
  }

  Future<void> refresh() async {
    await load();
  }

  void filterByStatus(String? status) {
    _currentStatus = status;
    load();
  }

  void filterBySeverity(String? severity) {
    _currentSeverity = severity;
    load();
  }

  void clearFilters() {
    _currentStatus = null;
    _currentSeverity = null;
    load();
  }

  String? get currentStatus => _currentStatus;
  String? get currentSeverity => _currentSeverity;
}
