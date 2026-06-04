import 'package:flutter/material.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

class AiResultCard extends StatelessWidget {
  final String label;
  final double confidence;
  final InspectionSeverity? severity;
  final VoidCallback onConfirm;
  final VoidCallback onCorrect;

  const AiResultCard({
    super.key,
    required this.label,
    required this.confidence,
    this.severity,
    required this.onConfirm,
    required this.onCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLowConfidence = confidence < 0.55;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVarDark : AppColors.accentLight,
        border: const Border(
          left: BorderSide(color: AppColors.secondary, width: 4),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 20, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text(
                    isLowConfidence ? 'Classificação incerta' : 'Classificação IA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              if (severity != null) _buildSeverityBadge(severity!),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.onSurfLight,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: confidence,
            backgroundColor: isDark ? Colors.black26 : Colors.white,
            color: isLowConfidence ? Colors.orange : AppColors.secondary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Text(
            '${(confidence * 100).toStringAsFixed(0)}% de confiança',
            style: TextStyle(
              fontSize: 12, 
              color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
            ),
          ),
          if (isLowConfidence) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Confiança baixa. Por favor, corrija a classificação manualmente.',
                      style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCorrect,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.secondary),
                    foregroundColor: AppColors.secondary,
                  ),
                  child: const Text('Corrigir'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLowConfidence ? null : onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityBadge(InspectionSeverity severity) {
    Color color;
    String label;

    switch (severity) {
      case InspectionSeverity.critical:
        color = AppColors.criticalBg;
        label = 'CRÍTICA';
        break;
      case InspectionSeverity.moderate:
        color = AppColors.moderateBg;
        label = 'MODERADA';
        break;
      case InspectionSeverity.low:
        color = AppColors.lowBg;
        label = 'BAIXA';
        break;
      case InspectionSeverity.pendingReview:
        color = AppColors.pendingBg;
        label = 'PENDENTE';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: severity == InspectionSeverity.pendingReview ? AppColors.pendingFg : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
