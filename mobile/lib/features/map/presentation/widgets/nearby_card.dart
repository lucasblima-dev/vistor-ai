import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/features/map/domain/map_cubit.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';
import 'package:go_router/go_router.dart';

class NearbyCard extends StatelessWidget {
  final Inspection inspection;

  const NearbyCard({super.key, required this.inspection});

  @override
  Widget build(BuildContext context) {
    Color severityColor;
    switch (inspection.severity) {
      case InspectionSeverity.critical:
        severityColor = AppColors.criticalBg;
        break;
      case InspectionSeverity.moderate:
        severityColor = AppColors.moderateBg;
        break;
      case InspectionSeverity.low:
        severityColor = AppColors.lowBg;
        break;
      default:
        severityColor = AppColors.pendingBg;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppShadows.card],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/inspections/${inspection.id}').then((_) {
            if (context.mounted) {
              context.read<MapCubit>().loadMap();
            }
          }),
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        inspection.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: AppColors.subtextLight),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              (inspection.address?.isNotEmpty == true)
                                  ? inspection.address!
                                  : 'Lat: ${inspection.lat.toStringAsFixed(4)}, Lon: ${inspection.lon.toStringAsFixed(4)}',
                              style: const TextStyle(color: AppColors.subtextLight, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
