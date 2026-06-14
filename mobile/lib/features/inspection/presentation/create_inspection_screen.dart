import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/core/di/service_locator.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_cubit.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_state.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/create_inspection_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/create_inspection_state.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';
import 'package:vistor_ai_mobile/shared/widgets/glass_card.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/widgets/media_picker_sheet.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/widgets/ai_result_card.dart';
import 'package:vistor_ai_mobile/shared/widgets/error_snackbar.dart';

class CreateInspectionScreen extends StatelessWidget {
  const CreateInspectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CreateInspectionCubit>(),
      child: const _CreateInspectionView(),
    );
  }
}

class _CreateInspectionView extends StatefulWidget {
  const _CreateInspectionView();

  @override
  State<_CreateInspectionView> createState() => _CreateInspectionViewState();
}

class _CreateInspectionViewState extends State<_CreateInspectionView> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nova Inspeção', 
          style: theme.textTheme.titleLarge?.copyWith(color: isDark ? Colors.white : AppColors.onBgLight),
        ),
        leading: BackButton(color: isDark ? Colors.white : AppColors.onBgLight),
      ),
      body: BlocListener<CreateInspectionCubit, CreateInspectionState>(
        listener: (context, state) {
          if (state.error != null) {
            showErrorSnackbar(context, state.error!);
          }
          if (state.isCompleted) {
            Navigator.pop(context);
          }
          // Sincroniza os controllers locais com os valores obtidos do GPS/Geocoding
          if (state.position != null) {
            final newLat = state.position!.latitude.toStringAsFixed(6);
            final newLon = state.position!.longitude.toStringAsFixed(6);
            if (_latController.text != newLat) {
              _latController.text = newLat;
            }
            if (_lonController.text != newLon) {
              _lonController.text = newLon;
            }
          }
          if (state.address.isNotEmpty && _addressController.text != state.address) {
            _addressController.text = state.address;
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicsSection(context),
              const SizedBox(height: AppSpacing.lg),
              BlocBuilder<CreateInspectionCubit, CreateInspectionState>(
                buildWhen: (prev, curr) => 
                  prev.isLoadingGps != curr.isLoadingGps || 
                  prev.position != curr.position || 
                  prev.address != curr.address,
                builder: (context, state) {
                  final cubit = context.read<CreateInspectionCubit>();
                  return _buildLocationSection(context, state, cubit);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              BlocBuilder<CreateInspectionCubit, CreateInspectionState>(
                buildWhen: (prev, curr) => prev.photos != curr.photos,
                builder: (context, state) {
                  final cubit = context.read<CreateInspectionCubit>();
                  return _buildPhotosSection(context, state, cubit);
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
              BlocBuilder<CreateInspectionCubit, CreateInspectionState>(
                buildWhen: (prev, curr) => 
                  prev.photos != curr.photos || 
                  prev.position != curr.position || 
                  prev.isSubmitting != curr.isSubmitting || 
                  prev.isUploadingMedia != curr.isUploadingMedia ||
                  prev.aiResultInspection != curr.aiResultInspection,
                builder: (context, state) {
                  final cubit = context.read<CreateInspectionCubit>();
                  final authState = context.read<AuthCubit>().state;
                  final String inspectorId = authState.maybeMap(
                    authenticated: (s) => s.user.id,
                    orElse: () => '',
                  );
                  return ElevatedButton(
                    onPressed: (state.photos.isEmpty || state.position == null || state.isSubmitting || state.aiResultInspection != null)
                        ? null
                        : () => cubit.submit(inspectorId),
                    child: state.isSubmitting
                        ? const SizedBox(
                            height: 20, width: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(state.isUploadingMedia ? 'Enviando mídias...' : 'Criar Inspeção em Campo'),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              BlocBuilder<CreateInspectionCubit, CreateInspectionState>(
                buildWhen: (prev, curr) => prev.aiResultInspection != curr.aiResultInspection,
                builder: (context, state) {
                  if (state.aiResultInspection == null) return const SizedBox.shrink();
                  final cubit = context.read<CreateInspectionCubit>();
                  return Column(
                    children: [
                      AiResultCard(
                        label: state.aiResultInspection!.aiLabel ?? 'Processando...',
                        confidence: state.aiResultInspection!.aiScore ?? 0.0,
                        severity: state.aiResultInspection!.severity,
                        onConfirm: () => cubit.confirmAiLabel(state.aiResultInspection!.id),
                        onCorrect: () => _showCorrectionDialog(context, cubit, state.aiResultInspection!.id),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicsSection(BuildContext context) {
    final cubit = context.read<CreateInspectionCubit>();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informações Básicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppSpacing.md),
          const Text('Título', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _titleController,
            onChanged: (v) => cubit.updateTitle(v),
            decoration: const InputDecoration(hintText: 'Ex: Fissura em viga'),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Categoria', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            items: ['Elétrica', 'Civil', 'Hidráulica', 'Estrutural', 'Incêndio', 'Outro']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => cubit.updateCategory(v ?? ''),
            decoration: const InputDecoration(hintText: 'Selecione a categoria'),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Observações', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _descController,
            maxLines: 3,
            onChanged: (v) => cubit.updateDescription(v),
            decoration: const InputDecoration(hintText: 'Descreva os detalhes da ocorrência'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, CreateInspectionState state, CreateInspectionCubit cubit) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Localização', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (state.isLoadingGps)
                ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.5).animate(_pulseController),
                  child: Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LATITUDE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.subtextLight)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _latController,
                      readOnly: true,
                      style: const TextStyle(color: Colors.grey),
                      decoration: const InputDecoration(
                        hintText: '---',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LONGITUDE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.subtextLight)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _lonController,
                      readOnly: true,
                      style: const TextStyle(color: Colors.grey),
                      decoration: const InputDecoration(
                        hintText: '---',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Endereço Aproximado', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.subtextLight)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _addressController,
            readOnly: true,
            style: const TextStyle(color: Colors.grey),
            decoration: const InputDecoration(
              hintText: 'Endereço aproximado obtido',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state.isLoadingGps ? null : () => _onCaptureGps(context, cubit),
                  icon: const Icon(LucideIcons.mapPin, size: 16),
                  label: Text(state.isLoadingGps ? 'Aguarde...' : 'Via GPS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state.isLoadingGps ? null : () => _showManualLocationDialog(context, cubit),
                  icon: const Icon(LucideIcons.edit3, size: 16),
                  label: const Text('Manual'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showManualLocationDialog(BuildContext context, CreateInspectionCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => _ManualLocationDialog(cubit: cubit),
    );
  }

  Future<void> _onCaptureGps(BuildContext context, CreateInspectionCubit cubit) async {
    await cubit.captureGps();
    if (!cubit.isAccuracyAcceptable() && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Baixa Precisão GPS'),
          content: Text(
            'A precisão do GPS está em ${cubit.state.position?.accuracy.toStringAsFixed(1)}m. '
            'RN-08: Recomenda-se precisão abaixo de 50m para maior fidelidade.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }



  Widget _buildPhotosSection(BuildContext context, CreateInspectionState state, CreateInspectionCubit cubit) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Registros Fotográficos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                child: Text('${state.photos.length} fotos', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.photos.isEmpty)
            GestureDetector(
              onTap: () => _showMediaPicker(context, cubit),
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                color: AppColors.subtextLight,
                dashPattern: const [6, 4],
                child: const SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.camera, color: AppColors.subtextLight),
                      SizedBox(height: 8),
                      Text('Tocar para adicionar mídia', style: TextStyle(color: AppColors.subtextLight, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: state.photos.length + 1,
              itemBuilder: (context, index) {
                if (index == state.photos.length) {
                  return GestureDetector(
                    onTap: () => _showMediaPicker(context, cubit),
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(8),
                      color: AppColors.subtextLight,
                      child: const Center(child: Icon(LucideIcons.plus, color: AppColors.subtextLight)),
                    ),
                  );
                }
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(state.photos[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    ),
                    Positioned(
                      top: 4, right: 4,
                      child: GestureDetector(
                        onTap: () => cubit.removePhoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void _showMediaPicker(BuildContext context, CreateInspectionCubit cubit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MediaPickerSheet(onMediaSelected: (file) => cubit.addPhoto(file)),
    );
  }

  void _showCorrectionDialog(BuildContext context, CreateInspectionCubit cubit, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Definir Severidade Técnica'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('A IA não teve certeza. Escolha o nível de risco real:'),
            const SizedBox(height: 16),
            _buildSeverityOption(
              context, 
              label: 'CRÍTICA', 
              color: AppColors.criticalBg, 
              onTap: () {
                cubit.correctAiLabel(id, InspectionSeverity.critical);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _buildSeverityOption(
              context, 
              label: 'MODERADA', 
              color: AppColors.moderateBg, 
              onTap: () {
                cubit.correctAiLabel(id, InspectionSeverity.moderate);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _buildSeverityOption(
              context, 
              label: 'BAIXA', 
              color: AppColors.lowBg, 
              onTap: () {
                cubit.correctAiLabel(id, InspectionSeverity.low);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ],
      ),
    );
  }

  Widget _buildSeverityOption(BuildContext context, {required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ManualLocationDialog extends StatefulWidget {
  final CreateInspectionCubit cubit;

  const _ManualLocationDialog({required this.cubit});

  @override
  State<_ManualLocationDialog> createState() => _ManualLocationDialogState();
}

class _ManualLocationDialogState extends State<_ManualLocationDialog> {
  final TextEditingController _inputController = TextEditingController();
  List<LocationSuggestion> _suggestions = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _suggestions = [];
    });

    try {
      Position? currentPos = widget.cubit.state.position;
      if (currentPos == null) {
        try {
          currentPos = await Geolocator.getLastKnownPosition();
        } catch (_) {}
      }

      String? currentCity;
      String? currentState;

      if (currentPos != null) {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            currentPos.latitude,
            currentPos.longitude,
          );
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            currentCity = p.subAdministrativeArea ?? p.locality;
            currentState = p.administrativeArea;
          }
        } catch (_) {}
      }

      List<Location> locations = [];

      if (currentCity != null || currentState != null) {
        final List<String> biasParts = [
          query,
          if (currentCity != null) currentCity,
          if (currentState != null) currentState,
        ];
        final biasedQuery = biasParts.join(', ');
        try {
          locations = await locationFromAddress(biasedQuery);
        } catch (_) {}
      }

      if (locations.isEmpty) {
        locations = await locationFromAddress(query);
      }

      if (locations.isEmpty) {
        setState(() {
          _errorMessage = 'Nenhum local encontrado para esta busca.';
          _isLoading = false;
        });
        return;
      }

      if (currentPos != null && locations.length > 1) {
        locations.sort((a, b) {
          final distA = Geolocator.distanceBetween(
            currentPos!.latitude,
            currentPos.longitude,
            a.latitude,
            a.longitude,
          );
          final distB = Geolocator.distanceBetween(
            currentPos.latitude,
            currentPos.longitude,
            b.latitude,
            b.longitude,
          );
          return distA.compareTo(distB);
        });
      }

      final candidates = locations.take(4).toList();
      final List<LocationSuggestion> list = [];

      for (var loc in candidates) {
        String displayName = query;
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            final parts = [
              if (p.street != null && p.street!.isNotEmpty) p.street,
              if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality,
              if (p.subAdministrativeArea != null && p.subAdministrativeArea!.isNotEmpty) p.subAdministrativeArea,
              if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) p.administrativeArea,
            ];
            if (parts.isNotEmpty) {
              displayName = parts.join(', ');
            }
          }
        } catch (_) {}

        double? distKm;
        if (currentPos != null) {
          final m = Geolocator.distanceBetween(
            currentPos.latitude,
            currentPos.longitude,
            loc.latitude,
            loc.longitude,
          );
          distKm = m / 1000.0;
        }

        list.add(LocationSuggestion(
          latitude: loc.latitude,
          longitude: loc.longitude,
          address: displayName,
          distanceKm: distKm,
        ));
      }

      setState(() {
        _suggestions = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao buscar localização: ${e.toString().contains('Service not Available') ? 'Serviço geocoding indisponível' : 'Erro de rede ou conexão'}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Inserir Localização Manualmente'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Digite o local (Ex: UERN Natal) e clique em Buscar:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Digite o endereço...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (v) => _searchAddress(v.trim()),
                    autofocus: true,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isLoading ? null : () => _searchAddress(_inputController.text.trim()),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    if (_inputController.text.trim().isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () {
                          final fallbackPos = widget.cubit.state.position ?? Position(
                            latitude: -5.79448,
                            longitude: -35.2110,
                            timestamp: DateTime.now(),
                            accuracy: 15.0,
                            altitude: 0.0,
                            altitudeAccuracy: 0.0,
                            heading: 0.0,
                            headingAccuracy: 0.0,
                            speed: 0.0,
                            speedAccuracy: 0.0,
                          );
                          widget.cubit.updateLatitude(fallbackPos.latitude);
                          widget.cubit.updateLongitude(fallbackPos.longitude);
                          widget.cubit.updateAddress(_inputController.text.trim());
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Usar endereço digitado mesmo assim'),
                      ),
                  ],
                ),
              )
            else if (_suggestions.isNotEmpty)
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _suggestions[index];
                      return ListTile(
                        dense: true,
                        title: Text(item.address, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text(
                          'Lat: ${item.latitude.toStringAsFixed(6)}, Lon: ${item.longitude.toStringAsFixed(6)}${item.distanceKm != null ? ' (${item.distanceKm!.toStringAsFixed(1)} km)' : ''}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        onTap: () {
                          widget.cubit.updateLatitude(item.latitude);
                          widget.cubit.updateLongitude(item.longitude);
                          widget.cubit.updateAddress(item.address);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class LocationSuggestion {
  final double latitude;
  final double longitude;
  final String address;
  final double? distanceKm;

  LocationSuggestion({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.distanceKm,
  });
}
