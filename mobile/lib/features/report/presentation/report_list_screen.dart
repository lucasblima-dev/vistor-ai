import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/features/report/presentation/cubit/report_cubit.dart';
import 'package:vistor_ai_mobile/features/report/presentation/cubit/report_state.dart';
import 'package:vistor_ai_mobile/shared/models/report.dart';
import 'package:vistor_ai_mobile/shared/widgets/empty_state.dart';
import 'package:vistor_ai_mobile/shared/widgets/error_snackbar.dart';
import 'package:vistor_ai_mobile/shared/widgets/error_state.dart';
import 'package:vistor_ai_mobile/shared/widgets/loading_state.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ReportCubit>().loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ReportCubit, ReportState>(
          builder: (context, state) {
            final count = state.maybeMap(
              loaded: (s) => s.reports.length,
              orElse: () => 0,
            );
            return Row(
              children: [
                const Text('Laudos Técnicos'),
                const SizedBox(width: 8),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Buscar por ID ou data...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ReportCubit, ReportState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const AppLoadingState(message: 'Carregando laudos...'),
                  downloading: (progress) => AppLoadingState(
                    message: 'Baixando laudo... ${(progress * 100).toStringAsFixed(0)}%',
                  ),
                  downloaded: (filePath) => const AppLoadingState(message: 'Laudo pronto!'),
                  error: (msg) => AppErrorState(
                    message: msg,
                    onRetry: () => context.read<ReportCubit>().loadAll(),
                  ),
                  loaded: (reports) {
                    final filtered = reports.where((r) {
                      return r.id.toLowerCase().contains(_searchQuery) ||
                          DateFormat('dd/MM/yyyy').format(r.createdAt).contains(_searchQuery);
                    }).toList();

                    if (filtered.isEmpty) {
                      return const AppEmptyState(
                        title: 'Nenhum laudo encontrado',
                        subtitle: 'Os laudos gerados aparecerão aqui.',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _ReportCard(report: filtered[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/reports/${report.id}', extra: report),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53E3E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.fileText, color: Color(0xFFE53E3E)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laudo #${report.id.substring(0, 8)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(report.createdAt),
                          style: const TextStyle(color: AppColors.offline, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HashBadge(hash: report.sha256),
                  const Row(
                    children: [
                      Text(
                        'Ver documento',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(LucideIcons.chevronRight, size: 16, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(LucideIcons.user, size: 14, color: AppColors.offline),
                  const SizedBox(width: 4),
                  Text(
                    'Gerado por: ${report.generatedBy.substring(0, 8)}',
                    style: const TextStyle(color: AppColors.offline, fontSize: 12),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.download, size: 20),
                    onPressed: () async {
                      try {
                        final savedPath = await context.read<ReportCubit>().downloadToLocal(report);
                        if (savedPath != null && context.mounted) {
                          showSuccessSnackbar(context, 'Laudo salvo em: $savedPath');
                          await OpenFilex.open(savedPath);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackbar(context, e.toString());
                        }
                      }
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.share2, size: 20),
                    onPressed: () async {
                      try {
                        await context.read<ReportCubit>().shareReport(report);
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackbar(context, e.toString());
                        }
                      }
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HashBadge extends StatelessWidget {
  final String hash;

  const _HashBadge({required this.hash});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.shieldCheck, size: 12, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            '${hash.substring(0, 8)}...',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
