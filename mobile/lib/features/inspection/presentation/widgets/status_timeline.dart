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
                    children: [                      _buildActionTitleWidget(context, log, isCurrent),
                      const SizedBox(height: 4),
                      Text(
                        'Por: ${_formatAuthor(log)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.subtextLight),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(log.createdAt.toLocal()),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? AppColors.outlineDark : AppColors.outlineLight;

    return SizedBox(
      width: 24,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: 2,
              color: isFirst ? Colors.transparent : lineColor,
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
              color: isLast ? Colors.transparent : lineColor,
            ),
          ),
        ],
      ),
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
    if (action == 'ai_classified') return Colors.purple;
    if (action == 'delete') return AppColors.error;
    
    return isCurrent ? AppColors.primary : AppColors.subtextLight.withValues(alpha: 0.5);
  }

  String _translateStatus(String status) {
    final s = status.toLowerCase().trim();
    if (s == 'open') return 'Pendente';
    if (s == 'in_progress' || s == 'inprogress') return 'Em Andamento';
    if (s == 'resolved') return 'Resolvido';
    if (s == 'archived') return 'Arquivado';
    return status;
  }

  String _translateSeverity(String severity) {
    final s = severity.toLowerCase().trim();
    if (s == 'critical') return 'Crítica';
    if (s == 'moderate') return 'Moderada';
    if (s == 'low') return 'Baixa';
    if (s == 'pending_review' || s == 'pending') return 'Pendente de Revisão';
    return severity;
  }

  Color _getStatusTextColor(BuildContext context, String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = status.toLowerCase().trim();
    if (s == 'resolved' || s == 'resolvido') {
      return isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
    }
    if (s == 'in_progress' || s == 'inprogress' || s == 'em andamento') {
      return isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
    }
    if (s == 'open' || s == 'pendente') {
      return isDark ? AppColors.primaryDark : AppColors.primary;
    }
    if (s == 'archived' || s == 'arquivado') {
      return isDark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE);
    }
    return isDark ? AppColors.onSurfDark : AppColors.onSurfLight;
  }

  Color _getSeverityTextColor(BuildContext context, String severity) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = severity.toLowerCase().trim();
    if (s == 'critical' || s == 'crítica') {
      return isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    }
    if (s == 'moderate' || s == 'moderada') {
      return isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
    }
    if (s == 'low' || s == 'baixa') {
      return isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
    }
    if (s == 'pending_review' || s == 'pending' || s == 'pendente de revisão') {
      return isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
    }
    return isDark ? AppColors.onSurfDark : AppColors.onSurfLight;
  }

  String _formatAuthor(AuditLog log) {
    if (log.action == 'ai_classified') {
      return 'Inteligência Artificial';
    }
    if (log.userName != null && log.userName!.trim().isNotEmpty) {
      return log.userName!;
    }
    if (log.userId != null && log.userId!.trim().isNotEmpty) {
      if (log.userId!.length > 8) {
        return 'Usuário (${log.userId!.substring(0, 8)})';
      }
      return log.userId!;
    }
    return 'Sistema';
  }

  Widget _buildActionTitleWidget(BuildContext context, AuditLog log, bool isCurrent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: isCurrent 
          ? (isDark ? AppColors.primaryDark : AppColors.primary) 
          : (isDark ? AppColors.onSurfDark : AppColors.onSurfLight),
    );

    switch (log.action) {
      case 'create':
        return Text('Inspeção Criada', style: defaultStyle);
      
      case 'ai_classified':
        final label = log.newValue?['ai_label'] ?? 'Não identificado';
        final translatedLabel = _translateSeverity(label.toString());
        final score = log.newValue?['ai_score'] != null 
            ? ' (${((log.newValue?['ai_score'] as num) * 100).toStringAsFixed(0)}%)'
            : '';
            
        return Text.rich(
          TextSpan(
            text: 'IA Classificou: ',
            style: defaultStyle,
            children: [
              TextSpan(
                text: translatedLabel,
                style: defaultStyle.copyWith(
                  color: _getSeverityTextColor(context, label.toString()),
                ),
              ),
              TextSpan(text: score, style: defaultStyle),
            ],
          ),
        );
        
      case 'update':
        final status = log.newValue?['status'];
        final severity = log.newValue?['severity'];
        final humanLabel = log.newValue?['human_label'];

        if (status != null && severity != null) {
          final transStatus = _translateStatus(status.toString());
          final transSev = _translateSeverity(severity.toString());
          return Text.rich(
            TextSpan(
              text: 'Status: ',
              style: defaultStyle,
              children: [
                TextSpan(
                  text: transStatus,
                  style: defaultStyle.copyWith(color: _getStatusTextColor(context, status.toString())),
                ),
                const TextSpan(text: ' & Severidade: '),
                TextSpan(
                  text: transSev,
                  style: defaultStyle.copyWith(color: _getSeverityTextColor(context, severity.toString())),
                ),
              ],
            ),
          );
        }
        if (status != null) {
          final transStatus = _translateStatus(status.toString());
          return Text.rich(
            TextSpan(
              text: 'Status alterado para ',
              style: defaultStyle,
              children: [
                TextSpan(
                  text: transStatus,
                  style: defaultStyle.copyWith(color: _getStatusTextColor(context, status.toString())),
                ),
              ],
            ),
          );
        }
        if (severity != null) {
          final transSev = _translateSeverity(severity.toString());
          return Text.rich(
            TextSpan(
              text: 'Severidade alterada para ',
              style: defaultStyle,
              children: [
                TextSpan(
                  text: transSev,
                  style: defaultStyle.copyWith(color: _getSeverityTextColor(context, severity.toString())),
                ),
              ],
            ),
          );
        }
        if (humanLabel != null) {
          final transSev = _translateSeverity(humanLabel.toString());
          return Text.rich(
            TextSpan(
              text: 'Classificação confirmada: ',
              style: defaultStyle,
              children: [
                TextSpan(
                  text: transSev,
                  style: defaultStyle.copyWith(color: _getSeverityTextColor(context, humanLabel.toString())),
                ),
              ],
            ),
          );
        }
        return Text('Dados atualizados', style: defaultStyle);
        
      case 'delete':
        return Text(
          'Inspeção Excluída',
          style: defaultStyle.copyWith(color: AppColors.error),
        );
        
      default:
        return Text('Ação: ${log.action}', style: defaultStyle);
    }
  }
}
