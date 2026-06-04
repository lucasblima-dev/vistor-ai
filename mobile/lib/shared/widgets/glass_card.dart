import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vistor_ai_mobile/app/theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark 
              ? AppColors.glassWhite 
              : Colors.white.withValues(alpha: 0.80),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isDark 
                ? AppColors.glassBorder 
                : Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
