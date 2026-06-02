# Vistor AI Mobile — Progress

Arquivo de atualização de todo o desenvolvimento do **Vistor AI Mobile**. Esse documento
foca exclusivamente na camada `mobile`. Para visualizar o `backend`, acesse o [`./PROGRESS.md`](./PROGRESS.md).

---

## Status das Sprints

| Sprint | Descrição | Status | Concluída em |
|---|---|---|---|
| 9 | Setup Mobile (Deps, Theme, App, Router, API, Local, Shared) | ✅ Concluído | 01/06/2026 |
| 10 | Autenticação + Core Services | ✅ Concluído | 02/06/2026 |
| 11 | Home + Lista de Inspeções | ⬜ Pendente | — |
| 12 | Fluxo de Criação de Inspeção | ⬜ Pendente | — |
| 13 | Mapa + Heatmap | ⬜ Pendente | — |
| 14 | Offline + Sincronização | ⬜ Pendente | — |
| 15 | Laudos + PDF Viewer | ⬜ Pendente | — |
| 16 | Gestão de Equipe + Usuários | ⬜ Pendente | — |

---

## Task 01

**Data:** 01/06/2026

**Sprint:** 9 - Setup Mobile
**Sessão:** Configuração de Dependências

### O que foi feito

- Preenchimento do `pubspec.yaml` com todas as dependências de produção (flutter_bloc, go_router, dio, drift, etc).
- Configuração de dependências de desenvolvimento (freezed, mocktail, bloc_test, etc).
- Adição de `dependency_overrides` para resolver conflitos entre as versões estáveis solicitadas e o Flutter SDK.
- Configuração de assets para imagens e fontes.

### Estado dos arquivos tocados

- `mobile/pubspec.yaml` — completo e validado.
- `mobile/pubspec.lock` — gerado via `flutter pub get`.

### Validações que passaram

- `flutter pub get` executado sem erros após ajustes de versão.

---

## Task 02

**Data:** 01/06/2026

**Sprint:** 9 - Setup Mobile
**Sessão:** Código Base (Theme, App, Main)

### O que foi feito

- Implementação do `lib/app/theme.dart` como fonte da verdade de design (cores, estilos, tokens).
- Configuração do `lib/app/app.dart` com `MaterialApp.router`, suporte a Dark Mode e localização (pt-BR).
- Implementação do `lib/main.dart` com inicialização do Hive e stub do Service Locator (GetIt).
- Adição da dependência `flutter_localizations` al `pubspec.yaml`.

### Estado dos arquivos tocados

- `mobile/lib/app/theme.dart` — completo.
- `mobile/lib/app/app.dart` — completo.
- `mobile/lib/main.dart` — completo.

### Validações que passaram

- `flutter analyze` sem erros nos arquivos criados.

---

## Task 03

**Data:** 01/06/2026

**Sprint:** 9 - Setup Mobile
**Sessão:** Navegação e Roteamento (GoRouter)

### O que foi feito

- Implementação do `lib/app/router.dart` com todas as 13 rotas do sistema.
- Configuração de `StatefulShellRoute` para as 4 abas principais: Inspeções, Mapa, Laudos e Perfil.
- Criação do `AppScaffold` com `BottomNavigationBar` utilizando `LucideIcons`.
- Implementação de telas placeholder para todas as rotas para permitir navegação funcional.
- Estrutura do guard de autenticação preparada (comentada) para ativação na Sprint 10.

### Estado dos arquivos tocados

- `mobile/lib/app/router.dart` — completo.
- `mobile/lib/app/app.dart` — atualizado para usar `buildRouter()`.

### Validações que passaram

- `flutter analyze` sem erros. Navegação entre as 4 abas funcionais via placeholders.

---

## Task 04

**Data:** 01/06/2026

**Sprint:** 9 - Setup Mobile
**Sessão:** Comunicação Core API (Dio, JWT, Storage)

### O que foi feito

- Implementação do `ApiClient` utilizando a biblioteca `Dio` para centralizar as requisições HTTP.
- Configuração de interceptores para injeção automática de tokens JWT no header `Authorization`.
- Implementação de lógica de **Refresh Token** automatizada para renovação de sessões expiradas.
- Criação do `TokenStorage` utilizando `FlutterSecureStorage` para armazenamento criptografado de tokens.
- Mapeamento completo dos endpoints do backend em `AppEndpoints`.
- Configuração de variáveis de ambiente (`API_BASE_URL`) via `envied`.

### Estado dos arquivos tocados

- `mobile/lib/core/api/api_client.dart` — completo.
- `mobile/lib/core/api/token_storage.dart` — completo.
- `mobile/lib/core/api/endpoints.dart` — completo.
- `mobile/lib/core/utils/env.dart` — completo.
- `mobile/pubspec.yaml` — atualizado com pins para compatibilidade de build.

### Validações que passaram

- `flutter analyze` sem erros.
- Geração de código `build_runner` concluída com sucesso (`env.g.dart`).
- Teste de instanciação do `ApiClient` validado.

---

## Task 05

**Data:** 01/06/2026

**Sprint:** 9 - Setup Mobile
**Sessão:** Local DB (Drift) e GPS Service

### O que foi feito

- Implementação do `GpsService` com captura de posição, validação de precisão (RN-08) e stream contínuo.
- Configuração do banco de dados local com `Drift` (`AppDatabase`) e tabela `local_inspections` para suporte offline.
- Implementação do `InspectionDao` para persistência local de inspeções pendentes de sincronização.
- Definição de exceções customizadas para falhas de GPS.

### Estado dos arquivos tocados

- `mobile/lib/core/services/gps_service.dart` — completo.
- `mobile/lib/core/local/database.dart` — completo.
- `mobile/lib/core/local/inspection_dao.dart` — completo.

### Validações que passaram

- `flutter analyze` sem erros.
- Geração de código `build_runner` (`database.g.dart`) concluída com sucesso.

---

## Task 06

**Data:** 01/06/2026

**Sprint:** 9 - Setup Mobile
**Sessão:** Sync Manager e Shared Widgets

### O que foi feito

- Implementação do `SyncManager` para sincronização automática de inspeções pendentes ao detectar conexão.
- Criação de widgets compartilhados: `OfflineBanner`, `SyncIndicator`, `LoadingOverlay`.
- Implementação de utilitários para SnackBars de erro e sucesso (`error_snackbar.dart`).
- Integração do `SyncManager` com `connectivity_plus` e `ApiClient`.

### Estado dos arquivos tocados

- `mobile/lib/core/local/sync_manager.dart` — completo.
- `mobile/lib/shared/widgets/offline_banner.dart` — completo.
- `mobile/lib/shared/widgets/sync_indicator.dart` — completo.
- `mobile/lib/shared/widgets/loading_overlay.dart` — completo.
- `mobile/lib/shared/widgets/error_snackbar.dart` — completo.

### Validações que passaram

- `flutter analyze` sem erros.
- Widgets compilam e são integráveis ao AppScaffold/Telas.

---

### ✅ Checklist de conclusão da Sprint 9

| Status | Demandas |
|---|---|
| [✅] | flutter pub get sem conflitos |
| [✅] | flutter analyze lib/ → No issues found |
| [✅] | flutter run → app abre com Splash placeholder |
| [✅] | BottomNav com 4 abas navega sem crash |
| [✅] | GET /health via ApiClient retorna 200 |
| [✅] | build_runner gera os arquivos .g.dart sem erro |
| [✅] | GPS retorna posição no emulador Android |
| [✅] | Drift database cria o arquivo SQLite |
| [✅] | OfflineBanner aparece ao desligar WiFi |
| [✅] | 6 commits + tag v0.9.0-mobile-foundation |
| [✅] | Tabela de controle preenchida (Gemini CLI + 01/06/2026) |
| [✅] | PROGRESS_MOBILE.md atualizado |

---

## Task 07

**Data:** 02/06/2026

**Sprint:** 10 - Autenticação + Core Services
**Sessão:** Feature Auth (Login, Cubit, Repository)

### O que foi feito

- Implementação completa da feature de autenticação:
  - `User` model com Freezed e JSON serializável.
  - `AuthRepository` com login, logout, refresh token e getMe.
  - `AuthCubit` e `AuthState` (Freezed) para gerenciamento de estado reativo.
  - `LoginScreen` seguindo rigorosamente o `LAYOUT.md` (tela 8.1).
  - `LoginForm` com validações de email e senha.
  - `SplashScreen` para o fluxo inicial de carregamento.
- Configuração do `ServiceLocator` (GetIt) para injeção de dependências.
- Integração do `AuthCubit` no `VistorApp` (app level provider).
- Implementação de lógica de redirecionamento dinâmico no `GoRouter` baseada no estado de autenticação.
- Adição do componente `AppLogo` conforme especificação visual.

### Estado dos arquivos tocados

- `mobile/lib/features/auth/data/auth_repository.dart` — completo.
- `mobile/lib/features/auth/domain/auth_cubit.dart` — completo.
- `mobile/lib/features/auth/domain/auth_state.dart` — completo.
- `mobile/lib/features/auth/presentation/login_screen.dart` — completo.
- `mobile/lib/features/auth/presentation/widgets/login_form.dart` — completo.
- `mobile/lib/features/auth/presentation/splash_screen.dart` — completo.
- `mobile/lib/shared/models/user.dart` — completo.
- `mobile/lib/shared/widgets/app_logo.dart` — completo.
- `mobile/lib/core/di/service_locator.dart` — completo.
- `mobile/lib/app/router.dart` — atualizado.
- `mobile/lib/app/app.dart` — atualizado.
- `mobile/lib/main.dart` — atualizado.

### Validações que passaram

- `flutter analyze lib/features/auth/` — sem erros (apenas um info de deprecation).
- Geração de código `build_runner` concluída com sucesso para Freezed e JSON serializável.
- Fluxo de autenticação (Splash -> Login -> Home) preparado e integrado.

