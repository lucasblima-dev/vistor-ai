import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/shared/models/audit_log.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

class StatusTimeline extends StatelessWidget {
  final List<AuditLog> history;
  final InspectionStatus currentStatus;

  const StatusTimeline({
    super.key,
    required this.history,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text('Nenhum histórico registrado.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final log = history[index];
        final isLast = index == history.length - 1;
        final isFirst = index == 0;
        
        final bool isCurrent = _isLogCurrentStatus(log);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTimelineIndicator(context, isFirst, isLast, isCurrent, log.action),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatActionTitle(log),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isCurrent ? AppColors.primary : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Por: ${log.userName ?? log.userId ?? "Sistema"}',
                        style: const TextStyle(fontSize: 12, color: AppColors.subtextLight),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(log.createdAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.subtextLight),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineIndicator(
    BuildContext context, 
    bool isFirst, 
    bool isLast, 
    bool isCurrent,
    String action,
  ) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 2,
            color: isFirst ? Colors.transparent : AppColors.outlineLight,
          ),
        ),
        Container(
          width: isCurrent ? 14 : 10,
          height: isCurrent ? 14 : 10,
          decoration: BoxDecoration(
            color: _getStatusColor(action, isCurrent),
            shape: BoxShape.circle,
            border: isCurrent 
              ? Border.all(color: _getStatusColor(action, isCurrent).withValues(alpha: 0.3), width: 4)
              : null,
          ),
        ),
        Expanded(
          child: Container(
            width: 2,
            color: isLast ? Colors.transparent : AppColors.outlineLight,
          ),
        ),
      ],
    );
  }

  bool _isLogCurrentStatus(AuditLog log) {
    if (log.action != 'update') return false;
    final newValue = log.newValue;
    if (newValue == null) return false;
    return newValue['status'] == currentStatus.name;
  }

  Color _getStatusColor(String action, bool isCurrent) {
    if (action == 'create') return AppColors.primary;
    if (action == 'delete') return AppColors.error;
    
    return isCurrent ? AppColors.primary : AppColors.subtextLight.withValues(alpha: 0.5);
  }

  String _formatActionTitle(AuditLog log) {
    switch (log.action) {
      case 'create':
        return 'Inspeção Criada';
      case 'update':
        final status = log.newValue?['status'];
        if (status != null) {
          return 'Status alterado para ${status.toString().toUpperCase()}';
        }
        return 'Dados atualizados';
      case 'delete':
        return 'Inspeção Excluída';
      default:
        return 'Ação: ${log.action}';
    }
  }
}
