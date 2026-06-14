import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/core/di/service_locator.dart';
import 'package:vistor_ai_mobile/core/local/sync_manager.dart';
import 'package:vistor_ai_mobile/core/services/theme_service.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_cubit.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_state.dart';
import 'package:vistor_ai_mobile/shared/models/user.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    // Configura o feedback de sincronização
    getIt<SyncManager>().onSyncSuccess = (count) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$count inspeções sincronizadas com sucesso!"),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    };
  }

  @override
  void dispose() {
    getIt<SyncManager>().onSyncSuccess = null;
    super.dispose();
  }

  // Removido carregamento local do avatar pois agora é obtido diretamente do backend.

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
                      onTap: () => context.push('/profile/edit'),
                    ),
                    const Divider(),
                    _SettingsTile(
                      icon: LucideIcons.lock,
                      title: "Segurança e Senha",
                      onTap: () => context.push('/profile/change-password'),
                    ),
                    const Divider(),
                    _SettingsTile(
                      icon: LucideIcons.archive,
                      title: "Inspeções Finalizadas & Arquivo",
                      onTap: () => context.push('/profile/archive'),
                    ),
                  ],
                ),
                if (user.role == UserRole.admin || user.role == UserRole.manager) ...[
                  const SizedBox(height: AppSpacing.sectionGap),
                  const _SectionLabel(label: "GERENCIAMENTO"),
                  _SettingsCard(
                    children: [
                      if (user.role == UserRole.admin) ...[
                        _SettingsTile(
                          icon: LucideIcons.users,
                          title: "Gestão de Usuários",
                          onTap: () => context.push('/users'),
                        ),
                        const Divider(),
                        _SettingsTile(
                          icon: LucideIcons.settings,
                          title: "Configurações do Sistema",
                          onTap: () => context.push('/admin/settings'),
                        ),
                        const Divider(),
                      ],
                      _SettingsTile(
                        icon: LucideIcons.userCheck,
                        title: "Gestão de Equipe",
                        onTap: () => context.push('/team'),
                      ),
                      const Divider(),
                      _SettingsTile(
                        icon: LucideIcons.fileText,
                        title: "Laudos Técnicos",
                        onTap: () => context.push('/reports-all'),
                      ),
                      const Divider(),
                      _SettingsTile(
                        icon: LucideIcons.download,
                        title: "Exportação de Dados",
                        onTap: () => context.push('/export'),
                      ),
                    ],
                  ),
                ],
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
                                "Estado da sincronização",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              StreamBuilder<int>(
                                stream: getIt<SyncManager>().pendingCountStream,
                                builder: (context, snapshot) {
                                  final count = snapshot.data ?? 0;
                                  if (count == 0) {
                                    return const Row(
                                      children: [
                                        Icon(LucideIcons.checkCircle2, color: AppColors.success, size: 14),
                                        SizedBox(width: 4),
                                        Text("Tudo em dia", style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    );
                                  }
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
                            onPressed: () async {
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(content: Text("Iniciando sincronização...")),
                              );
                              await getIt<SyncManager>().syncAll();
                            },
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
                  onTap: () => _showAboutDialog(context),
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
              backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                  ? Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              '${user.name} | ${user.role == UserRole.admin ? "Administrador" : user.role == UserRole.manager ? "Gestor" : "Inspetor Sênior"}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.cardLg),
          ),
          title: Row(
            children: [
              const Icon(LucideIcons.info, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                'Sobre o App',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.primaryDeep,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vistor AI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Inspeções técnicas de infraestrutura potencializadas por inteligência artificial.',
                style: TextStyle(color: AppColors.subtextLight),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Versão do App:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.badge),
                    ),
                    child: const Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Fechar',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
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
