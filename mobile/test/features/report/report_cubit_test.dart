import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vistor_ai_mobile/features/report/domain/repositories/report_repository.dart';
import 'package:vistor_ai_mobile/features/report/presentation/cubit/report_cubit.dart';
import 'package:vistor_ai_mobile/features/report/presentation/cubit/report_state.dart';
import 'package:vistor_ai_mobile/shared/models/report.dart';

class MockReportRepository extends Mock implements ReportRepository {}

void main() {
  late ReportRepository repository;
  late ReportCubit reportCubit;

  final tReport = Report(
    id: '1',
    inspectionId: '1',
    generatedBy: 'user-1',
    minioKey: 'reports/1.pdf',
    sha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    createdAt: DateTime.now(),
    downloadUrl: 'https://vistor-ai.com/reports/1.pdf',
  );

  setUp(() {
    repository = MockReportRepository();
    reportCubit = ReportCubit(repository: repository);
  });

  group('ReportCubit - loadAll', () {
    blocTest<ReportCubit, ReportState>(
      'emits [ReportLoading, ReportLoaded] when loadAll succeeds',
      build: () {
        when(() => repository.getAll()).thenAnswer((_) async => [tReport]);
        return reportCubit;
      },
      act: (cubit) => cubit.loadAll(),
      expect: () => [
        const ReportState.loading(),
        ReportState.loaded([tReport]),
      ],
    );

    blocTest<ReportCubit, ReportState>(
      'emits [ReportLoading, ReportError] when loadAll fails',
      build: () {
        when(() => repository.getAll()).thenThrow(Exception('Erro ao buscar laudos'));
        return reportCubit;
      },
      act: (cubit) => cubit.loadAll(),
      expect: () => [
        const ReportState.loading(),
        const ReportState.error('Erro ao buscar laudos'),
      ],
    );
  });

  group('ReportCubit - generate', () {
    blocTest<ReportCubit, ReportState>(
      'emits [ReportLoading, ReportLoaded] when generate succeeds',
      build: () {
        when(() => repository.generate(any())).thenAnswer((_) async => tReport);
        when(() => repository.getAll()).thenAnswer((_) async => [tReport]);
        return reportCubit;
      },
      act: (cubit) => cubit.generate('insp-1'),
      expect: () => [
        const ReportState.loading(),
        ReportState.loaded([tReport]),
      ],
    );

    blocTest<ReportCubit, ReportState>(
      'emits [ReportLoading, ReportError] when generate fails',
      build: () {
        when(() => repository.generate(any())).thenThrow(Exception('Falha ao gerar'));
        return reportCubit;
      },
      act: (cubit) => cubit.generate('insp-1'),
      expect: () => [
        const ReportState.loading(),
        const ReportState.error('Falha ao gerar'),
      ],
    );
  });
}
