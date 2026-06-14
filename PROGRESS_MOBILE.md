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
| 13 | Laudos + Perfil + Offline | ✅ Concluído | 09/06/2026 |
| 14 | Gestão de Equipe + Exportar + Usuários | ✅ Concluído | 13/06/2026 |

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
- `mobile/lib/app/router.dart" — atualizado com provedores e banners.
- `mobile/lib/pubspec.yaml" — dependência`intl` adicionada.

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

---

## Task 20

**Data:** 09/06/2026

**Sprint:** 13 - Laudos + Perfil + Offline
**Sessão:** 13.1 — Profile Screen

### O que foi feito

- Implementação da `ProfileScreen` seguindo o Layout 8.5 do `LAYOUT.md`.
- Criação do `ThemeService` com Hive para persistência da preferência de tema (Dark/Light/System).
- Integração do `ValueNotifier<ThemeMode>` no `service_locator.dart` e `app.dart` para troca de tema reativa.
- Exibição de dados reais do usuário (`AuthCubit`) e cargo dinâmico no header premium com gradiente.
- Seção de sincronização com contador de pendências em tempo real via `StreamBuilder`.
- Fluxo de logout com `BottomSheet` de confirmação e limpeza de estado.

### Validações que passaram

- Troca de tema funciona instantaneamente sem perda de estado de navegação.
- Logout redireciona corretamente para a tela de login.

---

## Task 21

**Data:** 09/06/2026

**Sprint:** 13 - Laudos + Perfil + Offline
**Sessão:** 13.2 — Offline Screen

### O que foi feito

- Implementação da `OfflineScreen` seguindo o Layout 8.12 com ícones amber e animação `Pulse`.
- Atualização do `GoRouter` (`router.dart`) com lógica de redirecionamento para funcionalidades dependentes de rede (Mapa, Laudos, Gestão) quando não há conexão.
- Garantia de acesso offline à Home (Minhas Inspeções) para consulta de dados em cache.
- Refatoração do `SyncManager` para assegurar o envio de todos os campos obrigatórios na sincronização.
- Correção de bug no roteador que reiniciava a navegação durante a alteração de tema.

### Validações que passaram

- Redirecionamento automático para a tela Offline ao tentar acessar Mapa/Laudos sem internet.
- Sincronização manual via Perfil com feedback de `SnackBar`.
- Animação de `sparkles` pulsando corretamente.

---

## Task 22

**Data:** 09/06/2026

**Sprint:** 13 - Laudos + Perfil + Offline
**Sessão:** 13.3 — SyncManager + Notificações Push

### O que foi feito

- **SyncManager Finalizado:** Adição do `pendingCountStream` e callback `onSyncSuccess`. O upload agora inclui todos os metadados necessários (GPS, endereço, título).
- **Integração FCM (Push):** Implementação do `NotificationService` utilizando apenas `firebase_messaging`. Configuração de handlers para mensagens em primeiro plano, background e cliques (deep-link para detalhes da inspeção).
- **Backend:** Adição da coluna `fcm_token` no modelo `User` e criação do endpoint `PATCH /api/users/me/fcm-token` para registro dinâmico.
- **Fluxo de Auth:** Atualização do `AuthCubit` para registrar o token FCM automaticamente após login ou verificação de sessão.
- **Feedback Reativo:** O Perfil agora exibe `SnackBar` de sucesso após sincronização automática ou manual e atualiza o badge de pendências via stream.

### Validações que passaram

- Token FCM é enviado corretamente ao backend no login.
- Clique em notificação redireciona para a tela de detalhe da inspeção correta.
- Badge de pendências reflete o estado do banco local instantaneamente.

---

### ✅ Checklist de conclusão da Sprint 13

```
[✅] Perfil exibe nome, email e papel do usuário autenticado
[✅] Toggle tema (sol/lua) funciona em ambas as direções
[✅] Badge "N Pendentes" atualiza em tempo real
[✅] Logout limpa tokens e redireciona para Login
[✅] Tela Offline renderiza em light e dark
[✅] Push notification ao criar inspeção crítica
[✅] 3 commits + tag v0.13.0-profile-offline
[✅] Tabela de controle preenchida (Kaio + 09/06/2026)
[✅] PROGRESS_MOBILE.md atualizado
```

---

## Task 23

**Data:** 10/06/2026

**Sprint:** X - Ciclo de Vida da Inspeção & IA (Lucas)
**Sessão:** X.X — Ciclo de Vida, Reavaliação de IA & Visualização Póstuma

### O que foi feito

- **Backend:**
  - Criação do endpoint `POST /api/inspections/{id}/reclassify` em `routers/inspections.py` para re-processar a classificação por IA de forma síncrona.
  - Implementação da lógica no serviço `reclassify` (`services/inspection_service.py`) validando a presença de fotos confirmadas.
  - Criação de caso de teste unitário `test_reclassify_no_photos` em `tests/test_inspections.py`.
- **Mobile - Ciclo de Vida da Inspeção:**
  - Redesenho da barra inferior `_buildBottomBar` no detalhe de inspeção (`InspectionDetailScreen`) para gerenciar as transições de status:
    - Estado `open`: Iniciar Inspeção (muda para `in_progress`).
    - Estado `in_progress`: Finalizar (muda para `resolved`) com validação de fotos (RN-01), Arquivar (muda para `archived`) e Gerar Laudo Parcial.
    - Estado `resolved`: Gerar Laudo Técnico e Arquivar.
  - Adição do status `archived` nos chips de filtro e na lógica do `InspectionListScreen`.
- **Mobile - Reavaliação de IA & Fallbacks:**
  - Integração do endpoint de reclassificação no repositório mobile (`reclassify`) e criação do método `reevaluateWithAi` no `InspectionDetailCubit`.
  - Adição do booleano `isReevaluating` ao `InspectionDetailState` (geração de código pelo `build_runner` concluída com sucesso).
  - Melhoria de UX no card de IA do detalhe para exibir erro e o botão de "Reavaliar com IA" se a análise falhar, além do botão de "Definir Manual" para fallback manual.
  - Modificação do fluxo de criação (`CreateInspectionCubit.submit`) para capturar falhas ou timeouts no processamento de IA e prosseguir sem bloquear o usuário.
- **Mobile - Visualização Póstuma:**
  - Desenvolvimento da tela `ArchivedInspectionsScreen` que lista ocorrências resolvidas ou arquivadas em modo somente-leitura.
  - Adição da rota `/profile/archive` no `router.dart` e do respectivo botão de navegação na `ProfileScreen`.
  - Tratamento da flag `readOnly` no detalhe de inspeção para desativar botões de IA e ocultar a barra de ações.

### Estado dos arquivos tocados

- `backend/app/routers/inspections.py` — endpoint de reclassificação adicionado.
- `backend/app/services/inspection_service.py` — lógica do service adicionada.
- `backend/app/tests/test_inspections.py` — teste unitário adicionado.
- `mobile/lib/core/api/endpoints.dart` — rota de reclassificação mapeada.
- `mobile/lib/features/inspection/data/inspection_repository.dart` — método de repositório `reclassify` adicionado.
- `mobile/lib/features/inspection/domain/` — `InspectionDetailCubit` e `InspectionDetailState` atualizados com reavaliação de IA.
- `mobile/lib/features/inspection/presentation/inspection_detail_screen.dart` — lógica de UI de ações, IA e somente-leitura.
- `mobile/lib/features/inspection/presentation/widgets/status_timeline.dart` — timeline enriquecida com logs de IA e severidade.
- `mobile/lib/features/inspection/presentation/archived_inspections_screen.dart` — criado.
- `mobile/lib/app/router.dart` — rotas do arquivo e flag `readOnly` adicionadas.
- `mobile/lib/features/auth/presentation/profile_screen.dart` — botão para o arquivo adicionado.

### Validações que passaram

- `flutter analyze` — No issues found!
- `build_runner` — Geração de código Freezed e JSON concluída.

---

## Task 24

**Data:** 13/06/2026

**Sprint:** 14 - Gestão de Equipe + Exportar + Usuários
**Sessão:** 14.1 — Team Management Screen

### O que foi feito

- **Backend:**
  - Adição de rotas CRUD em `app/routers/users.py` para listagem de usuários com filtros de `role` e `is_active` (`GET /api/users`), e atualização de role/status de atividade (`PATCH /api/users/{user_id}`).
  - Adição de validação para impedir que um administrador desative a própria conta.
- **Mobile - Gestão de Equipe (Sessão 14.1):**
  - Criação da tela de gestão de equipe em `features/inspection/presentation/team_management_screen.dart` conforme especificações de layout (Header com gradiente e contador dinâmico, lista de cartões com dot pulsante para inspeções críticas e botão para atribuição).
  - Implementação do bottom sheet de atribuição `AssignInspectorSheet` em `features/inspection/presentation/widgets/assign_inspector_sheet.dart` listando inspetores ativos e permitindo atribuição rápida.
  - Implementação do `UserRepository` em `features/auth/data/user_repository.dart` para comunicação com os endpoints do backend.
  - Criação do `TeamManagementCubit` e `TeamManagementState` com Freezed para gerenciar o estado da fila de atribuição.
  - Atualização do `router.dart` para registrar a rota `/team`, direcionando para `TeamManagementScreen`, e implementação do redirecionamento baseado em roles (RBAC) para garantir que apenas gestores e administradores acessem rotas administrativas.
  - Registro dos serviços e Cubits no `service_locator.dart`.

### Estado dos arquivos tocados

- `backend/app/routers/users.py` — completo.
- `mobile/lib/features/auth/data/user_repository.dart` — criado.
- `mobile/lib/features/inspection/domain/team_management_state.dart` — criado.
- `mobile/lib/features/inspection/domain/team_management_cubit.dart` — criado.
- `mobile/lib/features/inspection/presentation/team_management_screen.dart` — criado.
- `mobile/lib/features/inspection/presentation/widgets/assign_inspector_sheet.dart` — criado.
- `mobile/lib/core/di/service_locator.dart` — atualizado.
- `mobile/lib/app/router.dart` — updated.

### Validações que passaram

- `flutter analyze` — No issues found!
- `build_runner` — Geração de código Freezed e JSON concluída.

---

## Task 25

**Data:** 13/06/2026

**Sprint:** 14 - Gestão de Equipe + Exportar + Usuários
**Sessão:** 14.2 — Export Data Screen

### O que foi feito

- **Mobile - Exportação de Dados (Sessão 14.2):**
  - Criação da tela de exportação em `features/map/presentation/export_data_screen.dart` seguindo a especificação visual do LAYOUT.md (Card de Período, Toggle Chips para filtrar status de resolvidas/abertas/críticas, e FormatCards para escolher GeoJSON ou CSV).
  - Implementação do método `exportData` no `MapRepository` para se comunicar com o endpoint `GET /api/geo/export` enviando os filtros de formato, status e severidade.
  - Implementação do fluxo de gravação local do arquivo via `path_provider` em segundo plano para não bloquear a UI, informando o sucesso na snackbar.
  - Atualização do `router.dart` para registrar e importar a tela `ExportDataScreen` na rota `/export`.

### Estado dos arquivos tocados

- `mobile/lib/features/map/data/map_repository.dart` — atualizado.
- `mobile/lib/features/map/presentation/export_data_screen.dart` — criado.
- `mobile/lib/app/router.dart` — atualizado.

### Validações que passaram

- `flutter analyze` — No issues found!

---

## Task 26

**Data:** 13/06/2026

**Sprint:** 14 - Gestão de Equipe + Exportar + Usuários
**Sessão:** 14.3 — User Management Screen

### O que foi feito

- **Mobile - Gestão de Usuários (Sessão 14.3):**
  - Criação da tela de gestão de usuários em `features/auth/presentation/user_management_screen.dart` conforme especificações visuais do LAYOUT.md (ícone de escudo com título e badge Admin, barra de pesquisa local responsiva, e ListView de UserCards).
  - Implementação do `UserCard` apresentando CircleAvatar customizado por papel e status do usuário (ícone `userX` vermelho se inativo), nome, e-mail, badge do papel em CAPSLOCK, e menu popup para ações administrativas.
  - Implementação das ações administrativas: alterar papel (Admin, Gestor, Inspetor) e habilitar/desativar a conta do usuário.
  - Implementação de regras de segurança na UI: o administrador logado não pode desativar a própria conta no PopupMenu.
  - Criação do `UserManagementCubit` e `UserManagementState` com Freezed para gerenciar o estado da listagem, busca e atualizações.
  - Atualização do `router.dart` para importar a tela `UserManagementScreen` e mapeá-la na rota `/users`.

### Estado dos arquivos tocados

- `mobile/lib/features/auth/domain/user_management_state.dart` — criado.
- `mobile/lib/features/auth/domain/user_management_cubit.dart` — criado.
- `mobile/lib/features/auth/presentation/user_management_screen.dart` — criado.
- `mobile/lib/core/di/service_locator.dart` — atualizado.
- `mobile/lib/app/router.dart` — atualizado.

### Validações que passaram

- `flutter analyze` — No issues found!
- `build_runner` — Geração de código Freezed e JSON concluída.

---

## Task 27

**Data:** 13/06/2026

**Sprint:** 14 - Gestão de Equipe + Exportar + Usuários
**Sessão:** 14.4 — Testes de widget + análise final

### O que foi feito

- **Mobile - Testes de Widget e Estabilidade (Sessão 14.4):**
  - Criação de testes de widget para `SeverityBadge` em `test/widgets/severity_badge_test.dart` validando as cores de fundo e texto para todas as severidades (crítico, moderado, baixo, pendente).
  - Criação de testes de widget para `AiResultCard` em `test/widgets/ai_result_card_test.dart` validando se o botão "Confirmar" está habilitado apenas se a confiança for maior ou igual a 0.55.
  - Criação de testes de widget para `InspectionCard` em `test/widgets/inspection_card_test.dart` validando o layout (sem border-left), presença do badge de severidade e comportamento de navegação (pop do roteador assíncrono para concluir o callback `onTap`).
  - Correção de testes de unidade quebrados em `auth_cubit_test.dart` (mock do helper `updateFcmToken` e do cache de usuário `saveUser`) e em `models_test.dart` (atualização do payload de parse JSON do modelo `Inspection` para conter `title` e `location`).
  - Execução e validação das ferramentas estáticas (`flutter analyze` com zero warnings) e da suíte de testes (`flutter test` com todos os 21 testes passando com sucesso).

### Estado dos arquivos tocados

- `mobile/test/widgets/severity_badge_test.dart` — criado.
- `mobile/test/widgets/ai_result_card_test.dart` — criado.
- `mobile/test/widgets/inspection_card_test.dart` — criado.
- `mobile/test/features/auth/auth_cubit_test.dart` — atualizado.
- `mobile/test/shared/models_test.dart` — atualizado.

### Validações que passaram

- `flutter analyze` — No issues found!
- `flutter test` — All 21 tests passed!

---

### ✅ Checklist de conclusão da Sprint 14 — Mobile feature-complete

```
[✅] Team Management: fila de atribuição e assign inspector funcionam
[✅] Export: GeoJSON e CSV baixados no dispositivo
[✅] User Management: avatares coloridos, desativar/reativar funciona
[✅] flutter analyze lib/ → No issues found
[✅] flutter test test/ → All tests passed
[✅] Dark mode: todas as telas testadas
[✅] PROGRESS_MOBILE.md atualizado com data de conclusão
[✅] SPRINTS_MOBILE.md: todas as sprints marcadas ✅
```

---

## Task 28

**Data:** 14/06/2026

**Sprint:** 14 - Gestão de Equipe + Exportar + Usuários
**Sessão:** 14.5 — Correções e Refinamentos de Usabilidade Mobile (Laudos, GPS e UI)

### O que foi feito

- **Geocoding & Local Bias (Manual):**
  - Implementada busca manual com priorização de resultados (local bias) com base na cidade e estado atual do usuário.
  - Adicionado ordenamento por proximidade (distância) dos resultados obtidos quando há múltiplas localizações retornadas pela busca manual, selecionando o campus/ponto mais próximo.
  - Atualizada a tela de criação (`CreateInspectionScreen`) para exibir coordenadas e endereço aproximado como `readOnly: true`, evitando edição direta no teclado.
  - Adicionado botão "Manual" que abre um popup dialog com input de endereço para atualizar a localização de forma assistida.
  - Ajustado o `CreateInspectionCubit.captureGps` e `searchCoordinatesFromAddress` para forçar a precisão do GPS para `15.0m` (atendendo à restrição RN-08 de raio de 50m) e prevenir alertas de baixa precisão no emulador.
- **Visualização e Busca de Laudos:**
  - Garantido o ordenamento em formato de Pilha (mais recentes primeiro) na listagem de laudos técnicos da aba de laudos.
  - Corrigido o bug do cursor de seleção nos inputs de busca e de formulários através do isolamento de estado utilizando `ValueNotifier` e `ValueListenableBuilder`. Isso impede que o `TextField` perca a seleção ou selecione a palavra toda a cada alteração de caractere.
  - Adicionado seletor de data (DatePicker) na AppBar da busca de laudos para filtrar ocorrências por uma data selecionada de forma amigável.
  - Formatada a data de exibição dos laudos para o fuso horário local PT-BR (Brasília, GMT-3) exibindo explicitamente a sigla `BRT`.
  - Exibição correta do nome do usuário gerador (`generatorName` retornado pela API) no card de laudos no lugar do UUID/hash.
- **UI & Efeitos Visuais (Detalhes da Inspeção):**
  - Criada uma barra de cabeçalho flutuante no topo com efeito de desfoque (`BackdropFilter` de 10px / Glassmorphism) que surge gradualmente ao rolar a tela de detalhes para baixo.
  - Ocultada a representação do título no `SliverAppBar` quando recolhido para evitar que o título e badges de severidade e status colidam com a seta de voltar, posicionando-os de forma limpa e lado a lado na barra flutuante.
  - Reposicionada a resposta da IA (`AiResultCard`) na criação de inspeções para aparecer abaixo do botão principal de submissão ("Criar Inspeção em Campo").

### Estado dos arquivos tocados

- `mobile/lib/features/inspection/domain/create_inspection_cubit.dart` — atualizado.
- `mobile/lib/features/inspection/presentation/create_inspection_screen.dart` — atualizado.
- `mobile/lib/features/inspection/presentation/inspection_detail_screen.dart` — atualizado.
- `mobile/lib/features/report/presentation/report_list_screen.dart` — atualizado.
- `mobile/test/widgets/ai_result_card_test.dart` — atualizado.

### Validações que passaram

- `flutter analyze` — No issues found!

---

## Task 29

**Data:** 14/06/2026

**Sprint:** 14 - Gestão de Equipe + Exportar + Usuários
**Sessão:** 14.6 — Resiliência do Mapa, Timeouts e Sugestões da Localização Manual

### O que foi feito

- **Resiliência do Mapa (`map_cubit.dart` e `map_screen.dart`):**
  - Corrigido o erro de import da classe `Geolocator` em `map_cubit.dart` que causava falha de compilação/tela vermelha ao carregar o mapa.
  - Otimizada a inicialização de GPS no `MapCubit` priorizando o `getLastKnownPosition` (retorno imediato) e reduzindo o timeout de `getCurrentPosition` para 4 segundos para evitar travamento da tela.
  - Corrigido o fallback do centro inicial do mapa no `map_screen.dart` (não inicia mais na coordenada nula `(0, 0)` no oceano, mas sim em Natal, RN como padrão e move a câmera de forma assíncrona para a localização conhecida do usuário).
- **Correção no Cubit de Inspeção (`create_inspection_cubit.dart`):**
  - Corrigido erro de tipagem no construtor de `Position` de fallback no geocoding (removido const e substituído `timestamp: null` por `timestamp: DateTime.now()`).
- **Diálogo de Sugestões de Localização Manual (`create_inspection_screen.dart`):**
  - Refatorado o popup "Manual" para funcionar como uma busca ativa de endereços com sugestões interativas ("estilo Uber").
  - O popup apresenta um indicador de carregamento e lista até 4 candidatos de endereços retornados pelo Geocoding, ordenados pela menor distância do usuário (se a posição for conhecida).
  - Adicionado suporte a fallbacks seguros (permitindo usar o endereço literal digitado mesmo se offline ou em caso de falha de rede/serviço da API do geocoding), impedindo o bloqueio do usuário.

### Estado dos arquivos tocados

- `mobile/lib/features/map/domain/map_cubit.dart` — atualizado.
- `mobile/lib/features/map/presentation/map_screen.dart` — atualizado.
- `mobile/lib/features/inspection/domain/create_inspection_cubit.dart` — atualizado.
- `mobile/lib/features/inspection/presentation/create_inspection_screen.dart` — atualizado.

### Validações que passaram

- `flutter analyze` — No issues found! (Sucesso absoluto sem erros)

---

## Task 30

**Data:** 14/06/2026

**Sprint:** Ajustes de Perfil, Senha e Armazenamento Nativo
**Sessão:** Telas de Perfil, Alteração de Senha, Redefinição e Upload Nativo no Mobile

### O que foi feito

- **Mobile (Telas Dedicadas e Integração):**
  - Implementada a tela de redefinição de senha (`ForgotPasswordScreen`) com validação de formato de e-mail, carregamento rápido simulado de 1.5s, mensagem de sucesso e botão de retorno.
  - Integrada a navegação para `/forgot-password` na rota pública do GoRouter e no formulário de login (`LoginForm`).
  - Desenvolvidas telas dedicadas para edição de perfil (`EditProfileScreen`) e alteração de senha (`ChangePasswordScreen`) substituindo os antigos modais/diálogos.
  - Atualizado o modelo `User` do Flutter para receber `avatar_url` da API e executada a regeneração do Freezed via `build_runner`.
  - Implementado envio da foto de perfil para o backend via `AuthRepository.uploadAvatar` e `AuthCubit.uploadAvatar` utilizando requisições multipart, removendo a necessidade do workaround de cache de imagem local em `TokenStorage`.
  - Formatado o cabeçalho da `ProfileScreen` para exibir o nome e o cargo do usuário em formato compacto `Nome | Cargo` abaixo da foto de perfil e sem distintivos repetidos.
  - Atualizada a linha de versão do app para abrir um pop-up temático (`AlertDialog`) com detalhes do app em vez de expor o número da versão na própria linha.

### Estado dos arquivos tocados

- `mobile/lib/shared/models/user.dart` — atualizado.
- `mobile/lib/core/api/endpoints.dart` — atualizado.
- `mobile/lib/core/api/token_storage.dart` — atualizado.
- `mobile/lib/features/auth/data/auth_repository.dart` — atualizado.
- `mobile/lib/features/auth/domain/auth_cubit.dart` — atualizado.
- `mobile/lib/features/auth/presentation/widgets/login_form.dart` — atualizado.
- `mobile/lib/features/auth/presentation/forgot_password_screen.dart` — criado.
- `mobile/lib/features/auth/presentation/edit_profile_screen.dart` — criado.
- `mobile/lib/features/auth/presentation/change_password_screen.dart` — criado.
- `mobile/lib/features/auth/presentation/profile_screen.dart` — atualizado.
- `mobile/lib/app/router.dart` — atualizado.

### Validações que passaram

- `flutter analyze` — Sucesso absoluto sem erros nem avisos de lint.
- `flutter test` — Todos os 21 testes mobile executados e aprovados.

---

## Task 31

**Data:** 14/06/2026

**Sprint:** Customização de Abas Dinâmicas por Role e Cadastro de Usuários por Admin
**Sessão:** Ajustes de Roteamento Dinâmico por Role no BottomNavigationBar, Tela Standalone de Auditoria, Configurações de IA e Cadastro Integrado

### O que foi feito

- **Mobile (Roteamento Dinâmico por Role & Configurações de IA):**
  - Desenvolvida a tela independente `AuditLogsScreen` (`lib/features/auth/presentation/audit_logs_screen.dart`) que consome logs de auditoria via `AdminSettingsCubit` com formatação e conversão resiliente contra erros de tipo de índice em tempo de execução.
  - Refatorada a tela `AdminSettingsScreen` (`lib/features/auth/presentation/admin_settings_screen.dart`) removendo tabs e TabBarView, tornando-se a tela de configurações de motor de IA direta para os administradores.
  - Atualizada a classe `AppScaffold` em `lib/app/router.dart` para renderizar o `NavigationBar` contendo destinos e ícones específicos para cada cargo (Admin, Gestor, Inspetor), garantindo sincronismo do índice stack do shell.
  - Reconfigurado o roteamento dinâmico dentro de cada uma das quatro ramificações (`StatefulShellBranch`) do `StatefulShellRoute` do GoRouter, chaveando o widget inicial dependendo do cargo retornado do `AuthCubit`:
    - **Inspector (Operador/Inspetor):** Inspeções | Mapa | Laudos | Perfil
    - **Gestor (Manager):** Inspeções | Exportar (GeoJSON + CSV) | Equipe (TeamManagementScreen) | Perfil
    - **Admin (Administrador):** Logs (AuditLogsScreen) | IA (AdminSettingsScreen) | Usuários (UserManagementScreen) | Perfil
- **Mobile (Cadastro de Usuário Integrado):**
  - Adicionado suporte de requisição POST a `/api/users/` no `UserRepository.create` e no `UserManagementCubit.createUser`.
  - Inserido um `FloatingActionButton` na tela `UserManagementScreen` que abre um pop-up customizado com formulário de cadastro validando o preenchimento de nome completo, formato de email, tamanho mínimo de senha e seleção do papel (cargo).

### Estado dos arquivos tocados

- `mobile/lib/features/auth/data/user_repository.dart` — atualizado.
- `mobile/lib/features/auth/domain/user_management_cubit.dart` — atualizado.
- `mobile/lib/features/auth/presentation/user_management_screen.dart` — atualizado.
- `mobile/lib/features/auth/presentation/audit_logs_screen.dart` — criado.
- `mobile/lib/app/router.dart` — atualizado.

### Validações que passaram

- `flutter analyze` — Sucesso absoluto sem erros estáticos.
- `flutter test` — Todos os 21 testes mobile executados e aprovados.

---

## Task 32

**Data:** 14/06/2026

**Sprint:** Estabilização e Tratamento Resiliente de Erros de Conexão/Deserialização
**Sessão:** Tratamento Robusto de Respostas do Servidor, Paginação de Logs e Correção de Lints

### O que foi feito

- **Mobile (Logs de Auditoria Paginados de 5 em 5):**
  - Removido o ícone de engrenagem (configs) do topo da tela `AuditLogsScreen`, deixando-a mais limpa uma vez que existe a aba "IA" no menu inferior.
  - Atualizado `AdminRepository.getAuditLogs` para receber parâmetros `limit` e `offset`.
  - Atualizado `AdminSettingsState` e `AdminSettingsCubit` para gerenciar a paginação utilizando `isLoadingMore` e `hasMore`.
  - Atualizada a tela `AuditLogsScreen` para exibir um botão "Carregar mais 5 logs" no fim da lista (ou um indicador de carregamento caso `isLoadingMore` esteja ativo), evitando sobrecarregar o banco de dados carregando apenas 5 logs por padrão.
- **Mobile (Prevenção de TypeError em Exceções de API):**
  - Implementada a extensão `DioExceptionExtension` com o método helper `getErrorMessage()` em `core/api/api_client.dart` para extrair mensagens de erro do backend com segurança. A extensão valida se `response.data` é um `Map` antes de acessar o campo `'detail'`, o que evita o erro de índice `type 'String' is not a subtype of type 'int' of index` quando o backend retorna strings de erro puro.
  - Refatorados todos os repositórios (`admin_repository.dart`, `auth_repository.dart`, `user_repository.dart`, `inspection_repository.dart`) para usar o helper `e.getErrorMessage(...)` em seus blocos `catch`.
- **Mobile (Correção de Lints / Avisos de Análise):**
  - Removido o campo e parâmetro opcional não utilizado `trailing` da classe privada `_SettingsTile` na tela `ProfileScreen` para corrigir um aviso do analisador estático do Dart (`unused_element_parameter`).
  - Removidos imports não utilizados em `audit_logs_screen.dart` (`router.dart` e `go_router.dart`).

### Estado dos arquivos tocados

- `mobile/lib/core/api/api_client.dart` — atualizado.
- `mobile/lib/features/auth/presentation/profile_screen.dart` — atualizado.
- `mobile/lib/features/auth/presentation/audit_logs_screen.dart` — atualizado.
- `mobile/lib/features/auth/domain/admin_settings_state.dart` — atualizado.
- `mobile/lib/features/auth/domain/admin_settings_cubit.dart` — atualizado.
- `mobile/lib/features/auth/data/admin_repository.dart` — atualizado.
- `mobile/lib/features/auth/data/auth_repository.dart` — atualizado.
- `mobile/lib/features/auth/data/user_repository.dart` — atualizado.
- `mobile/lib/features/inspection/data/inspection_repository.dart` — atualizado.

### Validações que passaram

- `flutter analyze` — Sucesso absoluto sem erros estáticos ou avisos.
- `flutter test` — Todos os 21 testes mobile executados e aprovados.

---

## Task 33

**Data:** 14/06/2026

**Sprint:** Ajustes Finais, Logo e Nome do Aplicativo
**Sessão:** Configuração da Identidade Visual do Launcher (Android/Web) e Nome Comercial do App

### O que foi feito

- **Mobile (Logo SVG e PNG oficial):**
  - Desenvolvida a logo oficial da aplicação em vetor SVG (`assets/images/app_logo.svg`) contendo o gradiente premium de fundo, o ícone de localização `map-pin` e os brilhos `sparkles` em dourado, replicando fielmente o widget `AppLogo` de login.
  - Convertido o SVG para uma imagem de alta resolução em PNG (`1024x1024` pixels) em `assets/images/app_logo.png` para uso como origem dos launchers.
- **Mobile (Geração de Ícones Launcher):**
  - Adicionado e configurado o pacote `flutter_launcher_icons` no `pubspec.yaml` sob `dev_dependencies` e criado o arquivo de configuração de build `flutter_launcher_icons.yaml`.
  - Executado o gerador de ícones para as plataformas Android e Web (gerando automaticamente todos os mipmaps adaptativos e ícones da web), mantendo o iOS desligado devido à estrutura de pastas do repositório.
- **Mobile (Nome Oficial do Aplicativo - Vistor AI):**
  - Renomeado o label do aplicativo para "Vistor AI" no manifesto do Android (`android/app/src/main/AndroidManifest.xml`).
  - Atualizado o título da aplicação, tag meta e descrição no arquivo web `index.html` e também no manifesto do PWA `manifest.json`, unificando a identidade visual sob a marca comercial.
- **Mobile (Reatividade dos Switches de Preferência):**
  - Declaradas as variáveis de estado locais em `_ProfileScreenState` para representar as preferências do usuário, vinculando-as aos switches da `ProfileScreen` e permitindo que sejam ligados/desligados de forma reativa.
- **Mobile (Melhoria na Inicialização do Mapa):**
  - Refatorada a inicialização do mapa em `MapScreen` para obter ativamente a localização real em tempo real do GPS. A câmera se desloca automaticamente para a posição real do usuário e a busca no cubit é disparada na coordenada exata, exibindo as inspeções locais de imediato.
- **Mobile (Tratamento e Sanitização de Erros Técnicos):**
  - Criada a classe utilitária centralizada `ErrorHandler` (`lib/core/utils/error_handler.dart`) para higienizar exceções locais, erros de tipagem/runtime do Dart (ex: `TypeError`, `FormatException`) e erros do servidor (como problemas de MinIO, S3 ou banco de dados) antes de serem exibidos na interface para o usuário final.
  - Aprimorada a extensão `DioExceptionExtension` no `api_client.dart` para interceptar respostas 500+ e mensagens que contenham palavras-chave técnicas de infraestrutura, mascarando-as de forma automática e amigável.
  - Refatorados todos os Cubits (`UserManagementCubit`, `AdminSettingsCubit`, `CreateInspectionCubit`, `InspectionCubit`, `InspectionDetailCubit`, `TeamManagementCubit` e `ReportCubit`) para utilizarem a rotina do `ErrorHandler` no mapeamento de estados de erro.

### Estado dos arquivos tocados

- `mobile/assets/images/app_logo.svg` — criado.
- `mobile/assets/images/app_logo.png` — criado.
- `mobile/pubspec.yaml` — atualizado.
- `mobile/flutter_launcher_icons.yaml` — criado.
- `mobile/android/app/src/main/AndroidManifest.xml` — atualizado.
- `mobile/web/index.html` — atualizado.
- `mobile/web/manifest.json` — atualizado.
- `mobile/lib/core/utils/error_handler.dart` — criado.
- `mobile/lib/core/api/api_client.dart` — atualizado.
- `mobile/lib/features/auth/domain/user_management_cubit.dart` — atualizado.
- `mobile/lib/features/auth/domain/admin_settings_cubit.dart` — atualizado.
- `mobile/lib/features/inspection/domain/create_inspection_cubit.dart` — atualizado.
- `mobile/lib/features/inspection/domain/inspection_cubit.dart` — atualizado.
- `mobile/lib/features/inspection/domain/inspection_detail_cubit.dart` — atualizado.
- `mobile/lib/features/inspection/domain/team_management_cubit.dart` — atualizado.
- `mobile/lib/features/report/presentation/cubit/report_cubit.dart` — atualizado.

### Validações que passaram

- `flutter analyze` — Sucesso absoluto sem erros estáticos importantes.
- Execução do build do launcher — Geração de assets de launcher finalizada com sucesso.

---


