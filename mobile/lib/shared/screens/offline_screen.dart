import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/app/router.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ─── Ícone Central (Layout 8.12) ──────────────────────────────────
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVarDark : AppColors.surfaceVarLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          LucideIcons.wifiOff,
                          color: AppColors.offline,
                          size: 36,
                        ),
                      ),
                      Positioned(
                        top: 18,
                        right: 18,
                        child: Pulse(
                          infinite: true,
                          duration: const Duration(seconds: 2),
                          child: const Icon(
                            LucideIcons.sparkles,
                            color: AppColors.offline,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Títulos ────────────────────────────────────────────────────
              Text(
                "Você está Offline",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Sua conexão com a internet caiu, mas o trabalho não precisa parar.\n"
                "Continue criando suas inspeções localmente. Elas serão\n"
                "sincronizadas assim que a rede voltar.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // ─── Ações ──────────────────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.createInspection),
                icon: const Icon(LucideIcons.plus),
                label: const Text("Criar Inspeção Offline"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.offline,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Connectivity().checkConnectivity();
                  if (result != ConnectivityResult.none) {
                    if (context.mounted) {
                      context.go(AppRoutes.home);
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Ainda sem conexão. Verifique seu WiFi ou dados móveis."),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(LucideIcons.refreshCcw, size: 18),
                label: const Text("Tentar Novamente"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(
                    color: theme.colorScheme.outline,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
