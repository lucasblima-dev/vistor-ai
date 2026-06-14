class AdminSettingsState {
  final bool isLoading;
  final bool isSaving;
  final String modelId;
  final double confidenceThreshold;
  final List<Map<String, dynamic>> auditLogs;
  final String? error;
  final String? successMessage;

  const AdminSettingsState({
    this.isLoading = false,
    this.isSaving = false,
    this.modelId = '',
    this.confidenceThreshold = 0.55,
    this.auditLogs = const [],
    this.error,
    this.successMessage,
  });

  AdminSettingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? modelId,
    double? confidenceThreshold,
    List<Map<String, dynamic>>? auditLogs,
    String? error,
    String? successMessage,
  }) {
    return AdminSettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      modelId: modelId ?? this.modelId,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      auditLogs: auditLogs ?? this.auditLogs,
      error: error,
      successMessage: successMessage,
    );
  }
}
