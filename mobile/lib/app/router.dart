import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_cubit.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_state.dart';
import 'package:vistor_ai_mobile/features/auth/presentation/login_screen.dart';
import 'package:vistor_ai_mobile/features/auth/presentation/splash_screen.dart';

// ─── Constantes de rota ───────────────────────────────────────────────────────

class AppRoutes {
  // Auth
  static const splash             = '/';
  static const login              = '/login';

  // Bottom nav (raízes das 4 abas)
  static const home               = '/inspections';
  static const map                = '/map';
  static const reports            = '/reports';
  static const profile            = '/profile';

  // Inspeções (sub-rotas da aba home)
  static const createInspection   = '/inspections/create';
  static const inspectionDetail   = '/inspections/:id';

  // Laudos (sub-rota da aba reports)
  static const reportDetail       = '/reports/:id';

  // Gestão — fora do shell (manager/admin)
  static const teamManagement     = '/team';
  static const exportData         = '/export';
  static const userManagement     = '/users';

  // Utilitário
  static const offline            = '/offline';

  // Helpers para rotas com parâmetro
  static String inspection(String id) => '/inspections/$id';
  static String report(String id)     => '/reports/$id';
}

// ─── App Scaffold ─────────────────────────────────────────────────────────────

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('AppScaffold'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.clipboardList),
            label: 'Inspeções',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.fileText),
            label: 'Laudos',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ─── Router Builder ──────────────────────────────────────────────────────────

class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(AuthCubit cubit) {
    _subscription = cubit.stream.listen((state) {
      notifyListeners();
    });
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter buildRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: AuthRefreshListenable(authCubit),
    redirect: (context, state) {
      final authState = authCubit.state;
      final bool loggingIn = state.matchedLocation == AppRoutes.login;
      final bool isSplash = state.matchedLocation == AppRoutes.splash;

      return authState.maybeWhen(
        authenticated: (_) {
          if (loggingIn || isSplash) return AppRoutes.home;
          return null;
        },
        unauthenticated: () {
          if (loggingIn || isSplash) return null;
          return AppRoutes.login;
        },
        error: (_) {
           if (loggingIn || isSplash) return null;
           return AppRoutes.login;
        },
        orElse: () => null, // Mantém no splash enquanto carrega
      );
    },
    routes: [
      // Auth & Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Shell para as abas principais
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Aba: Inspeções
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Home - Lista de Inspeções')),
                ),
                routes: [
                  GoRoute(
                    path: 'create', // /inspections/create
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Nova Inspeção')),
                    ),
                  ),
                  GoRoute(
                    path: ':id', // /inspections/:id
                    builder: (context, state) => Scaffold(
                      body: Center(child: Text('Detalhe da Inspeção ${state.pathParameters['id']}')),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Aba: Mapa
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Mapa / Heatmap')),
                ),
              ),
            ],
          ),

          // Aba: Laudos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Lista de Laudos')),
                ),
                routes: [
                  GoRoute(
                    path: ':id', // /reports/:id
                    builder: (context, state) => Scaffold(
                      body: Center(child: Text('Visualizador de Laudo ${state.pathParameters['id']}')),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Aba: Perfil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Perfil do Usuário')),
                ),
              ),
            ],
          ),
        ],
      ),

      // Rotas fora do shell (Gestão)
      GoRoute(
        path: AppRoutes.teamManagement,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Gestão de Equipe')),
        ),
      ),
      GoRoute(
        path: AppRoutes.exportData,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Exportar Dados')),
        ),
      ),
      GoRoute(
        path: AppRoutes.userManagement,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Gestão de Usuários')),
        ),
      ),

      // Utilitário
      GoRoute(
        path: AppRoutes.offline,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Modo Offline')),
        ),
      ),
    ],
  );
}

// Helper para acessar o contexto fora da árvore de widgets se necessário
class GetItNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static BuildContext? get rootContext => navigatorKey.currentContext;
}
