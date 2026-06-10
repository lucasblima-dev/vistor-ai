import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/router.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/widgets/severity_badge.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';
import 'package:intl/intl.dart';

class _StatusIndicator extends StatelessWidget {
  final InspectionStatus status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (status) {
      case InspectionStatus.open:
        color = Colors.blue;
        icon = LucideIcons.circle;
        break;
      case InspectionStatus.inProgress:
        color = Colors.orange;
        icon = LucideIcons.playCircle;
        break;
      case InspectionStatus.resolved:
        color = Colors.green;
        icon = LucideIcons.checkCircle2;
        break;
      case InspectionStatus.archived:
        color = Colors.grey;
        icon = LucideIcons.archive;
        break;
      default:
        color = Colors.grey;
        icon = LucideIcons.helpCircle;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class InspectionCard extends StatefulWidget {
  final Inspection inspection;
  final VoidCallback? onTap;

  const InspectionCard({
    super.key,
    required this.inspection,
    this.onTap,
  });

  @override
  State<InspectionCard> createState() => _InspectionCardState();
}

class _InspectionCardState extends State<InspectionCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('dd MMM yyyy, HH:mm', 'pt_BR').format(widget.inspection.createdAt.toLocal());
    
    String? thumbnailUrl;
    if (widget.inspection.media.isNotEmpty) {
      for (var m in widget.inspection.media) {
        if (m.thumbnailUrl != null) {
          thumbnailUrl = m.thumbnailUrl;
          break;
        }
      }
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () async {
        await context.push(AppRoutes.inspection(widget.inspection.id));
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Hero(
                tag: 'inspection-${widget.inspection.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    child: thumbnailUrl != null
                      ? Image.network(
                          thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            _getCategoryIcon(widget.inspection.category),
                            color: theme.primaryColor,
                            size: 28,
                          ),
                        )
                      : Icon(
                          _getCategoryIcon(widget.inspection.category),
                          color: theme.primaryColor,
                          size: 28,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.inspection.category.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.inspection.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.inspection.description ?? 'Sem descrição',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.inspection.address ?? 
                            '${widget.inspection.lat.toStringAsFixed(4)}, ${widget.inspection.lon.toStringAsFixed(4)}',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              
              SeverityBadge(severity: widget.inspection.severity),
              const SizedBox(width: 8),
              if (!widget.inspection.isSynced) ...[
                const Tooltip(
                  message: 'Pendente de sincronização',
                  child: Icon(
                    LucideIcons.cloudOff,
                    color: AppColors.offline,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              _StatusIndicator(status: widget.inspection.status),
            ],
          ),
        ),
      ),
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
