import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vistor_ai_mobile/core/di/service_locator.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_cubit.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_state.dart';
import 'package:vistor_ai_mobile/features/auth/presentation/login_screen.dart';
import 'package:vistor_ai_mobile/features/auth/presentation/profile_screen.dart';
import 'package:vistor_ai_mobile/features/auth/presentation/register_screen.dart';
import 'package:vistor_ai_mobile/features/auth/presentation/splash_screen.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/inspection_detail_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/inspection_list_screen.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/create_inspection_screen.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/inspection_detail_screen.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/archived_inspections_screen.dart';
import 'package:vistor_ai_mobile/features/map/presentation/map_screen.dart';
import 'package:vistor_ai_mobile/features/report/presentation/report_list_screen.dart';
import 'package:vistor_ai_mobile/features/report/presentation/cubit/report_cubit.dart';
import 'package:vistor_ai_mobile/features/report/presentation/screens/report_detail_screen.dart';
import 'package:vistor_ai_mobile/shared/models/report.dart';
import 'package:vistor_ai_mobile/shared/screens/offline_screen.dart';
import 'package:vistor_ai_mobile/shared/widgets/offline_banner.dart';

// ─── Constantes de rota ───────────────────────────────────────────────────────

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/inspections';
  static const String createInspection = '/inspections/create';
  static String inspection(String id) => '/inspections/$id';

  static const String map = '/map';
  static const String reports = '/reports';
  static String report(String id) => '/reports/$id';

  static const String profile = '/profile';
  
  // Gestão
  static const String teamManagement = '/team';
  static const String userManagement = '/users';
  static const String exportData = '/export';

  // Utilitário
  static const String offline = '/offline';
}

// ─── Scaffold Principal com Shell (Abas) ──────────────────────────────────────

class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.list),
            label: 'Inspeções',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.fileText),
            label: 'Laudos',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ─── Roteador Principal ──────────────────────────────────────────────────────

class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(AuthCubit authCubit) {
    _subscription = authCubit.stream.listen((_) => notifyListeners());
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
    navigatorKey: GetItNavigator.navigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: AuthRefreshListenable(authCubit),
    redirect: (context, state) async {
      final authState = authCubit.state;
      final bool loggingIn = state.matchedLocation == AppRoutes.login;
      final bool registering = state.matchedLocation == AppRoutes.register;
      final bool isSplash = state.matchedLocation == AppRoutes.splash;

      // 1. Redirecionamento de Auth
      final String? authRedirect = authState.maybeWhen(
        authenticated: (_) {
          if (loggingIn || registering || isSplash) return AppRoutes.home;
          return null;
        },
        unauthenticated: () {
          if (loggingIn || registering) return null;
          return AppRoutes.login;
        },
        error: (_) {
           if (loggingIn || registering) return null;
           return AppRoutes.login;
        },
        orElse: () => null,
      );

      if (authRedirect != null) return authRedirect;

      // 2. Redirecionamento de Conectividade (UC-03 / RN-01)
      final networkDependentRoutes = [
        AppRoutes.map,
        AppRoutes.reports,
        AppRoutes.teamManagement,
        AppRoutes.userManagement,
        AppRoutes.exportData,
      ];

      if (networkDependentRoutes.any((route) => state.matchedLocation.startsWith(route))) {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          return AppRoutes.offline;
        }
      }

      return null;
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
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
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
                builder: (context, state) => const InspectionListScreen(),
                routes: [
                  GoRoute(
                    path: 'create', // /inspections/create
                    builder: (context, state) => const CreateInspectionScreen(),
                  ),
                  GoRoute(
                    path: ':id', // /inspections/:id
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      final readOnly = state.uri.queryParameters['readOnly'] == 'true';
                      return BlocProvider(
                        create: (context) => getIt<InspectionDetailCubit>(param1: id),
                        child: InspectionDetailScreen(readOnly: readOnly),
                      );
                    },
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
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),

          // Aba: Laudos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                builder: (context, state) => const ReportListScreen(),
                routes: [
                  GoRoute(
                    path: ':id', // /reports/:id
                    builder: (context, state) {
                      final report = state.extra as Report?;
                      if (report != null) {
                        return BlocProvider(
                          create: (context) => getIt<ReportCubit>(),
                          child: ReportDetailScreen(report: report),
                        );
                      }
                      return const Scaffold(
                        body: Center(child: Text('Erro: Laudo não carregado')),
                      );
                    },
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
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'archive',
                    builder: (context, state) => const ArchivedInspectionsScreen(),
                  ),
                ],
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
        builder: (context, state) => const OfflineScreen(),
      ),
    ],
  );
}

// Helper para acessar o contexto fora da árvore de widgets se necessário
class GetItNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static BuildContext? get rootContext => navigatorKey.currentContext;
}
