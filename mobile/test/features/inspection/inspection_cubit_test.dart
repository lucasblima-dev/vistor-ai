import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vistor_ai_mobile/features/inspection/data/inspection_repository.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/inspection_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/inspection_state.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

class MockInspectionRepository extends Mock implements InspectionRepository {}

void main() {
  late InspectionRepository repository;
  late InspectionCubit inspectionCubit;

  final tInspection = Inspection(
    id: '1',
    inspectorId: '1',
    title: 'Test Inspection',
    category: 'Elétrica',
    location: const LocationPoint(lat: 0, lon: 0),
    status: InspectionStatus.open,
    createdAt: DateTime.now(),
  );

  setUp(() {
    repository = MockInspectionRepository();
    inspectionCubit = InspectionCubit(repository: repository);
  });

  group('InspectionCubit - Load', () {
    blocTest<InspectionCubit, InspectionState>(
      'emits [loading, loaded] when load is successful with data',
      build: () {
        when(() => repository.getAll(status: any(named: 'status')))
            .thenAnswer((_) async => [tInspection]);
        return inspectionCubit;
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const InspectionState.loading(),
        InspectionState.loaded([tInspection]),
      ],
    );

    blocTest<InspectionCubit, InspectionState>(
      'emits [loading, empty] when load is successful with no data',
      build: () {
        when(() => repository.getAll(status: any(named: 'status')))
            .thenAnswer((_) async => []);
        return inspectionCubit;
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const InspectionState.loading(),
        const InspectionState.empty(),
      ],
    );

    blocTest<InspectionCubit, InspectionState>(
      'emits [loading, error] when load fails',
      build: () {
        when(() => repository.getAll(status: any(named: 'status')))
            .thenThrow(Exception('Erro ao carregar'));
        return inspectionCubit;
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const InspectionState.loading(),
        const InspectionState.error('Erro ao carregar'),
      ],
    );
  });
}
