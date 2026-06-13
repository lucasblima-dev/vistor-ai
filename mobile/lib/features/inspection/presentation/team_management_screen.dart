import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/core/di/service_locator.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/team_management_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/team_management_state.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/widgets/assign_inspector_sheet.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  late final TeamManagementCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<TeamManagementCubit>();
    _cubit.loadQueue();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: BlocBuilder<TeamManagementCubit, TeamManagementState>(
        bloc: _cubit,
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => _buildErrorState(message),
            loaded: (unassignedInspections, activeInspectors, isAssigning, error) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(unassignedInspections.length),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.clock, color: AppColors.secondary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Fila de Atribuição',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: unassignedInspections.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: unassignedInspections.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final inspection = unassignedInspections[index];
                              return AssignmentCard(
                                inspection: inspection,
                                isDark: isDark,
                                onAssignPressed: () => _openAssignSheet(context, inspection.id),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppGradients.premium,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Gestão de Equipe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Text(
                  count == 1
                      ? '1 inspeção aguardando atribuição'
                      : '$count inspeções aguardando atribuição',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.checkCircle2,
              size: 64,
              color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Fila vazia!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Todas as inspeções cadastradas já possuem inspetores atribuídos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Equipe'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.alertTriangle, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Falha ao carregar dados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.onSurfDark
                      : AppColors.onSurfLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.error),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _cubit.loadQueue(),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAssignSheet(BuildContext context, String inspectionId) async {
    final messenger = ScaffoldMessenger.of(context);
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AssignInspectorSheet(
          inspectionId: inspectionId,
          cubit: _cubit,
        ),
      ),
    );

    if (success == true && mounted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Inspetor atribuído com sucesso!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ─── Componente: AssignmentCard ───────────────────────────────────────────────

class AssignmentCard extends StatelessWidget {
  final Inspection inspection;
  final bool isDark;
  final VoidCallback onAssignPressed;

  const AssignmentCard({
    super.key,
    required this.inspection,
    required this.isDark,
    required this.onAssignPressed,
  });

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return 'Há ${difference.inDays} ${difference.inDays == 1 ? "dia" : "dias"}';
    } else if (difference.inHours > 0) {
      return 'Há ${difference.inHours} ${difference.inHours == 1 ? "hora" : "horas"}';
    } else if (difference.inMinutes > 0) {
      return 'Há ${difference.inMinutes} ${difference.inMinutes == 1 ? "minuto" : "minutos"}';
    }
    return 'Agora mesmo';
  }

  @override
  Widget build(BuildContext context) {
    final isCritical = inspection.severity == InspectionSeverity.critical;
    final timeAgo = _formatTimeAgo(inspection.createdAt);
    final locationText = inspection.address ?? 'Sem endereço cadastrado';
    final isOpen = inspection.status == InspectionStatus.open;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  inspection.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                  ),
                ),
              ),
              if (isCritical) ...[
                const SizedBox(width: 8),
                const PulsingDot(),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                LucideIcons.mapPin,
                size: 13,
                color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '$locationText • $timeAgo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: const BorderSide(color: AppColors.secondary, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            icon: const Icon(LucideIcons.users, size: 16, color: AppColors.secondary),
            label: const Text(
              'Atribuir Inspetor',
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            onPressed: isOpen ? onAssignPressed : null,
          ),
        ],
      ),
    );
  }
}

// ─── Componente Auxiliar: PulsingDot ──────────────────────────────────────────

class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.criticalBg,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
