import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/features/map/domain/map_cubit.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/widgets/severity_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class InspectionMarker extends StatelessWidget {
  final Inspection inspection;

  const InspectionMarker({super.key, required this.inspection});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (inspection.severity) {
      case InspectionSeverity.critical:
        color = AppColors.criticalBg;
        break;
      case InspectionSeverity.moderate:
        color = AppColors.moderateBg;
        break;
      case InspectionSeverity.low:
        color = AppColors.lowBg;
        break;
      default:
        color = AppColors.pendingBg;
    }

    return GestureDetector(
      onTap: () => _showPopup(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            LucideIcons.mapPin,
            color: color,
            size: 32,
          ),
          Positioned(
            top: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Material(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.card),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (inspection.media.isNotEmpty && inspection.media.first.thumbnailUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: inspection.media.first.thumbnailUrl!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.surfaceVarLight,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    inspection.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  SeverityBadge(severity: inspection.severity ?? InspectionSeverity.low),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop();
                        context.push('/inspections/${inspection.id}').then((_) {
                          // ignore: use_build_context_synchronously
                          if (context.mounted) {
                            context.read<MapCubit>().loadMap();
                          }
                        });
                      },
                      child: const Text('Ver detalhes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
