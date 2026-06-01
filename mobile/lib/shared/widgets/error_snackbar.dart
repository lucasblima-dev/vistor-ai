import 'package:flutter/material.dart';
import 'package:vistor_ai_mobile/app/theme.dart';

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.error_outline, color: Colors.white, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(message,
        style: const TextStyle(color: Colors.white, fontFamily: 'Inter'))),
    ]),
    backgroundColor: AppColors.error,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.input)),
    margin: const EdgeInsets.all(AppSpacing.md),
    duration: const Duration(seconds: 4),
  ));
}

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(message,
        style: const TextStyle(color: Colors.white, fontFamily: 'Inter'))),
    ]),
    backgroundColor: AppColors.success,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.input)),
    margin: const EdgeInsets.all(AppSpacing.md),
    duration: const Duration(seconds: 3),
  ));
}
