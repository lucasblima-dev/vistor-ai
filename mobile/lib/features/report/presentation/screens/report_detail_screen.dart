import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/features/report/presentation/cubit/report_cubit.dart';
import 'package:vistor_ai_mobile/features/report/presentation/cubit/report_state.dart';
import 'package:vistor_ai_mobile/shared/models/report.dart';
import 'package:vistor_ai_mobile/shared/widgets/error_snackbar.dart';
import 'package:vistor_ai_mobile/shared/widgets/error_state.dart';
import 'package:vistor_ai_mobile/shared/widgets/loading_state.dart';
import 'package:open_filex/open_filex.dart';

class ReportDetailScreen extends StatefulWidget {
  final Report report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String? _pdfViewError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportCubit>().downloadForPreview(widget.report);
    });
  }

  Future<void> _handleDownload() async {
    try {
      final savedPath = await context.read<ReportCubit>().downloadToLocal(widget.report);
      if (savedPath != null && mounted) {
        showSuccessSnackbar(context, 'Laudo salvo em: $savedPath');
        await OpenFilex.open(savedPath);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, e.toString());
      }
    }
  }

  Future<void> _handleShare() async {
    try {
      await context.read<ReportCubit>().shareReport(widget.report);
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laudo #${widget.report.id.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download, size: 20),
            onPressed: _handleDownload,
            tooltip: 'Baixar no dispositivo',
          ),
          IconButton(
            icon: const Icon(LucideIcons.share2, size: 20),
            onPressed: _handleShare,
            tooltip: 'Compartilhar',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const AppLoadingState(message: 'Carregando laudo...'),
            loaded: (_) => const SizedBox.shrink(), // We manage loading/downloading states mainly
            downloading: (progress) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress > 0.0 ? progress : null,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Baixando laudo... ${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            downloaded: (filePath) {
              return Stack(
                children: [
                  SfPdfViewer.file(
                    File(filePath),
                    onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                      setState(() {
                        _pdfViewError = details.description;
                      });
                    },
                    onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                      setState(() {
                        _totalPages = details.document.pages.count;
                        _isReady = true;
                      });
                    },
                    onPageChanged: (PdfPageChangedDetails details) {
                      setState(() {
                        _currentPage = details.newPageNumber - 1;
                      });
                    },
                  ),
                  if (_pdfViewError != null)
                    Center(
                      child: AppErrorState(
                        message: _pdfViewError!,
                        onRetry: () {
                          setState(() {
                            _pdfViewError = null;
                            _isReady = false;
                          });
                          context.read<ReportCubit>().downloadForPreview(widget.report);
                        },
                      ),
                    ),
                  if (_isReady && _totalPages > 0)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Página ${_currentPage + 1} / $_totalPages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
            error: (message) => Center(
              child: AppErrorState(
                message: message,
                onRetry: () => context.read<ReportCubit>().downloadForPreview(widget.report),
              ),
            ),
          );
        },
      ),
    );
  }
}
