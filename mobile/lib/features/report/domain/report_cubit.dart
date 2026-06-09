import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vistor_ai_mobile/features/report/data/report_repository.dart';
import 'package:vistor_ai_mobile/features/report/domain/report_state.dart';
import 'package:vistor_ai_mobile/shared/models/report.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository _repository;

  ReportCubit({required ReportRepository repository})
      : _repository = repository,
        super(const ReportState.initial());

  Future<void> loadAll() async {
    emit(const ReportState.loading());
    try {
      final reports = await _repository.getAll();
      emit(ReportState.loaded(reports));
    } catch (e) {
      emit(ReportState.error(e.toString()));
    }
  }

  Future<void> generate(String inspectionId) async {
    emit(const ReportState.generating());
    try {
      final report = await _repository.generate(inspectionId);
      emit(ReportState.generated(report));
      // Recarrega a lista para incluir o novo laudo
      final reports = await _repository.getAll();
      emit(ReportState.loaded(reports));
    } catch (e) {
      emit(ReportState.error(e.toString()));
    }
  }

  void openPdf(Report report) {
    // A navegação será tratada no BlocListener ou via GoRouter
    // Aqui apenas emitimos o estado de gerado caso queiramos forçar uma visualização
    emit(ReportState.generated(report));
  }
}
