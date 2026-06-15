import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

class GradientProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final BorderRadius borderRadius;

  const GradientProgressBar({
    super.key,
    required this.value,
    this.height = 10.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6.0)),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : const Color(0xFFF3F4F6),
        borderRadius: borderRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * value.clamp(0.0, 1.0);
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF3B82F6), // Blue
                    Color(0xFF8B5CF6), // Purple
                  ],
                ),
                borderRadius: borderRadius,
              ),
            ),
          );
        },
      ),
    );
  }
}

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

    // 1. Dynamic color mappings for the severity badge
    Color badgeBgColor;
    Color badgeTextColor;
    String badgeLabel;

    switch (severity) {
      case InspectionSeverity.critical:
        badgeBgColor = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
        badgeTextColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B);
        badgeLabel = 'CRÍTICO';
        break;
      case InspectionSeverity.moderate:
        badgeBgColor = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        badgeTextColor = isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E);
        badgeLabel = 'ATENÇÃO';
        break;
      case InspectionSeverity.low:
        badgeBgColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
        badgeTextColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46);
        badgeLabel = 'NORMAL';
        break;
      case InspectionSeverity.pendingReview:
      default:
        badgeBgColor = isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);
        badgeTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
        badgeLabel = 'PENDENTE';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVarDark : AppColors.accentLight,
        border: const Border(
          left: BorderSide(color: AppColors.secondary, width: 4),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Header: Icon Container + Title + Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF4F46E5) : const Color(0xFF6366F1), // Vibrant Indigo background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.sparkles,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Análise da IA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              if (severity != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Body: AI Label + Confidence on the same row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Confiança: ${(confidence * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8B5CF6), // Purple color from the progress bar
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4. Progress Bar: Thick gradient line
          GradientProgressBar(
            value: confidence,
            height: 12.0,
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
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
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
}
