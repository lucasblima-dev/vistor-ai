import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vistor_ai_mobile/shared/models/report.dart';

part 'report_state.freezed.dart';

@freezed
class ReportState with _$ReportState {
  const factory ReportState.initial() = ReportInitial;
  const factory ReportState.loading() = ReportLoading;
  const factory ReportState.loaded(List<Report> reports) = ReportLoaded;
  const factory ReportState.downloading(double progress) = ReportDownloading;
  const factory ReportState.downloaded(String filePath) = ReportDownloaded;
  const factory ReportState.error(String message) = ReportError;
}
