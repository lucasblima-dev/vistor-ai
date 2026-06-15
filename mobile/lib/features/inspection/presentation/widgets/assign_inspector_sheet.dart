import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/team_management_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/team_management_state.dart';

class AssignInspectorSheet extends StatefulWidget {
  final String inspectionId;
  final TeamManagementCubit cubit;

  const AssignInspectorSheet({
    super.key,
    required this.inspectionId,
    required this.cubit,
  });

  @override
  State<AssignInspectorSheet> createState() => _AssignInspectorSheetState();
}

class _AssignInspectorSheetState extends State<AssignInspectorSheet> {
  String getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
 
  @override
  void initState() {
    super.initState();
    widget.cubit.loadQueue();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<TeamManagementCubit, TeamManagementState>(
      bloc: widget.cubit,
      listener: (context, state) {
        state.maybeWhen(
          loaded: (_, __, ___, error) {
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
          loaded: (unassignedInspections, activeInspectors, isAssigning, error) {
            return Container(
              padding: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.cardLg),
                  topRight: Radius.circular(AppRadius.cardLg),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  // Indicador de arrasto do BottomSheet
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.users, color: AppColors.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Atribuir Inspetor',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                                ),
                              ),
                              Text(
                                'Selecione um inspetor ativo para iniciar',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isAssigning)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
                  if (activeInspectors.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.userX,
                            size: 48,
                            color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhum inspetor ativo encontrado',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: activeInspectors.length,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemBuilder: (context, index) {
                          final inspector = activeInspectors[index];
                          final initials = getInitials(inspector.name);

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceVarDark : AppColors.surfaceVarLight,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                            ),
                            child: ListTile(
                              enabled: !isAssigning,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.lowBg, // Cor verde/success para inspetor ativo
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                inspector.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                                ),
                              ),
                              subtitle: Text(
                                inspector.email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
                                ),
                              ),
                              trailing: Icon(
                                LucideIcons.chevronRight,
                                size: 18,
                                color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
                              ),
                              onTap: () async {
                                final navigator = Navigator.of(context);
                                final success = await widget.cubit.assignInspector(
                                  widget.inspectionId,
                                  inspector.id,
                                );
                                if (success && mounted) {
                                  navigator.pop(true);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
          orElse: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
