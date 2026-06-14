import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/core/di/service_locator.dart';
import 'package:vistor_ai_mobile/features/auth/domain/admin_settings_cubit.dart';
import 'package:vistor_ai_mobile/features/auth/domain/admin_settings_state.dart';
import 'package:vistor_ai_mobile/shared/widgets/error_snackbar.dart';
import 'dart:convert';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  late final AdminSettingsCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  double _threshold = 0.55;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AdminSettingsCubit>();
    _cubit.loadSettingsAndLogs();
  }

  @override
  void dispose() {
    _modelController.dispose();
    super.dispose();
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (_) {
      return isoString;
    }
  }

  String _prettyJson(dynamic val) {
    if (val == null) return 'Nenhum';
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(val);
    } catch (_) {
      return val.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              LucideIcons.arrowLeft,
              color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Configurações do Sistema',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(
                icon: Icon(LucideIcons.cpu),
                text: 'Modelos de IA',
              ),
              Tab(
                icon: Icon(LucideIcons.history),
                text: 'Logs de Auditoria',
              ),
            ],
          ),
        ),
        body: BlocConsumer<AdminSettingsCubit, AdminSettingsState>(
          bloc: _cubit,
          listener: (context, state) {
            if (state.error != null) {
              showErrorSnackbar(context, state.error!);
            }
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            // Atualizar valores do formulário quando carregados pela primeira vez
            if (state.modelId.isNotEmpty && _modelController.text.isEmpty && !state.isLoading) {
              _modelController.text = state.modelId;
              _threshold = state.confidenceThreshold;
            }

            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                _buildAiSettingsTab(state, isDark),
                _buildAuditLogsTab(state, isDark),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAiSettingsTab(AdminSettingsState state, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Card(
          elevation: 2,
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.sparkles, color: AppColors.primary, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Configuração do Motor de IA',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Troque o modelo HuggingFace do classificador e defina o limiar de aceitação das predições.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                    labelText: 'ID do Modelo HuggingFace',
                    prefixIcon: Icon(LucideIcons.box, size: 20),
                    hintText: 'Ex: google/vit-base-patch16-224',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe o ID do modelo.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Limiar de Confiança (Threshold)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _threshold.toStringAsFixed(2),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Abaixo desse valor, a predição da IA é marcada como "Revisão Pendente" (RN-04).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _threshold,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _threshold = val;
                    });
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.isSaving
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _cubit.saveSettings(
                                modelId: _modelController.text.trim(),
                                confidenceThreshold: _threshold,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Salvar Alterações',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuditLogsTab(AdminSettingsState state, bool isDark) {
    if (state.auditLogs.isEmpty) {
      return const Center(
        child: Text('Nenhum log de auditoria encontrado.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _cubit.loadSettingsAndLogs(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.auditLogs.length,
        itemBuilder: (context, index) {
          final log = state.auditLogs[index];
          final String action = log['action'] ?? '';
          final String entity = log['entity'] ?? '';
          final String userName = log['user_name'] ?? 'Sistema';
          final String timestamp = _formatDateTime(log['created_at']);
          final String entityId = log['entity_id'] ?? '';

          IconData icon;
          Color color;
          switch (action) {
            case 'create':
            case 'user_created':
              icon = LucideIcons.plusCircle;
              color = AppColors.success;
              break;
            case 'update':
            case 'user_updated':
            case 'ai_settings_updated':
              icon = LucideIcons.edit3;
              color = AppColors.primary;
              break;
            case 'delete':
            case 'user_deactivated':
              icon = LucideIcons.xCircle;
              color = AppColors.error;
              break;
            case 'ai_classified':
              icon = LucideIcons.sparkles;
              color = Colors.purple;
              break;
            default:
              icon = LucideIcons.activity;
              color = Colors.blueGrey;
          }

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 20),
              ),
              title: Text(
                '$action no $entity',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                'Por: $userName • $timestamp',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID da Entidade: $entityId',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Valor Antigo:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _prettyJson(log['old_value']),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Novo Valor:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _prettyJson(log['new_value']),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
