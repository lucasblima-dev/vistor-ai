import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/core/di/service_locator.dart';
import 'package:vistor_ai_mobile/features/auth/domain/admin_settings_cubit.dart';
import 'package:vistor_ai_mobile/features/auth/domain/admin_settings_state.dart';
import 'package:vistor_ai_mobile/shared/widgets/error_snackbar.dart';
import 'dart:convert';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  late final AdminSettingsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AdminSettingsCubit>();
    _cubit.loadSettingsAndLogs();
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
      if (val is String) {
        final decoded = json.decode(val);
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(decoded);
      }
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(val);
    } catch (_) {
      return val.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.activity,
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Logs do Sistema',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: BlocConsumer<AdminSettingsCubit, AdminSettingsState>(
                  bloc: _cubit,
                  listener: (context, state) {
                    if (state.error != null) {
                      showErrorSnackbar(context, state.error!);
                    }
                  },
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.auditLogs.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => _cubit.loadSettingsAndLogs(),
                        child: ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    LucideIcons.history,
                                    size: 48,
                                    color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nenhum log de auditoria',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final showLoadMore = state.hasMore;
                    return RefreshIndicator(
                      onRefresh: () => _cubit.loadSettingsAndLogs(),
                      child: ListView.separated(
                        itemCount: state.auditLogs.length + (showLoadMore ? 1 : 0),
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index == state.auditLogs.length) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: state.isLoadingMore
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : TextButton.icon(
                                        onPressed: () => _cubit.loadMoreLogs(),
                                        icon: const Icon(LucideIcons.plus, size: 16),
                                        label: const Text(
                                          'Carregar mais 5 logs',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                                        ),
                                      ),
                              ),
                            );
                          }

                          final log = state.auditLogs[index];
                          
                          final String action = log['action']?.toString() ?? '';
                          final String entity = log['entity']?.toString() ?? '';
                          final String userName = log['user_name']?.toString() ?? 'Sistema';
                          final String timestamp = _formatDateTime(log['created_at']?.toString());
                          final String entityId = log['entity_id']?.toString() ?? '';

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
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                              ),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.1),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              title: Text(
                                '$action no $entity',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
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
                                      Text(
                                        'Valor Antigo:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                                        ),
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
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                            color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Novo Valor:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                                        ),
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
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                            color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
