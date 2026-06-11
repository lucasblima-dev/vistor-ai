import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/inspection_detail_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/inspection_detail_state.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/widgets/severity_badge.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/widgets/status_timeline.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';
import 'package:vistor_ai_mobile/shared/widgets/error_state.dart';
import 'package:vistor_ai_mobile/shared/widgets/loading_state.dart';
import 'package:vistor_ai_mobile/shared/widgets/glass_card.dart';
import 'package:vistor_ai_mobile/shared/widgets/error_snackbar.dart';
import 'package:vistor_ai_mobile/features/report/presentation/cubit/report_cubit.dart';
import 'package:vistor_ai_mobile/features/report/presentation/cubit/report_state.dart';
import 'package:vistor_ai_mobile/shared/widgets/loading_overlay.dart';

class _StatusBadge extends StatelessWidget {
  final InspectionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case InspectionStatus.open:
        color = Colors.blue;
        label = 'ABERTO';
        break;
      case InspectionStatus.inProgress:
        color = Colors.orange;
        label = 'EM ANDAMENTO';
        break;
      case InspectionStatus.resolved:
        color = Colors.green;
        label = 'RESOLVIDO';
        break;
      case InspectionStatus.archived:
        color = Colors.grey;
        label = 'ARQUIVADO';
        break;
      default:
        color = Colors.grey;
        label = 'DESCONHECIDO';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class InspectionDetailScreen extends StatefulWidget {
  final bool readOnly;
  const InspectionDetailScreen({super.key, this.readOnly = false});

  @override
  State<InspectionDetailScreen> createState() => _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends State<InspectionDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    context.read<InspectionDetailCubit>().load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<InspectionDetailCubit, InspectionDetailState>(
          listener: (context, state) {
            state.maybeWhen(
              loaded: (insp, history, updating, generating, reevaluating, error) {
                if (error != null) {
                  showErrorSnackbar(context, error);
                }
              },
              orElse: () {},
            );
          },
        ),
        BlocListener<ReportCubit, ReportState>(
          listener: (context, state) {
            state.maybeWhen(
              error: (msg) => showErrorSnackbar(context, msg),
              orElse: () {},
            );
          },
        ),
      ],
      child: BlocBuilder<InspectionDetailCubit, InspectionDetailState>(
        builder: (context, state) {
          return Stack(
            children: [
              Scaffold(
                body: state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const AppLoadingState(message: 'Carregando detalhes...'),
                  error: (msg) => AppErrorState(
                    message: msg,
                    onRetry: () => context.read<InspectionDetailCubit>().load(),
                  ),
                  loaded: (inspection, history, isUpdating, isGenerating, isReevaluating, error) => 
                      _buildContent(context, inspection, history, isUpdating, isGenerating, isReevaluating),
                ),
                bottomNavigationBar: widget.readOnly 
                    ? null 
                    : state.maybeMap(
                        loaded: (s) => _buildBottomBar(context, s.inspection),
                        orElse: () => null,
                      ),
              ),
              // Overlay de geração de laudo (via ReportCubit)
              context.watch<ReportCubit>().state.maybeWhen(
                    loading: () => const AppLoadingOverlay(message: 'Gerando laudo técnico...'),
                    orElse: () => const SizedBox.shrink(),
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, 
    Inspection inspection, 
    List<dynamic> history,
    bool isUpdating,
    bool isGenerating,
    bool isReevaluating,
  ) {
    final heroImageUrl = inspection.media.isNotEmpty 
        ? inspection.media.first.thumbnailUrl ?? '' 
        : '';

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final appBarHeight = constraints.biggest.height;
                  final statusBarHeight = MediaQuery.of(context).padding.top;
                  final isCollapsed = appBarHeight <= kToolbarHeight + statusBarHeight + 30;

                  return FlexibleSpaceBar(
                    stretchModes: const [StretchMode.zoomBackground],
                    centerTitle: false,
                    titlePadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, 
                      vertical: isCollapsed ? 10 : 16
                    ),
                    title: isCollapsed
                        ? SafeArea(
                            bottom: false,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    inspection.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SeverityBadge(
                                  severity: inspection.severity ?? InspectionSeverity.pendingReview,
                                  isLarge: false,
                                ),
                                const SizedBox(width: 4),
                                _StatusBadge(status: inspection.status),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SeverityBadge(
                                    severity: inspection.severity ?? InspectionSeverity.pendingReview,
                                    isLarge: true,
                                  ),
                                  const SizedBox(width: 8),
                                  _StatusBadge(status: inspection.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                inspection.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  shadows: [Shadow(color: Colors.black87, blurRadius: 10)],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'inspection-${inspection.id}',
                          child: heroImageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: heroImageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: Colors.grey[300]),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(LucideIcons.imageOff, color: Colors.grey),
                                  ),
                                )
                              : Container(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  child: const Icon(LucideIcons.image, size: 64, color: AppColors.primary),
                                ),
                        ),
                        // Gradient Overlay
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black],
                              stops: [0.3, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoGrid(context, inspection),
                    const SizedBox(height: AppSpacing.xl),
                    _buildAiAnalysisSection(context, inspection, isUpdating, isReevaluating),
                    const SizedBox(height: AppSpacing.xl),
                    if (inspection.media.isNotEmpty) ...[
                      _buildMediaSection(context, inspection),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    const Text(
                      'Linha do Tempo',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    StatusTimeline(
                      history: history.cast(),
                      currentStatus: inspection.status,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 8.0 + (_scrollOffset.clamp(0.0, 150.0) / 150.0) * 16.0,
          left: 16,
          child: const SafeArea(
            child: _GlassBackButton(),
          ),
        ),
      ],
    );
  }

  String _formatAddress(String? address) {
    if (address == null || address.trim().isEmpty) {
      return 'Endereço não disponível';
    }
    final parts = address.split(',').map((e) => e.trim()).toList();
    if (parts.length >= 2) {
      return '${parts[0]}, ${parts[1]}';
    }
    return address;
  }

  Widget _buildInfoGrid(BuildContext context, Inspection inspection) {
    final hasAddress = inspection.address != null && inspection.address!.trim().isNotEmpty;
    final displayAddress = hasAddress ? _formatAddress(inspection.address) : 'Endereço não disponível';
    
    final locationStr = displayAddress;

    return Column(
      children: [
        Row(
          children: [
            _buildInfoItem(
              context, 
              LucideIcons.mapPin, 
              'Localização', 
              locationStr,
            ),
            _buildInfoItem(
              context, 
              _getCategoryIcon(inspection.category), 
              'Categoria', 
              inspection.category,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            _buildInfoItem(
              context, 
              LucideIcons.calendar, 
              'Data', 
              DateFormat('dd/MM/yyyy').format(inspection.createdAt),
            ),
            _buildInfoItem(
              context, 
              LucideIcons.user, 
              'Inspetor', 
              inspection.inspector?.name ?? 'Não atribuído',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAnalysisSection(BuildContext context, Inspection inspection, bool isUpdating, bool isReevaluating) {
    if (inspection.media.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasAiResult = inspection.aiLabel != null && inspection.aiLabel != 'unknown';
    
    if (!hasAiResult) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.bot, color: AppColors.offline),
                SizedBox(width: 8),
                Text(
                  'Análise de Inteligência Artificial',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'A análise automática por IA não está disponível ou falhou (tempo limite excedido).',
              style: TextStyle(fontSize: 14, color: AppColors.subtextLight),
            ),
            if (!widget.readOnly && inspection.status != InspectionStatus.resolved && inspection.status != InspectionStatus.archived) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isUpdating || isReevaluating ? null : () => _showCorrectionDialog(context),
                      icon: const Icon(LucideIcons.edit3, size: 16),
                      label: const Text('Definir Manual'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isUpdating || isReevaluating ? null : () => context.read<InspectionDetailCubit>().reevaluateWithAi(),
                      icon: isReevaluating 
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(LucideIcons.refreshCcw, size: 16),
                      label: Text(isReevaluating ? 'Reavaliando...' : 'Reavaliar com IA'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    }

    final score = inspection.aiScore ?? 0.0;
    final color = _getScoreColor(score);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.bot, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Análise de Inteligência Artificial',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'A IA identificou: ${inspection.aiLabel}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: score,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(score * 100).toStringAsFixed(0)}%',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (inspection.humanLabel == null && !widget.readOnly && inspection.status != InspectionStatus.resolved && inspection.status != InspectionStatus.archived) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isUpdating || isReevaluating ? null : () => _showCorrectionDialog(context),
                    child: const Text('Corrigir'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isUpdating || isReevaluating ? null : () => context.read<InspectionDetailCubit>().confirmAiLabel(),
                    child: const Text('Confirmar'),
                  ),
                ),
              ],
            ),
          ] else if (inspection.humanLabel != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(LucideIcons.check, color: AppColors.success, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Confirmado como: ${inspection.humanLabel}',
                  style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context, Inspection inspection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mídias Registradas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: inspection.media.length,
          itemBuilder: (context, index) {
            final media = inspection.media[index];
            return GestureDetector(
              onTap: () {
                // TODO: Abrir viewer de imagem/vídeo
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: media.thumbnailUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(LucideIcons.imageOff, color: Colors.grey),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, Inspection inspection) {
    if (widget.readOnly || inspection.status == InspectionStatus.archived) {
      return const SizedBox.shrink();
    }

    final reportState = context.watch<ReportCubit>().state;
    final isGenerating = reportState.maybeWhen(loading: () => true, orElse: () => false);

    final isUpdating = context.watch<InspectionDetailCubit>().state.maybeMap(
      loaded: (s) => s.isUpdatingStatus,
      orElse: () => false,
    );

    final isOpen = inspection.status == InspectionStatus.open;
    final isInProgress = inspection.status == InspectionStatus.inProgress;
    final isResolved = inspection.status == InspectionStatus.resolved;

    if (isOpen) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isUpdating ? null : () => context.read<InspectionDetailCubit>().updateStatus(InspectionStatus.inProgress),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
              child: isUpdating
                  ? const SizedBox(
                      height: 20, width: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Iniciar Inspeção'),
            ),
          ),
        ),
      );
    }

    if (isInProgress) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isUpdating ? null : () => context.read<InspectionDetailCubit>().updateStatus(InspectionStatus.archived),
                      icon: const Icon(LucideIcons.archive, size: 16),
                      label: const Text('Arquivar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: isUpdating ? null : () {
                        if (inspection.media.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('RN-01: Adicione pelo menos uma foto antes de finalizar.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        context.read<InspectionDetailCubit>().updateStatus(InspectionStatus.resolved);
                      },
                      icon: const Icon(LucideIcons.checkCircle, size: 16),
                      label: const Text('Finalizar Inspeção'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: isGenerating ? null : () => context.read<ReportCubit>().generate(inspection.id),
                  icon: isGenerating 
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                      : const Icon(LucideIcons.fileText, size: 16),
                  label: const Text('Gerar Laudo Parcial'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isResolved) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isUpdating ? null : () => context.read<InspectionDetailCubit>().updateStatus(InspectionStatus.archived),
                      icon: const Icon(LucideIcons.archive, size: 16),
                      label: const Text('Arquivar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: isGenerating ? null : () => context.read<ReportCubit>().generate(inspection.id),
                      icon: isGenerating 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(LucideIcons.fileSpreadsheet, size: 16),
                      label: const Text('Gerar Laudo Técnico'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return AppColors.success;
    if (score >= 0.55) return AppColors.offline;
    return AppColors.error;
  }

  void _showCorrectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Corrigir Severidade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSeverityOption(dialogContext, context, 'CRÍTICA', InspectionSeverity.critical, AppColors.error),
            const SizedBox(height: 8),
            _buildSeverityOption(dialogContext, context, 'MODERADA', InspectionSeverity.moderate, AppColors.offline),
            const SizedBox(height: 8),
            _buildSeverityOption(dialogContext, context, 'BAIXA', InspectionSeverity.low),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityOption(
    BuildContext dialogContext, 
    BuildContext screenContext, 
    String label, 
    InspectionSeverity severity, 
    [Color? color]
  ) {
    final effectiveColor = color ?? AppColors.success;
    return ListTile(
      title: Text(label, style: TextStyle(color: effectiveColor, fontWeight: FontWeight.bold)),
      onTap: () {
        screenContext.read<InspectionDetailCubit>().correctAiLabel(severity);
        Navigator.pop(dialogContext);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tileColor: effectiveColor.withValues(alpha: 0.1),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'elétrica':
        return LucideIcons.zap;
      case 'civil':
        return LucideIcons.building;
      case 'hidráulica':
        return LucideIcons.droplets;
      case 'estrutural':
        return LucideIcons.construction;
      case 'incêndio':
        return LucideIcons.flame;
      default:
        return LucideIcons.clipboardList;
    }
  }
}

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
