import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';

class OfflineBanner extends StatelessWidget {
  final int pendingCount;

  const OfflineBanner({
    super.key,
    this.pendingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final result = snapshot.data;
        final isOffline = result == ConnectivityResult.none;

        if (!isOffline) return const SizedBox.shrink();

        return MaterialBanner(
          backgroundColor: AppColors.offline,
          leading: const Icon(LucideIcons.wifiOff, color: Colors.white),
          content: Text(
            pendingCount > 0
                ? 'Sem conexão — $pendingCount inspeção(ões) pendente(s)'
                : 'Sem conexão com a internet',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {}, // Ação opcional
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
