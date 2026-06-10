# Vistor AI Mobile — Progress

Arquivo de atualização de todo o desenvolvimento do **Vistor AI Mobile**. Esse documento
foca exclusivamente na camada `mobile`. Para visualizar o `backend`, acesse o [`./PROGRESS.md`](./PROGRESS.md).

---

## Status das Sprints

| Sprint | Descrição | Status | Concluída em |
|---|---|---|---|
| 9 | Setup Mobile foundation | ✅ Concluído | 01/06/2026 |
| 10 | Auth + Home + Nova Inspeção | ✅ Concluído | 04/06/2026 |
| 11 | Detalhe da Inspeção + Gerar Laudo | ✅ Concluído | 09/06/2026 |
| 12 | Mapa + Heatmap | ✅ Concluído | 09/06/2026 |
| 13 | Laudos + Perfil + Offline | ⬜ Pendente | — | — |
| 14 | Gestão de Equipe + Exportar + Usuários | ⬜ Pendente | — | — |

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
- `mobile/lib/app/app.dart" — completo.
- `mobile/lib/main.dart" — completo.

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
- `mobile/lib/shared/models/user.dart" — completo.
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
- Adição de dependências `json_annotation` e `json_serializable` al `pubspec.yaml`.
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
- `mobile/lib/pubspec.yaml` — dependências corrigidas.
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
- `mobile/lib/pubspec.yaml` — dependência `intl` adicionada.

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
- `mobile/lib/core/utils/env.g.dart" — regenerado com a URL correta.

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
- **Fluxo completo validado manualmente:** criação de inspeção, captura de GPS com endereço, upload de fotos e classificação por IA funcionando conforme esperado.
- **Correção técnica:** Adição do campo `title` e suporte a miniaturas na lista inicial validados.

---

## Task 14

**Data:** 04/06/2026

**Sprint:** 10 - Autenticação + Core Services
**Sessão:** Guard de Autenticação e Testes Unitários (Task 10.5)

### O que foi feito

- Ativação do **Guard de Autenticação** no `GoRouter` para redirecionamento automático (Login <-> Home).
- Refatoração do `AppScaffold` e `Router` para utilizar `context.read<AuthCubit>()` no gerenciamento de acesso.
- Configuração do `MultiBlocProvider` global no `lib/app/app.dart`, injetando `AuthCubit` e `InspectionCubit`.
- Implementação de lógica de verificação automática de sessão (`checkAuth`) na inicialização do app.
- Criação de suíte de testes unitários para `AuthCubit` (Login, Logout, Erros).
- Criação de suíte de testes unitários para `InspectionCubit` (Carga de lista, Lista vazia, Erros).
- Utilização de `mocktail` para mocks de repositório e `bloc_test` para validação de estados.

### Estado dos arquivos tocados

- `mobile/lib/app/app.dart` — MultiBlocProvider e checkAuth adicionados.
- `mobile/lib/app/router.dart` — Guard ativado e simplificado.
- `mobile/test/features/auth/auth_cubit_test.dart` — Suíte de testes criada.
- `mobile/test/features/inspection/inspection_cubit_test.dart` — Suíte de testes criada.

### Validações que passaram

- **6 testes unitários aprovados** com 100% de sucesso.
- Redirecionamento automático validado: Usuário deslogado é enviado para `/login`.
- `flutter analyze` — No issues found.

---

### ✅ Checklist de conclusão da Sprint 10

| Status | Demandas |
|---|---|
| [✅] | Login com usuário real → redireciona para Home |
| [✅] | Home exibe inspeções do banco com InspectionCard correto |
| [✅] | SeverityBadge com fundo sólido (não fundo claro) |
| [✅] | Fluxo completo: Nova Inspeção → GPS → Foto → IA → lista atualizada |
| [✅] | AiResultCard: score < 0.55 desabilita botão Confirmar |
| [✅] | Guard: sem token → Login; com token → Home |
| [✅] | 6 testes de Cubit passando |
| [✅] | 5 commits + tag v0.10.0-core-flow |
| [✅] | Tabela de controle preenchida (Gemini CLI + 04/06/2026) |
| [✅] | PROGRESS.md atualizado |

---

## Task 15

**Data:** 05/06/2026

**Sprint:** 11 - Detalhe de Inspeção + Gerar Laudo
**Sessão:** Detalhe da Inspeção (11.1)

### O que foi feito

- Implementação da tela `InspectionDetailScreen` utilizando `CustomScrollView` e `SliverAppBar` pinned (260dp).
- Configuração de `FlexibleSpaceBar` com gradient overlay, título dinâmico e `SeverityBadge` em tamanho grande.
- Implementação do widget `StatusTimeline` vertical para visualização do histórico de eventos da inspeção.
- Criação do `InspectionDetailCubit` e `InspectionDetailState` para gerenciamento de estado granular (detalhe, histórico, report).
- Integração da animação `Hero` entre `InspectionCard` e `InspectionDetailScreen` (tag `inspection-{id}`).
- Implementação da `InfoGrid` 2x2 com ícones `LucideIcons` para Localização, Categoria, Data e Inspetor.
- Adição da seção de "Análise de IA" com `LinearProgressIndicator` colorido conforme score e botões de Confirmar/Corrigir.
- Configuração de bottom bar fixa para geração de laudo PDF (habilitada apenas para status `in_progress` ou `resolved`, cumprindo RN-05).
- Atualização do `InspectionRepository` com métodos `getHistory` e `generateReport`.

### Estado dos arquivos tocados

- `mobile/lib/features/inspection/presentation/inspection_detail_screen.dart` — completo.
- `mobile/lib/features/inspection/presentation/widgets/status_timeline.dart` — completo.
- `mobile/lib/features/inspection/domain/inspection_detail_cubit.dart` — completo.
- `mobile/lib/features/inspection/domain/inspection_detail_state.dart` — completo.
- `mobile/lib/features/inspection/presentation/widgets/inspection_card.dart` — navegação e Hero adicionados.
- `mobile/lib/features/inspection/presentation/widgets/severity_badge.dart` — suporte a `isLarge` adicionado.
- `mobile/lib/shared/models/audit_log.dart` — criado.
- `mobile/lib/core/di/service_locator.dart` — Cubit registrado.
- `mobile/lib/app/router.dart` — rota `/:id` configurada com Provider.

### Validadores que passaram

- `flutter analyze` — No issues found!
- `build_runner` — Geração de código Freezed e JSON concluída.
- Ciclo de navegação (Tap Card -> Detalhe) validado arquiteturalmente.

---

## Task 16

**Data:** 09/06/2026

**Sprint:** 11 - Detalhe da Inspeção + Gerar Laudo
**Sessão:** Feature de Laudos Técnicos e Refinamentos de UI

### O que foi feito

- **Backend:**
  - Implementação do endpoint `GET /api/reports/` para listagem de laudos.
  - Correção de URLs de mídia para o WeasyPrint utilizando endereços internos da rede Docker (`minio:9000`).
  - Adição do serviço `get_internal_presigned_download_url`.
- **Mobile - Feature Report:**
  - Implementação do `ReportRepository` com suporte a polling para geração assíncrona.
  - Criação do `ReportCubit` e gerenciamento de estados (`loading`, `generating`, `loaded`, `error`).
  - Desenvolvimento da `ReportListScreen` com campo de busca e listagem paginada.
  - Criação da `ReportViewerScreen` com download via Dio e integração nativa via `open_filex`.
  - Widget `_HashBadge` para exibição do hash SHA-256 com fonte `JetBrains Mono`.
- **Mobile - Refinamentos:**
  - Adição de **Filter Chips** (Status e Severidade) na lista de inspeções.
  - Implementação de indicadores de status visual nos cards de inspeção.
  - Refatoração da Bottom Bar no detalhe para suportar o fluxo "Iniciar Inspeção" -> "Gerar Laudo".
  - Melhoria no `AiResultCard` com visualização de score e botões de ação simplificados.

### Estado dos arquivos tocados

- `backend/app/routers/reports.py` — endpoint de listagem adicionado.
- `mobile/lib/features/report/` — estrutura completa da feature (data, domain, presentation).
- `mobile/lib/features/inspection/presentation/` — filtros e melhorias de UI.
- `mobile/lib/shared/models/report.dart` — campo `download_url` adicionado.

### Validações que passaram

- `flutter analyze` — No issues found.
- Fluxo de geração de laudo validado: trigger -> polling -> download -> open nativo.
- Filtros de inspeção funcionando reativamente no Cubit.

### ✅ Checklist de conclusão da Sprint 11

- [✅] Tap em card → detalhe com SliverAppBar hero photo
- [✅] Timeline exibe histórico de status com dots coloridos
- [✅] Botão "Gerar Laudo" desabilitado para inspeções abertas
- [✅] Geração de laudo → PDF abre no visualizador nativo
- [✅] Tela de Laudos lista laudos com hash JetBrains Mono
- [✅] 2 commits + tag v0.11.0-inspection-report
- [✅] Tabela de controle preenchida (Kaio + 09/06/2026)
- [✅] PROGRESS_MOBILE.md atualizado

---

## Task 17

**Data:** 09/06/2026

**Sprint:** 12 - Mapa + Heatmap
**Sessão:** 12.1 — Map repository + Map cubit

### O que foi feito

- **Modelagem:**
  - Criação do modelo `HeatmapPoint` para representação de dados de calor.
  - Definição do `MapData` e `MapState` utilizando Freezed, com suporte a múltiplas camadas (marcadores/heatmap).
- **Data Layer:**
  - Implementação do `MapRepository` com integração aos endpoints `/geo/nearby` (inspeções próximas) e `/geo/export` (GeoJSON para heatmap).
  - Lógica de parsing de GeoJSON para `HeatmapPoint` com pesos baseados na severidade.
- **Domain Layer:**
  - Implementação do `MapCubit` com carregamento paralelo (`Future.wait`) para otimização de performance.
  - Funcionalidade de alternância de camadas (`toggleLayer`) e atualização dinâmica de raio de busca (`updateRadius`).
- **Infraestrutura:**
  - Registro do `MapRepository` e `MapCubit` no Service Locator (GetIt).
  - Injeção global do `MapCubit` no `MultiBlocProvider` da aplicação.
- **Geração de Código:**
  - Execução do `build_runner` para geração de arquivos `.freezed.dart`.

### Validações que passaram

- `flutter analyze lib/features/map/` — No issues found.
- Código estruturado seguindo os princípios de separação de responsabilidades (Feature-First).

---

## Task 18

**Data:** 09/06/2026

**Sprint:** 12 - Mapa + Heatmap
**Sessão:** 12.2 — Map screen + markers + bottom sheet

### O que foi feito

- **UI do Mapa:**
  - Implementação do `MapScreen` com o `FlutterMap` usando `TileLayer` do OpenStreetMap e `MarkerClusterLayerWidget`.
  - Construção da interface com o estilo *glassmorphism* (botão "Filtrar Mapa") e controles flutuantes com sombras e cores exatas do Design System.
  - Implementação da `DraggableScrollableSheet` contendo uma lista horizontal para inspeções próximas (NearbyCard).
- **Componentes:**
  - Criação do `InspectionMarker`, um ícone *tear-drop* que reflete a severidade da inspeção, com suporte a popup/dialog mostrando a *thumbnail* e botão para "Ver detalhes".
  - Implementação do `MapFilterSheet` (bottom sheet) com slider para controle de raio (`_currentRadius`) e `FilterChip` dinâmicos para `Severidade` e `Status`.
  - Criação do `NearbyCard` com exibição concisa de detalhes da inspeção e indicação colorida (borda esquerda) conforme severidade.
- **Integração:**
  - `MapCubit` totalmente integrado à tela, lidando com alternância de `activeLayer` (entre marcadores e heatmap).
  - Controle de clusters (`flutter_map_marker_cluster`) para agregação de pins num certo raio com *zoom-out*.

### Validações que passaram

- `flutter analyze lib/features/map/` — No issues found.
- Correção de `deprecated_member_use` de `.withOpacity` para `.withValues` validada e aplicada.
- Redirecionamento `NearbyCard` → `/inspections/:id` devidamente configurado via GoRouter.

---

## Task 19

**Data:** 09/06/2026

**Sprint:** 12 - Mapa + Heatmap
**Sessão:** 12.3 — Heatmap CustomPainter

### O que foi feito

- **HeatmapLayer:**
  - Implementação de um `StatelessWidget` utilizando a API moderna do `flutter_map` v6 (acessando via `MapCamera.of(context)`).
  - Utilização da classe `CustomPainter` nativa do Flutter para desenhar os blobs de temperatura.
- **Lógica de Desenho:**
  - Limite de iteração aos top 200 pontos para performance e preservação de FPS na renderização contínua.
  - Conversão de `LatLng` para pixels da tela feita através de `MapCamera.latLngToScreenPoint`.
  - Desenho de cada blob com base no nível de severidade usando `RadialGradient` com `BlendMode.screen` e centros transparentes nas bordas.
  - Ajuste de opacidade da camada toda (`Opacity` widget = 0.7) para deixar os *tiles* de mapa visíveis ao fundo, conforme exigido.
- **Integração no MapScreen:**
  - O layer agora responde com sucesso aos estados cicláveis do `toggleLayer` do `MapCubit` (marcadores, heatmap, ou ambos simultâneos).

### Validações que passaram

- `flutter analyze lib/features/map/` — No issues found.
- As três camadas (Markers, Heatmap, Both) funcionam de forma intercalada sem sobreposição de estado indesejada.
- Total ausência de pacotes adicionais para a geração do heatmap, mantendo o bundle otimizado.

### ✅ Checklist de conclusão da Sprint 12

- [✅] `MapRepository` consome `getNearby` e converte para `Inspection`
- [✅] `MapRepository` consome `getHeatmapData` e converte GeoJSON para `HeatmapPoint`
- [✅] `MapCubit` implementado com suporte a refresh, raio e mudança de layers (`MapActiveLayer`)
- [✅] Tela principal `MapScreen` estruturada com `FlutterMap`
- [✅] `MarkerClusterLayerWidget` integra-se com pins customizados baseados na Severidade (`InspectionMarker`)
- [✅] Aba de Controle Lateral com *glassmorphism*, botões com estados Dark/Light adaptáveis e interações de zoom
- [✅] Modal interativo (`DraggableScrollableSheet`) construído contendo `NearbyCard` listados verticalmente (100% largura) com fallback do endereço e roteamento
- [✅] Componente puro `HeatmapLayer` criado desenhando pontos sobre a camada usando `BlendMode.screen` e `RadialGradient` no `CustomPainter`
- [✅] 3 commits + tag v0.12.0-map
- [✅] Tabela de controle preenchida
- [✅] PROGRESS_MOBILE.md atualizado

