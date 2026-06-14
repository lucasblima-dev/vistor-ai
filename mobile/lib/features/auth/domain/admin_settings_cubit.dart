import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vistor_ai_mobile/features/auth/data/admin_repository.dart';
import 'admin_settings_state.dart';

class AdminSettingsCubit extends Cubit<AdminSettingsState> {
  final AdminRepository _adminRepository;

  AdminSettingsCubit({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(const AdminSettingsState());

  Future<void> loadSettingsAndLogs() async {
    emit(state.copyWith(isLoading: true, hasMore: true));
    try {
      final settings = await _adminRepository.getAiSettings();
      final logs = await _adminRepository.getAuditLogs(limit: 5, offset: 0);
      emit(state.copyWith(
        isLoading: false,
        modelId: settings['model_id'] ?? '',
        confidenceThreshold: (settings['confidence_threshold'] as num?)?.toDouble() ?? 0.55,
        auditLogs: logs,
        hasMore: logs.length == 5,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadMoreLogs() async {
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final currentLength = state.auditLogs.length;
      final nextLogs = await _adminRepository.getAuditLogs(limit: 5, offset: currentLength);
      emit(state.copyWith(
        isLoadingMore: false,
        auditLogs: [...state.auditLogs, ...nextLogs],
        hasMore: nextLogs.length == 5,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }

  Future<void> saveSettings({
    required String modelId,
    required double confidenceThreshold,
  }) async {
    emit(state.copyWith(isSaving: true));
    try {
      final settings = await _adminRepository.updateAiSettings(
        modelId: modelId,
        confidenceThreshold: confidenceThreshold,
      );
      final logs = await _adminRepository.getAuditLogs(limit: 5, offset: 0);
      emit(state.copyWith(
        isSaving: false,
        modelId: settings['model_id'] ?? '',
        confidenceThreshold: (settings['confidence_threshold'] as num?)?.toDouble() ?? 0.55,
        auditLogs: logs,
        hasMore: logs.length == 5,
        successMessage: 'Configurações de IA salvas com sucesso!',
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }
}
