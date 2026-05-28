# Vistor AI - Navigation & Routing Specification

> **Aviso ao Agente (Gemini CLI)**:

> Este arquivo (`ROUTER.md`) é a fonte de verdade absoluta para a arquitetura de rotas e navegação do aplicativo.

> O agente deve usar estas diretrizes, constantes e estrutura de pseudo-código para configurar, referenciar e atualizar `mobile/lib/app/router.dart`.

> **NUNCA** utilize rotas em formato de strings brutas (hardcoded). Utilize sempre os tokens definidos em `AppRoutes`.

## Código e Diretrizes Estruturais (`router.dart`)

```dart
// docs/mobile/ROUTER.dart
// Fonte da verdade de navegação do Vistor AI.
// O agente usa este arquivo como referência ao preencher mobile/lib/app/router.dart.

import 'package:go_router/go_router.dart';

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

// ─── Estrutura do GoRouter ────────────────────────────────────────────────────
// O agente implementa buildRouter() em mobile/lib/app/router.dart.
// A estrutura obrigatória é:
//
// GoRouter(
//   initialLocation: AppRoutes.splash,
//   redirect: (context, state) {
//     // Guard de autenticação via AuthCubit
//     // Não autenticado + não em rota de auth → AppRoutes.login
//     // Autenticado + em rota de auth → AppRoutes.home
//   },
//   routes: [
//     GoRoute(path: AppRoutes.splash, ...),
//     GoRoute(path: AppRoutes.login, ...),
//     StatefulShellRoute.indexedStack(
//       builder: (ctx, state, shell) => AppScaffold(navigationShell: shell),
//       branches: [
//         branch: home → inspections + create + :id
//         branch: map
//         branch: reports + :id
//         branch: profile
//       ],
//     ),
//     GoRoute(path: AppRoutes.teamManagement, ...),
//     GoRoute(path: AppRoutes.exportData, ...),
//     GoRoute(path: AppRoutes.userManagement, ...),
//     GoRoute(path: AppRoutes.offline, ...),
//   ],
// )
//
// AppScaffold: Scaffold com BottomNavigationBar de 4 abas.
// Ícones (lucide_icons):
//   Inspeções → LucideIcons.clipboardList
//   Mapa      → LucideIcons.map
//   Laudos    → LucideIcons.fileText
//   Perfil    → LucideIcons.user
```

## REGRAS

- Nunca use strings soltas — sempre `AppRoutes.*`
- Guard ativo desde a Sprint 10
- `teamManagement`, `exportData`, `userManagement`: verificar role no guard
- FAB "Nova Inspeção" vive na `HomeScreen`, não no `AppScaffold`
