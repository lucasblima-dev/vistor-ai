import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';

class MediaPickerSheet extends StatelessWidget {
  final Function(File) onMediaSelected;

  const MediaPickerSheet({
    super.key,
    required this.onMediaSelected,
  });

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 100,
    );

    if (image != null) {
      onMediaSelected(File(image.path));
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.subtextLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildOption(
            context,
            icon: LucideIcons.camera,
            label: 'Câmera',
            onTap: () => _pickImage(ImageSource.camera, context),
          ),
          _buildOption(
            context,
            icon: LucideIcons.image,
            label: 'Galeria',
            onTap: () => _pickImage(ImageSource.gallery, context),
          ),
          _buildOption(
            context,
            icon: LucideIcons.fileText,
            label: 'Documento',
            onTap: () {
              // TODO: Implementar seleção de documento se necessário
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: onTap,
    );
  }
}
