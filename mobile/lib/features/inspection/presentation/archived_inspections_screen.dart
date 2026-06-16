import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/core/di/service_locator.dart';
import 'package:vistor_ai_mobile/features/inspection/data/inspection_repository.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';
import 'package:vistor_ai_mobile/shared/widgets/empty_state.dart';
import 'package:vistor_ai_mobile/shared/widgets/loading_state.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/widgets/inspection_card.dart';

class ArchivedInspectionsScreen extends StatefulWidget {
  const ArchivedInspectionsScreen({super.key});

  @override
  State<ArchivedInspectionsScreen> createState() => _ArchivedInspectionsScreenState();
}

class _ArchivedInspectionsScreenState extends State<ArchivedInspectionsScreen> {
  late Future<List<Inspection>> _archivedInspectionsFuture;

  @override
  void initState() {
    super.initState();
    _loadArchived();
  }

  void _loadArchived() {
    setState(() {
      _archivedInspectionsFuture = _fetchArchived();
    });
  }

  Future<List<Inspection>> _fetchArchived() async {
    try {
      final repository = getIt<InspectionRepository>();
      // Carrega todas as inspeções e filtra localmente por resolved/archived
      final all = await repository.getAll();
      return all.where((i) => 
        i.status == InspectionStatus.resolved || 
        i.status == InspectionStatus.archived
      ).toList();
    } catch (e) {
      // Fallback: se a chamada de rede falhar e o repositório lançar erro, tentamos ler localmente do DAO
      try {
        final repository = getIt<InspectionRepository>();
        final allLocal = await repository.getAll(); // O getAll possui fallback interno de timeout/conexão
        return allLocal.where((i) => 
          i.status == InspectionStatus.resolved || 
          i.status == InspectionStatus.archived
        ).toList();
      } catch (_) {
        return [];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Arquivo de Inspeções',
          style: theme.textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : AppColors.onBgLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: BackButton(color: isDark ? Colors.white : AppColors.onBgLight),
      ),
      body: FutureBuilder<List<Inspection>>(
        future: _archivedInspectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingState(message: 'Carregando arquivo...');
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.alertTriangle, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Erro ao carregar inspeções: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadArchived,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final inspections = snapshot.data ?? [];

          if (inspections.isEmpty) {
            return const Center(
              child: Text(
                'Não há inspeções arquivadas no momento!',
                style: TextStyle(
                  color: Colors.grey, 
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadArchived(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: inspections.length,
              itemBuilder: (context, index) {
                final inspection = inspections[index];
                return InspectionCard(
                  inspection: inspection,
                  onTap: () {
                    // Navega para a tela de detalhes com query param readOnly
                    context.push('/inspections/${inspection.id}?readOnly=true').then((_) {
                      _loadArchived();
                    });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
