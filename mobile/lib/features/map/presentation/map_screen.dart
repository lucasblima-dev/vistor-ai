import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/features/map/domain/map_cubit.dart';
import 'package:vistor_ai_mobile/features/map/domain/map_data.dart';
import 'package:vistor_ai_mobile/features/map/domain/map_state.dart';
import 'package:vistor_ai_mobile/features/map/presentation/widgets/heatmap_layer.dart';
import 'package:vistor_ai_mobile/features/map/presentation/widgets/inspection_marker.dart';
import 'package:vistor_ai_mobile/features/map/presentation/widgets/map_filter_sheet.dart';
import 'package:vistor_ai_mobile/features/map/presentation/widgets/nearby_card.dart';
import 'package:vistor_ai_mobile/core/utils/env.dart';
import 'package:vistor_ai_mobile/shared/widgets/error_state.dart';
import 'package:vistor_ai_mobile/shared/widgets/loading_state.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  LatLng? _userLocation;
  bool _hasCenteredOnUser = false;

  @override
  void initState() {
    super.initState();
    _initLocationAndLoad();
  }

  Future<void> _initLocationAndLoad() async {
    LatLng? location;
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 4),
      );
      location = LatLng(position.latitude, position.longitude);
    } catch (_) {
      // Ignora erro de GPS e mantém location nulo para fallback
    }

    if (mounted) {
      setState(() {
        _userLocation = location;
      });

      // Carrega o mapa com a localização real obtida (ou fallback interno do Cubit)
      context.read<MapCubit>().loadMap(
        lat: location?.latitude,
        lon: location?.longitude,
      );

      // Tenta centrar no mapa se o controller já estiver pronto
      if (location != null && !_hasCenteredOnUser) {
        try {
          _mapController.move(location, 13);
          _hasCenteredOnUser = true;
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const AppLoadingState(message: 'Carregando mapa...'),
            error: (msg) => AppErrorState(
              message: msg,
              onRetry: () => context.read<MapCubit>().loadMap(),
            ),
            loaded: (data) => _buildMapStack(context, data),
          );
        },
      ),
    );
  }

  Widget _buildMapStack(BuildContext context, MapData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Definimos o centro inicial do mapa:
    // 1. Localização atual do usuário identificada pelo GPS
    // 2. Se não houver, a primeira inspeção na lista
    // 3. Fallback final: Natal
    final center = _userLocation ?? (data.inspections.isNotEmpty 
        ? LatLng(data.inspections.first.lat, data.inspections.first.lon)
        : const LatLng(-5.79448, -35.2110));

    final markers = data.inspections.map((insp) {
      return Marker(
        point: LatLng(insp.lat, insp.lon),
        width: 32,
        height: 32,
        child: InspectionMarker(inspection: insp),
      );
    }).toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13,
            maxZoom: 18,
            minZoom: 3,
            onMapReady: () {
              if (_userLocation != null && !_hasCenteredOnUser) {
                _mapController.move(_userLocation!, 13);
                _hasCenteredOnUser = true;
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: '${Env.apiBaseUrl}/api/geo/tiles/{z}/{x}/{y}.png',
            ),
            if (data.activeLayer == MapActiveLayer.markers || 
                data.activeLayer == MapActiveLayer.both)
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  markers: markers,
                  builder: (context, clusterMarkers) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.primary.withValues(alpha:0.8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          clusterMarkers.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (data.activeLayer == MapActiveLayer.heatmap || 
                data.activeLayer == MapActiveLayer.both)
              HeatmapLayer(points: data.heatmapPoints),
          ],
        ),

        // Controles de Topo
        _buildTopControls(context),

        // Controles Laterais (Zoom, Layers)
        _buildSideControls(context, data),

        // Lista de Inspeções Próximas
        _buildNearbySheet(context, data),
      ],
    );
  }

  Widget _buildTopControls(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: AppSpacing.screenH,
      right: AppSpacing.screenH,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterPill(context),
          const SizedBox(width: 16),
          // Espaço para alinhar com os botões laterais se necessário
        ],
      ),
    );
  }

  Widget _buildFilterPill(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.7),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withValues(alpha:0.3)),
            boxShadow: const [AppShadows.card],
          ),
          child: InkWell(
            onTap: () => _showFilterSheet(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.sliders, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Filtrar Mapa',
                  style: TextStyle(
                    color: AppColors.primaryDeep,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSideControls(BuildContext context, MapData data) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      right: AppSpacing.screenH,
      child: Column(
        children: [
          _buildControlButton(
            icon: LucideIcons.plus,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
          ),
          const SizedBox(height: 12),
          _buildControlButton(
            icon: LucideIcons.minus,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
          ),
          const SizedBox(height: 12),
          _buildControlButton(
            icon: data.activeLayer == MapActiveLayer.heatmap 
                ? LucideIcons.layers 
                : LucideIcons.map,
            onTap: () => context.read<MapCubit>().toggleLayer(),
            active: data.activeLayer != MapActiveLayer.markers,
          ),
          const SizedBox(height: 12),
          _buildControlButton(
            icon: LucideIcons.navigation,
            onTap: _initLocationAndLoad,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Theme.of(context).cardColor,
        shape: BoxShape.circle,
        boxShadow: const [AppShadows.card],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            size: 20,
            color: active 
                ? Colors.white 
                : (isDark ? Colors.white : AppColors.primaryDeep),
          ),
        ),
      ),
    );
  }

  Widget _buildNearbySheet(BuildContext context, MapData data) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.28,
      minChildSize: 0.15,
      maxChildSize: 0.55,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle Bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.subtextLight.withValues(alpha:0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Inspeções ao seu redor',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data.inspections.length.toString(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                data.inspections.isEmpty 
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Nenhuma inspeção próxima encontrada.'),
                    ))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg, bottom: 20),
                      itemCount: data.inspections.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: NearbyCard(inspection: data.inspections[index]),
                        );
                      },
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MapFilterSheet(),
    );
  }
}
