import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/features/map/data/heatmap_point.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

class HeatmapLayer extends StatelessWidget {
  final List<HeatmapPoint> points;

  const HeatmapLayer({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    
    return MobileLayerTransformer(
      child: Opacity(
        opacity: 0.7,
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size(camera.size.x, camera.size.y),
            painter: _HeatmapPainter(camera: camera, points: points),
          ),
        ),
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final MapCamera camera;
  final List<HeatmapPoint> points;

  _HeatmapPainter({required this.camera, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    final renderPoints = points.take(200).toList();

    for (final point in renderPoints) {
      final latLng = LatLng(point.latitude, point.longitude);
      
      final offset = camera.getOffsetFromOrigin(latLng);

      if (offset.dx < -100 || offset.dx > size.width + 100 ||
          offset.dy < -100 || offset.dy > size.height + 100) {
        continue;
      }

      Color baseColor;
      switch (point.severity) {
        case InspectionSeverity.critical:
          baseColor = AppColors.criticalBg;
          break;
        case InspectionSeverity.moderate:
          baseColor = AppColors.moderateBg;
          break;
        case InspectionSeverity.low:
          baseColor = AppColors.lowBg;
          break;
        default:
          baseColor = AppColors.pendingBg;
      }

      final radius = 60.0 * point.weight;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            baseColor.withValues(alpha: 0.6),
            baseColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: offset, radius: radius))
        ..blendMode = BlendMode.screen;

      canvas.drawCircle(offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.camera != camera || oldDelegate.points != points;
  }
}
