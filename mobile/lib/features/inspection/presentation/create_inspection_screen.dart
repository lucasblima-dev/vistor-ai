import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dotted_border/dotted_border.dart';
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
      body: BlocConsumer<CreateInspectionCubit, CreateInspectionState>(
        listener: (context, state) {
          if (state.error != null) {
            showErrorSnackbar(context, state.error!);
          }
          if (state.isCompleted) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final cubit = context.read<CreateInspectionCubit>();
          final authState = context.read<AuthCubit>().state;
          final String inspectorId = authState.maybeMap(
            authenticated: (s) => s.user.id,
            orElse: () => '',
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.aiResultInspection != null) ...[
                  AiResultCard(
                    label: state.aiResultInspection!.aiLabel ?? 'Processando...',
                    confidence: state.aiResultInspection!.aiScore ?? 0.0,
                    severity: state.aiResultInspection!.severity,
                    onConfirm: () => cubit.confirmAiLabel(state.aiResultInspection!.id),
                    onCorrect: () => _showCorrectionDialog(context, cubit, state.aiResultInspection!.id),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _buildBasicsSection(context, state, cubit),
                const SizedBox(height: AppSpacing.lg),
                _buildLocationSection(context, state, cubit),
                const SizedBox(height: AppSpacing.lg),
                _buildPhotosSection(context, state, cubit),
                const SizedBox(height: AppSpacing.xxl),
                ElevatedButton(
                  onPressed: (state.photos.isEmpty || state.position == null || state.isSubmitting || state.aiResultInspection != null)
                      ? null
                      : () => cubit.submit(inspectorId),
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 20, width: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(state.isUploadingMedia ? 'Enviando mídias...' : 'Criar Inspeção em Campo'),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicsSection(BuildContext context, CreateInspectionState state, CreateInspectionCubit cubit) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informações Básicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppSpacing.md),
          const Text('Título', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
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
              Expanded(child: _buildReadonlyCoord('LAT', state.position?.latitude.toStringAsFixed(6) ?? '---')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildReadonlyCoord('LON', state.position?.longitude.toStringAsFixed(6) ?? '---')),
            ],
          ),
          if (state.address.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const Text('Endereço Aproximado', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.subtextLight)),
            const SizedBox(height: 4),
            Text(
              state.address,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: state.isLoadingGps ? null : () => _onCaptureGps(context, cubit),
            icon: const Icon(LucideIcons.mapPin, size: 18),
            label: Text(state.isLoadingGps ? 'Capturando...' : 'Obter Localização GPS'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
          ),
        ],
      ),
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

  Widget _buildReadonlyCoord(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.subtextLight)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
        ),
      ],
    );
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
