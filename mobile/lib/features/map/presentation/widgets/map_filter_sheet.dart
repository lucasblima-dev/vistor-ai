import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/features/map/domain/map_cubit.dart';
import 'package:vistor_ai_mobile/features/map/domain/map_state.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

class MapFilterSheet extends StatefulWidget {
  const MapFilterSheet({super.key});

  @override
  State<MapFilterSheet> createState() => _MapFilterSheetState();
}

class _MapFilterSheetState extends State<MapFilterSheet> {
  late double _currentRadius;
  final Set<InspectionSeverity> _selectedSeverities = {};
  final Set<InspectionStatus> _selectedStatuses = {};

  @override
  void initState() {
    super.initState();
    final state = context.read<MapCubit>().state;
    _currentRadius = state.maybeMap(
      loaded: (s) => s.data.radius,
      orElse: () => 300.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.subtextLight.withValues(alpha:0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Filtros do Mapa',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Raio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Raio de busca', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                _currentRadius >= 1000 
                    ? '${(_currentRadius / 1000).toStringAsFixed(1)} km' 
                    : '${_currentRadius.toInt()} m',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: _currentRadius,
            min: 50,
            max: 5000,
            divisions: 99,
            onChanged: (value) => setState(() => _currentRadius = value),
          ),
          
          const SizedBox(height: AppSpacing.md),
          const Text('Severidade', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip<InspectionSeverity>(
                label: 'Crítico',
                value: InspectionSeverity.critical,
                selected: _selectedSeverities.contains(InspectionSeverity.critical),
                onSelected: (selected) => _toggleSeverity(InspectionSeverity.critical, selected),
              ),
              _FilterChip<InspectionSeverity>(
                label: 'Moderado',
                value: InspectionSeverity.moderate,
                selected: _selectedSeverities.contains(InspectionSeverity.moderate),
                onSelected: (selected) => _toggleSeverity(InspectionSeverity.moderate, selected),
              ),
              _FilterChip<InspectionSeverity>(
                label: 'Baixo',
                value: InspectionSeverity.low,
                selected: _selectedSeverities.contains(InspectionSeverity.low),
                onSelected: (selected) => _toggleSeverity(InspectionSeverity.low, selected),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip<InspectionStatus>(
                label: 'Aberta',
                value: InspectionStatus.open,
                selected: _selectedStatuses.contains(InspectionStatus.open),
                onSelected: (selected) => _toggleStatus(InspectionStatus.open, selected),
              ),
              _FilterChip<InspectionStatus>(
                label: 'Em andamento',
                value: InspectionStatus.inProgress,
                selected: _selectedStatuses.contains(InspectionStatus.inProgress),
                onSelected: (selected) => _toggleStatus(InspectionStatus.inProgress, selected),
              ),
              _FilterChip<InspectionStatus>(
                label: 'Resolvida',
                value: InspectionStatus.resolved,
                selected: _selectedStatuses.contains(InspectionStatus.resolved),
                onSelected: (selected) => _toggleStatus(InspectionStatus.resolved, selected),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<MapCubit>().updateRadius(_currentRadius);
                Navigator.pop(context);
              },
              child: const Text('Aplicar filtros'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  void _toggleSeverity(InspectionSeverity severity, bool selected) {
    setState(() {
      if (selected) {
        _selectedSeverities.add(severity);
      } else {
        _selectedSeverities.remove(severity);
      }
    });
  }

  void _toggleStatus(InspectionStatus status, bool selected) {
    setState(() {
      if (selected) {
        _selectedStatuses.add(status);
      } else {
        _selectedStatuses.remove(status);
      }
    });
  }
}

class _FilterChip<T> extends StatelessWidget {
  final String label;
  final T value;
  final bool selected;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withValues(alpha:0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.subtextLight,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.outlineLight,
          width: 1,
        ),
      ),
    );
  }
}
