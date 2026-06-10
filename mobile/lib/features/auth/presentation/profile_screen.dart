import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/core/di/service_locator.dart';
import 'package:vistor_ai_mobile/core/local/sync_manager.dart';
import 'package:vistor_ai_mobile/core/services/theme_service.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_cubit.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_state.dart';
import 'package:vistor_ai_mobile/shared/models/user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return state.maybeWhen(
            authenticated: (user) => _buildProfile(context, user),
            orElse: () => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildProfile(BuildContext context, User user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context, user),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                const _SectionLabel(label: "CONTA"),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: LucideIcons.user,
                      title: "Editar perfil",
                      onTap: () {},
                    ),
                    const Divider(),
                    _SettingsTile(
                      icon: LucideIcons.lock,
                      title: "Segurança e Senha",
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                const _SectionLabel(label: "PREFERÊNCIAS"),
                _SettingsCard(
                  children: [
                    _SwitchTile(
                      icon: LucideIcons.bell,
                      title: "Alertas críticos",
                      subtitle: "Notificações push imediatas",
                      value: true,
                      onChanged: (v) {},
                    ),
                    const Divider(),
                    _SwitchTile(
                      icon: LucideIcons.clipboardList,
                      title: "Resumo diário",
                      subtitle: "Relatório via email",
                      value: false,
                      onChanged: (v) {},
                    ),
                    const Divider(),
                    _SwitchTile(
                      icon: LucideIcons.bellRing,
                      title: "Inspeção atribuída",
                      subtitle: "Avisar ao receber tarefa",
                      value: true,
                      onChanged: (v) {},
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                const _SectionLabel(label: "Sincronização"),
                _SettingsCard(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Última sync: Há 2 min",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              StreamBuilder<int>(
                                stream: getIt<SyncManager>().pendingCount,
                                builder: (context, snapshot) {
                                  final count = snapshot.data ?? 0;
                                  if (count == 0) return const SizedBox.shrink();
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.offline,
                                      borderRadius: BorderRadius.circular(AppRadius.badge),
                                    ),
                                    child: Text(
                                      "$count Pendentes",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: () => getIt<SyncManager>().syncAll(),
                            icon: const Icon(LucideIcons.refreshCcw, size: 18),
                            label: const Text("Forçar Sincronização"),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              side: const BorderSide(color: AppColors.outlineLight),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.button),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                _SettingsTile(
                  icon: LucideIcons.info,
                  title: "Sobre o App",
                  trailing: const Text("v1.0.0"),
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: LucideIcons.logOut,
                  title: "Sair da conta",
                  color: AppColors.error,
                  onTap: () => _showLogoutConfirmation(context),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User user) {
    final initials = user.name.isNotEmpty
        ? user.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('').toUpperCase()
        : '?';
    final themeNotifier = getIt<ValueNotifier<ThemeMode>>();

    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppGradients.premium,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (context, mode, _) {
                    final isDark = mode == ThemeMode.dark ||
                        (mode == ThemeMode.system &&
                            MediaQuery.of(context).platformBrightness == Brightness.dark);
                    return Icon(
                      isDark ? LucideIcons.sun : LucideIcons.moon,
                      color: Colors.white,
                    );
                  },
                ),
                onPressed: () {
                  final newMode = themeNotifier.value == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                  themeNotifier.value = newMode;
                  getIt<ThemeService>().setThemeMode(newMode);
                },
              ),
            ),
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.glassWhite,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(AppRadius.badge),
              ),
              child: Text(
                user.role == UserRole.admin
                    ? "Administrador"
                    : user.role == UserRole.manager
                        ? "Gestor"
                        : "Inspetor Sênior",
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user.email,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              "Sair da conta?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              "Você precisará fazer login novamente para acessar seus dados.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.subtextLight),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthCubit>().logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text("Sim, sair agora"),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.subtextLight,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        boxShadow: isDark ? null : const [AppShadows.card],
        border: isDark ? Border.all(color: const Color(0xFF2A2A3E)) : null,
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVarDark : AppColors.surfaceVarLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color ?? AppColors.secondary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing: trailing ?? const Icon(LucideIcons.chevronRight, size: 18),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVarDark : AppColors.surfaceVarLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.secondary),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.subtextLight)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
