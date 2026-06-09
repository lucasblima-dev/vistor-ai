import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vistor_ai_mobile/shared/models/report.dart';

part 'report_state.freezed.dart';

@freezed
class ReportState with _$ReportState {
  const factory ReportState.initial() = _Initial;
  const factory ReportState.loading() = _Loading;
  const factory ReportState.loaded(List<Report> reports) = _Loaded;
  const factory ReportState.generating() = _Generating;
  const factory ReportState.generated(Report report) = _Generated;
  const factory ReportState.error(String message) = _Error;
}
