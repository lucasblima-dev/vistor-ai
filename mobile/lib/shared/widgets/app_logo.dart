import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: AppGradients.premium,
        borderRadius: BorderRadius.circular(AppRadius.logo),
        boxShadow: const [AppShadows.cardMd],
      ),
      child: Stack(children: [
        Center(child: Icon(LucideIcons.mapPin, color: Colors.white, size: size * 0.45)),
        Positioned(
          top: size * 0.10, right: size * 0.10,
          child: Icon(LucideIcons.sparkles, color: AppColors.gold, size: size * 0.24),
        ),
      ]),
    );
  }
}
