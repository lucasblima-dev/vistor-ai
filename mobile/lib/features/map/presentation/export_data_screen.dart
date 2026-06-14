import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/core/di/service_locator.dart';
import 'package:vistor_ai_mobile/features/map/data/map_repository.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  late final MapRepository _mapRepository;
  bool _isDownloading = false;

  // Estado da Tela
  DateTimeRange? _selectedDateRange;
  bool _filterResolvidas = true;
  bool _filterAbertas = true;
  bool _filterCriticas = true;
  String _selectedFormat = 'geojson'; // 'geojson' ou 'csv'

  @override
  void initState() {
    super.initState();
    _mapRepository = getIt<MapRepository>();
    // Período padrão: Últimos 30 dias
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
  }

  void _selectPresetPeriod(int days) {
    setState(() {
      _selectedDateRange = DateTimeRange(
        start: DateTime.now().subtract(Duration(days: days)),
        end: DateTime.now(),
      );
    });
  }

  Future<void> _pickCustomDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = pickedRange;
      });
    }
  }

  Future<void> _startDownload() async {
    setState(() => _isDownloading = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Mapeamento de filtros para passar para a API
      String? statusFilter;
      String? severityFilter;

      // Se apenas uma das opções de status estiver marcada, filtramos por ela
      if (_filterResolvidas && !_filterAbertas) {
        statusFilter = 'resolved';
      } else if (!_filterResolvidas && _filterAbertas) {
        statusFilter = 'open';
      }

      if (_filterCriticas) {
        severityFilter = 'critical';
      }

      // 1. Faz a chamada HTTP assíncrona (não bloqueia a UI devido ao Event Loop)
      final data = await _mapRepository.exportData(
        format: _selectedFormat,
        status: statusFilter,
        severity: severityFilter,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      );

      // 2. Obtém diretório local de documentos do App
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final extension = _selectedFormat == 'geojson' ? 'geojson' : 'csv';
      final fileName = 'vistor_ai_export_$timestamp.$extension';
      
      final file = File('${directory.path}/$fileName');
      
      // 3. Grava o arquivo fisicamente
      await file.writeAsString(data);

      messenger.showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Exportação concluída com sucesso!', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                'Salvo em: .../documents/$fileName',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar dados: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd/MM/yyyy');

    final periodLabel = _selectedDateRange != null
        ? '${dateFormat.format(_selectedDateRange!.start)} - ${dateFormat.format(_selectedDateRange!.end)}'
        : 'Selecionar Período';

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  if (Navigator.of(context).canPop()) ...[
                    IconButton(
                      icon: Icon(
                        LucideIcons.arrowLeft,
                        color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    'Exportar Dados',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Card: Período
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.cardLg),
                  border: Border.all(
                    color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.calendar, color: AppColors.secondary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Período',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _pickCustomDateRange,
                          child: Text(
                            periodLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.secondary, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.button),
                              ),
                            ),
                            onPressed: () => _selectPresetPeriod(30),
                            child: const Text(
                              'Últimos 30 dias',
                              style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.secondary, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.button),
                              ),
                            ),
                            onPressed: () => _selectPresetPeriod(365),
                            child: const Text(
                              'Até hoje',
                              style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card: Status incluídos
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.cardLg),
                  border: Border.all(
                    color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.filter, color: AppColors.secondary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Status incluídos',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'Resolvidas',
                          isSelected: _filterResolvidas,
                          isDark: isDark,
                          onTap: () => setState(() => _filterResolvidas = !_filterResolvidas),
                        ),
                        _buildFilterChip(
                          label: 'Abertas',
                          isSelected: _filterAbertas,
                          isDark: isDark,
                          onTap: () => setState(() => _filterAbertas = !_filterAbertas),
                        ),
                        _buildFilterChip(
                          label: 'Críticas',
                          isSelected: _filterCriticas,
                          isDark: isDark,
                          onTap: () => setState(() => _filterCriticas = !_filterCriticas),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // FORMATO DO ARQUIVO Label
              Text(
                'FORMATO DO ARQUIVO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
                ),
              ),
              const SizedBox(height: 12),

              // FormatCards Row
              Row(
                children: [
                  Expanded(
                    child: FormatCard(
                      label: 'GeoJSON',
                      iconData: LucideIcons.map,
                      isSelected: _selectedFormat == 'geojson',
                      isDark: isDark,
                      onTap: () => setState(() => _selectedFormat = 'geojson'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormatCard(
                      label: 'CSV Data',
                      iconData: LucideIcons.fileSpreadsheet,
                      isSelected: _selectedFormat == 'csv',
                      isDark: isDark,
                      onTap: () => setState(() => _selectedFormat = 'csv'),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Botão Fazer Download
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                icon: _isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.download, size: 20),
                label: Text(
                  _isDownloading ? 'Baixando...' : 'Fazer Download',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onPressed: _isDownloading ? null : _startDownload,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surfaceVarDark : AppColors.surfaceVarLight),
          borderRadius: BorderRadius.circular(AppRadius.badge),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : (isDark ? AppColors.onSurfDark : AppColors.onSurfLight),
          ),
        ),
      ),
    );
  }
}

// ─── Componente: FormatCard ───────────────────────────────────────────────────

class FormatCard extends StatelessWidget {
  final String label;
  final IconData iconData;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const FormatCard({
    super.key,
    required this.label,
    required this.iconData,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 36,
              color: isSelected ? AppColors.primary : (isDark ? AppColors.subtextDark : AppColors.subtextLight),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.onSurfDark : AppColors.onSurfLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
