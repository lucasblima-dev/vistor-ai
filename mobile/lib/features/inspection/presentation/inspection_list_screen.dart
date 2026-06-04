import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/router.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/inspection_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/inspection_state.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/widgets/inspection_card.dart';
import 'package:vistor_ai_mobile/shared/widgets/empty_state.dart';
import 'package:vistor_ai_mobile/shared/widgets/error_state.dart';
import 'package:vistor_ai_mobile/shared/widgets/loading_state.dart';
import 'package:vistor_ai_mobile/shared/widgets/sync_indicator.dart';

class InspectionListScreen extends StatefulWidget {
  const InspectionListScreen({super.key});

  @override
  State<InspectionListScreen> createState() => _InspectionListScreenState();
}

class _InspectionListScreenState extends State<InspectionListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<InspectionCubit>().load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minhas Inspeções',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Visão geral do campo',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        actions: const [
          SyncIndicator(state: SyncState.synced),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por categoria ou local...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() {}), // Local filtering trigger
            ),
          ),

          Expanded(
            child: BlocBuilder<InspectionCubit, InspectionState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const AppLoadingState(message: 'Buscando inspeções...'),
                  error: (msg) => AppErrorState(
                    message: msg,
                    onRetry: () => context.read<InspectionCubit>().load(),
                  ),
                  empty: () => const AppEmptyState(
                    title: 'Nenhuma inspeção encontrada',
                    subtitle: 'Você ainda não registrou nenhuma ocorrência.',
                  ),
                  loaded: (inspections) {
                    final filtered = inspections.where((i) {
                      final query = _searchController.text.toLowerCase();
                      return i.category.toLowerCase().contains(query) ||
                             (i.description?.toLowerCase().contains(query) ?? false) ||
                             (i.address?.toLowerCase().contains(query) ?? false);
                    }).toList();

                    return Column(
                      children: [
                        // Filters Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.slidersHorizontal, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              const Text(
                                'Filtros e Status / Exibindo todas',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  filtered.length.toString(),
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        Expanded(
                          child: filtered.isEmpty
                              ? const AppEmptyState(
                                  title: 'Nenhum resultado',
                                  subtitle: 'Tente ajustar sua busca.',
                                )
                              : AnimationLimiter(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      return AnimationConfiguration.staggeredList(
                                        position: index,
                                        duration: const Duration(milliseconds: 375),
                                        child: SlideAnimation(
                                          verticalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: InspectionCard(inspection: filtered[index]),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createInspection).then((_) {
          if (context.mounted) {
            context.read<InspectionCubit>().load();
          }
        }),
        backgroundColor: const Color(0xFF3B55E6),
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('Nova Inspeção', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
