import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/core/di/service_locator.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_cubit.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_state.dart';
import 'package:vistor_ai_mobile/features/auth/domain/user_management_cubit.dart';
import 'package:vistor_ai_mobile/features/auth/domain/user_management_state.dart';
import 'package:vistor_ai_mobile/shared/models/user.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late final UserManagementCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = getIt<UserManagementCubit>();
    _cubit.loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Obter o ID do admin atual logado para evitar que ele desative a si próprio
    final currentUserId = context.read<AuthCubit>().state.maybeWhen(
          authenticated: (user) => user.id,
          orElse: () => '',
        );

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: BlocConsumer<UserManagementCubit, UserManagementState>(
            bloc: _cubit,
            listener: (context, state) {
              state.maybeWhen(
                loaded: (_, __, ___, error) {
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                orElse: () {},
              );
            },
            builder: (context, state) {
              return state.when(
                initial: () => const Center(child: CircularProgressIndicator()),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (message) => _buildErrorState(message),
                loaded: (users, searchQuery, isUpdating, error) {
                  // Filtragem de busca local instantânea
                  final filteredUsers = users.where((user) {
                    final query = searchQuery.toLowerCase();
                    return user.name.toLowerCase().contains(query) ||
                        user.email.toLowerCase().contains(query);
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          if (Navigator.of(context).canPop()) ...[
                            IconButton(
                              icon: Icon(
                                LucideIcons.arrowLeft,
                                color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(
                            LucideIcons.shield,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                            size: 26,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Usuários',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.badge),
                            ),
                            child: const Text(
                              'Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVarDark : AppColors.surfaceVarLight,
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          border: Border.all(
                            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => _cubit.search(val),
                          style: TextStyle(
                            color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Pesquisar por nome ou e-mail...',
                            hintStyle: TextStyle(
                              color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            icon: Icon(
                              LucideIcons.search,
                              size: 18,
                              color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(LucideIcons.x, size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                      _cubit.search('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // List of Users
                      Expanded(
                        child: filteredUsers.isEmpty
                            ? _buildEmptyState(isDark)
                            : ListView.separated(
                                itemCount: filteredUsers.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final user = filteredUsers[index];
                                  final initials = getInitials(user.name);

                                  return UserCard(
                                    user: user,
                                    initials: initials,
                                    isDark: isDark,
                                    isSelf: user.id == currentUserId,
                                    isUpdating: isUpdating,
                                    onRoleChanged: (role) => _cubit.updateRole(user.id, role),
                                    onActiveToggle: (isActive) => _cubit.toggleActive(user.id, isActive),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.users,
              size: 48,
              color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum usuário encontrado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verifique o termo pesquisado e tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(LucideIcons.alertTriangle, size: 48, color: AppColors.error),
        const SizedBox(height: 16),
        Text(
          'Falha ao carregar usuários',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.onSurfDark
                : AppColors.onSurfLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.error),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => _cubit.loadUsers(),
          child: const Text('Tentar Novamente'),
        ),
      ],
    );
  }
}

// ─── Componente: UserCard ─────────────────────────────────────────────────────

class UserCard extends StatelessWidget {
  final User user;
  final String initials;
  final bool isDark;
  final bool isSelf;
  final bool isUpdating;
  final Function(UserRole) onRoleChanged;
  final Function(bool) onActiveToggle;

  const UserCard({
    super.key,
    required this.user,
    required this.initials,
    required this.isDark,
    required this.isSelf,
    required this.isUpdating,
    required this.onRoleChanged,
    required this.onActiveToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBlocked = !user.isActive;

    // Avatar config
    Color avatarBg;
    Widget avatarChild;

    if (isBlocked) {
      avatarBg = AppColors.error;
      avatarChild = const Icon(LucideIcons.userX, color: Colors.white, size: 22);
    } else if (user.role == UserRole.admin) {
      avatarBg = AppColors.primary;
      avatarChild = Text(
        initials,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
      );
    } else {
      avatarBg = AppColors.success;
      avatarChild = Text(
        initials,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
      );
    }

    // Role badge config (Cores do tema ou fallback premium para manager)
    Color badgeBg;
    Color badgeFg;
    String badgeText;

    if (isBlocked) {
      badgeBg = AppColors.roleBlocBg;
      badgeFg = AppColors.roleBlocFg;
      badgeText = 'BLOQUEADO';
    } else {
      switch (user.role) {
        case UserRole.admin:
          badgeBg = AppColors.roleAdminBg;
          badgeFg = AppColors.roleAdminFg;
          badgeText = 'ADMINISTRADOR';
          break;
        case UserRole.manager:
          // Tom roxo para Gestor (Manager)
          badgeBg = const Color(0xFFF3E8FF);
          badgeFg = const Color(0xFF7C3AED);
          badgeText = 'GESTOR';
          break;
        case UserRole.inspector:
          badgeBg = AppColors.roleInspBg;
          badgeFg = AppColors.roleInspFg;
          badgeText = 'INSPETOR';
          break;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: avatarBg,
            child: avatarChild,
          ),
          const SizedBox(width: 14),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.onSurfDark : AppColors.onSurfLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelf) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVarDark : AppColors.surfaceVarLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'VOCÊ',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeFg,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Actions PopupMenu
          PopupMenuButton<String>(
            enabled: !isUpdating,
            icon: Icon(
              LucideIcons.moreVertical,
              color: isDark ? AppColors.subtextDark : AppColors.subtextLight,
            ),
            onSelected: (value) => _handleAction(value, context),
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  value: 'role_admin',
                  enabled: !isSelf,
                  child: const Text('Tornar Administrador'),
                ),
                PopupMenuItem<String>(
                  value: 'role_manager',
                  enabled: !isSelf,
                  child: const Text('Tornar Gestor'),
                ),
                PopupMenuItem<String>(
                  value: 'role_inspector',
                  enabled: !isSelf,
                  child: const Text('Tornar Inspetor'),
                ),
                const PopupMenuDivider(),
                if (user.isActive)
                  PopupMenuItem<String>(
                    value: 'toggle_active',
                    enabled: !isSelf, // Admin não pode desativar a si próprio
                    child: const Text(
                      'Desativar conta',
                      style: TextStyle(color: AppColors.error),
                    ),
                  )
                else
                  PopupMenuItem<String>(
                    value: 'toggle_active',
                    enabled: !isSelf,
                    child: const Text(
                      'Reativar conta',
                      style: TextStyle(color: AppColors.success),
                    ),
                  ),
              ];
            },
          ),
        ],
      ),
    );
  }

  void _handleAction(String value, BuildContext context) {
    if (value == 'toggle_active') {
      onActiveToggle(!user.isActive);
    } else if (value == 'role_admin') {
      onRoleChanged(UserRole.admin);
    } else if (value == 'role_manager') {
      onRoleChanged(UserRole.manager);
    } else if (value == 'role_inspector') {
      onRoleChanged(UserRole.inspector);
    }
  }
}
