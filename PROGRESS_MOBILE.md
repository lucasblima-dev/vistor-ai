# Vistor AI Mobile — Progress

Arquivo de atualização de todo o desenvolvimento do **Vistor AI Mobile**. Esse documento
foca exclusivamente na camada `mobile`. Para visualizar o `backend`, acesse o [`./PROGRESS.md`](./PROGRESS.md).

---

## Status das Sprints

| Sprint | Descrição | Status | Concluída em |
|---|---|---|---|
| 9 | Setup Mobile (Deps, Theme, App, Router, API, Local, Shared) | ✅ Concluído | 01/06/2026 |
| 10 | Autenticação + Core Services | ⏳ Em andamento | — |
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
- `mobile/lib/shared/widgets/app_logo.dart" — completo.
- `mobile/lib/core/di/service_locator.dart" — completo.
- `mobile/lib/app/router.dart" — atualizado.
- `mobile/lib/app/app.dart" — atualizado.
- `mobile/lib/main.dart" — atualizado.

### Validações que passaram

- `flutter analyze lib/features/auth/` — sem erros (apenas um info de deprecation).
- Geração de código `build_runner` concluída com sucesso para Freezed e JSON serializável.
- Fluxo de autenticação (Splash -> Login -> Home) preparado e integrado.

---

## Task 08

**Data:** 02/06/2026

**Sprint:** 10 - Autenticação + Core Services
**Sessão:** DTOs Freezed (User, Inspection, Media, Report)

### O que foi feito

- Criação dos DTOs principais utilizando `Freezed` e `JsonSerializable`:
  - `User`: Dados do usuário e enums de perfil.
  - `Inspection`: Dados completos de inspeção, GPS, severidade e status.
  - `Media`: Fotos, vídeos e anexos vinculados a inspeções.
  - `Report`: Laudos técnicos gerados.
- Configuração do `analysis_options.yaml` para suporte ao padrão Freezed e exclusão de arquivos gerados da análise.
- Adição de dependências `json_annotation` e `json_serializable` ao `pubspec.yaml`.
- Implementação de testes unitários para validar a serialização JSON dos modelos (`test/shared/models_test.dart`).

### Estado dos arquivos tocados

- `mobile/lib/shared/models/user.dart` — atualizado.
- `mobile/lib/shared/models/inspection.dart` — completo.
- `mobile/lib/shared/models/media.dart` — completo.
- `mobile/lib/shared/models/report.dart` — completo.
- `mobile/analysis_options.yaml` — completo.
- `mobile/test/shared/models_test.dart` — completo.

### Validacões que passaram

- `dart run build_runner build` — concluído sem erros.
- `flutter analyze lib/shared/models/` — No issues found.
- `flutter test test/shared/models_test.dart` — All tests passed!

---

## Task 09

**Data:** 02/06/2026

**Sprint:** 10 - Autenticação + Core Services
**Sessão:** Refatoração e Limpeza de Infraestrutura

### O que foi feito

- Remoção de imports não utilizados em `lib/app/router.dart`.
- Correção de avisos de análise estática:
  - Uso de `super parameters` em `InspectionDao`.
  - Adição de `const` em estados do `AuthCubit`.
  - Substituição do método depreciado `withOpacity` por `withValues` na `SplashScreen`.
- Ajuste de dependências no `pubspec.yaml`:
  - Adição explícita de `path` e `path_provider`.
- Criação dos diretórios de assets (`assets/images/`, `assets/fonts/`) para evitar avisos de build.
- **Consolidação de arquivos `.gitignore` na raiz do projeto, removendo redundâncias em `mobile/`.**
- **Correção de bug crítico no roteamento (`router.dart`) que impedia a saída da Splash Screen para usuários não autenticados.**
- Validação total do projeto com `flutter analyze` retornando zero erros/avisos.

### Estado dos arquivos tocados

- `mobile/lib/app/router.dart` — corrigido e limpo.
- `mobile/lib/core/local/inspection_dao.dart` — refatorado.
- `mobile/lib/features/auth/domain/auth_cubit.dart` — otimizado.
- `mobile/lib/features/auth/presentation/splash_screen.dart` — atualizado.
- `mobile/pubspec.yaml` — dependências corrigidas.
- `mobile/assets/` — estrutura criada.
- `.gitignore` — consolidado na raiz.

### Validações que passaram

- `flutter analyze` — No issues found.
- `flutter test test/shared/models_test.dart` — Passou.
- **Teste manual: App agora redireciona corretamente da Splash para o Login.**

---

## Task 10

**Data:** 02/06/2026

**Sprint:** 10 - Autenticação + Core Services
**Sessão:** Home e Lista de Inspeções (8.2)

### O que foi feito

- Implementação do `InspectionRepository` com suporte a paginação cursor-based e modo offline resiliente.
- Criação do `InspectionCubit` e gerenciamento de estados (initial, loading, loaded, empty, error) via `Freezed`.
- Desenvolvimento da `InspectionListScreen` (Tela 8.2) com busca local, contadores dinâmicos e animações de entrada.
- Criação dos componentes `InspectionCard` (sem border-left) e `SeverityBadge` (fundo sólido) seguindo o rigor do design.
- Integração global do `OfflineBanner` no `AppScaffold` e `SyncIndicator` na AppBar.
- Configuração do `BlocProvider` para `InspectionCubit` no roteamento via `GoRouter`.
- Adição da dependência `intl` para formatação de datas localizada (pt_BR).

### Estado dos arquivos tocados

- `mobile/lib/features/inspection/data/inspection_repository.dart` — completo.
- `mobile/lib/features/inspection/domain/inspection_cubit.dart` — completo.
- `mobile/lib/features/inspection/domain/inspection_state.dart` — completo.
- `mobile/lib/features/inspection/presentation/inspection_list_screen.dart` — completo.
- `mobile/lib/features/inspection/presentation/widgets/inspection_card.dart` — completo.
- `mobile/lib/features/inspection/presentation/widgets/severity_badge.dart` — completo.
- `mobile/lib/app/router.dart` — atualizado com provedores e banners.
- `mobile/pubspec.yaml` — dependência `intl` adicionada.

### Validações que passaram

- `flutter analyze` — No issues found.
- `dart run build_runner build` — Geração de arquivos `.freezed.dart` e `.g.dart` concluída.
- Testes manuais de navegação: Login -> Home funciona com redirecionamento correto.
- Estados de UI validados: Loading, Lista Vazia (EmptyState) e Lista com dados.

---

## Task 11

**Data:** 03/06/2026

**Sprint:** 10 - Autenticação + Core Services
**Sessão:** Cadastro de Novas Contas (Sign-up)

### O que foi feito

- Backend: Adição do endpoint `POST /api/auth/register` para permitir o cadastro público de inspetores.
- Mobile: Implementação completa do fluxo de cadastro:
  - Adição do método `signUp` no `AuthRepository` e `AuthCubit` com suporte a auto-login pós-cadastro.
  - Criação da `RegisterScreen` e `RegisterForm` seguindo os padrões visuais do sistema.
  - Atualização do `GoRouter` para suportar a nova rota `/register` com os devidos redirecionamentos.
  - Inclusão de link para cadastro na `LoginScreen`.

### Estado dos arquivos tocados

- `backend/app/routers/auth.py` — endpoint de registro adicionado.
- `mobile/lib/core/api/endpoints.dart` — AppEndpoints.register adicionado.
- `mobile/lib/features/auth/data/auth_repository.dart` — método signUp adicionado.
- `mobile/lib/features/auth/domain/auth_cubit.dart` — método signUp adicionado.
- `mobile/lib/app/router.dart` — rotas e redirecionamentos atualizados.
- `mobile/lib/features/auth/presentation/login_screen.dart` — link de cadastro adicionado.
- `mobile/lib/features/auth/presentation/register_screen.dart` — criado.
- `mobile/lib/features/auth/presentation/widgets/register_form.dart` — criado.

### Validações que passaram

- `flutter analyze` — No issues found.
- Fluxo de navegação: Login -> Register -> Login (via voltar ou link) funcionando.
- Fluxo de estado: Cadastro dispara loading e redireciona para Home após sucesso.

---

## Task 12

**Data:** 03/06/2026

**Sprint:** 10 - Autenticação + Core Services
**Sessão:** Resolução de Conexão e Refinamento de UX

### O que foi feito

- Resolução de erro crítico de conexão entre o dispositivo físico e o backend via cabo USB.
- Habilitação de `usesCleartextTraffic` no `AndroidManifest.xml` para permitir tráfego HTTP.
- Adição de permissões de Internet e Localização no manifesto principal.
- Correção da geração de variáveis de ambiente: limpeza e rebuild do `build_runner` para garantir que o `API_BASE_URL` reflita o `.env` atual (`localhost:8000`).
- Reversão das mensagens de erro de conexão para um formato genérico e amigável ("Não foi possível conectar ao servidor. Verifique sua conexão.").

### Estado dos arquivos tocados

- `mobile/android/app/src/main/AndroidManifest.xml` — permissões e cleartext adicionados.
- `mobile/lib/features/auth/data/auth_repository.dart` — mensagens de erro padronizadas.
- `mobile/lib/core/utils/env.g.dart` — regenerado com a URL correta.

### Validações que passaram

- Fluxo de cadastro validado em dispositivo físico com sucesso via `adb reverse`.
- Mensagens de erro testadas simulando queda de rede.
- `flutter analyze` — No issues found.

---

## Task 13

**Data:** 03/06/2026

**Sprint:** 10 - Autenticação + Core Services
**Sessão:** Fluxo Completo de Nova Inspeção (Task 10.4)

### O que foi feito

- Implementação do `MediaService` para gerenciamento de upload direto para MinIO com suporte a compressão de imagens > 5MB.
- Criação da `CreateInspectionScreen` seguindo o padrão de formulário scrollável único e Glassmorphism.
- Desenvolvimento do `CreateInspectionCubit` para gerenciar o estado complexo de criação (GPS, Fotos, IA).
- Implementação de widgets especializados: `GlassCard`, `MediaPickerSheet` (Camera/Galeria) e `AiResultCard` (Resultado da IA).
- Adição de animação de pulso no GPS e validação de precisão (RN-08).
- Integração do fluxo: Cadastro de inspeção -> Captura GPS -> Upload de fotos -> Classificação automática via IA -> Confirmação.
- Atualização do `InspectionRepository` e `InspectionDao` para suporte a `getById` e atualizações locais/remotas.

### Estado dos arquivos tocados

- `mobile/lib/core/services/media_service.dart` — criado.
- `mobile/lib/features/inspection/presentation/create_inspection_screen.dart` — implementado.
- `mobile/lib/features/inspection/domain/create_inspection_cubit.dart` — implementado.
- `mobile/lib/features/inspection/presentation/widgets/media_picker_sheet.dart` — implementado.
- `mobile/lib/features/inspection/presentation/widgets/ai_result_card.dart` — implementado.
- `mobile/lib/shared/widgets/glass_card.dart` — criado.
- `mobile/lib/core/di/service_locator.dart` — serviços registrados.
- `mobile/lib/app/router.dart` — rotas atualizadas.
- `mobile/lib/features/inspection/presentation/inspection_list_screen.dart` — refresh após criação adicionado.

### Validações que passaram

- `flutter analyze` — No issues found.
- Implementação da lógica de UI e integração com MediaService concluída.
- Geração de código via `build_runner` validada.
- **Pronto para validação manual do fluxo completo e da classificação de IA.**
