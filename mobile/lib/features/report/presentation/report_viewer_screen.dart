import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vistor_ai_mobile/shared/models/report.dart';
import 'package:vistor_ai_mobile/shared/widgets/loading_overlay.dart';
import 'package:vistor_ai_mobile/shared/widgets/error_state.dart';

class ReportViewerScreen extends StatefulWidget {
  final Report report;

  const ReportViewerScreen({super.key, required this.report});

  @override
  State<ReportViewerScreen> createState() => _ReportViewerScreenState();
}

class _ReportViewerScreenState extends State<ReportViewerScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _downloadAndOpen();
  }

  Future<void> _downloadAndOpen() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url = widget.report.downloadUrl;
      if (url == null) throw Exception('URL de download não disponível.');

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/laudo_${widget.report.id.substring(0, 8)}.pdf';
      
      // Download via Dio
      await Dio().download(url, filePath);

      final result = await OpenFilex.open(filePath);
      
      if (result.type != ResultType.done) {
        throw Exception('Não foi possível abrir o PDF: ${result.message}');
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laudo #${widget.report.id.substring(0, 8)}'),
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: AppErrorState(
                message: _error!,
                onRetry: _downloadAndOpen,
              ),
            )
          else if (!_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('PDF aberto no visualizador nativo.'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _downloadAndOpen,
                    child: const Text('Abrir Novamente'),
                  ),
                ],
              ),
            ),
          if (_isLoading)
            const AppLoadingOverlay(message: 'Baixando laudo técnico...'),
        ],
      ),
    );
  }
}
