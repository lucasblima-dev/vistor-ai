# Módulo: Mobile (Flutter)

> Contexto técnico específico do app Flutter.

> Complementa o GEMINI.md raiz com convenções Dart/Flutter.

> O agente deve consultar docs/mobile/LAYOUT.md antes de gerar qualquer widget ou tela.

> O agente deve consultar docs/mobile/THEME.dart antes de usar qualquer cor, espaçamento ou sombra.

> O agente deve consultar docs/mobile/STATES.md antes de implementar qualquer tela com dados assíncronos.

---

## Stack mobile

| Camada | Tecnologia |
|---|---|
| Framework | Flutter 3.x + Dart |
| State management | BLoC / Cubit + Freezed |
| Navegação | go_router (AppRoutes.* sempre) |
| Banco local | Drift (SQLite) |
| HTTP | Dio + interceptors JWT |
| Mapas | flutter_map + OpenStreetMap |
| IA visual | HuggingFace via backend |
| Push | Firebase Cloud Messaging |
| Ícones | lucide_icons (nunca Icons.*) |
| Fontes | google_fonts: Inter + JetBrains Mono |
| DI | get_it |
| Env | envied (.env) |

---

## Estrutura de Pastas

```
mobile/
├── .env                              ← não commitado
├── .env.example
├── .geminiignore
├── pubspec.yaml
│
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── router.dart
│   │   └── theme.dart
│   │
│   ├── core/
│   │   ├── api/
│   │   │   ├── api_client.dart
│   │   │   ├── endpoints.dart
│   │   │   └── token_storage.dart
│   │   ├── local/
│   │   │   ├── database.dart
│   │   │   ├── inspection_dao.dart
│   │   │   └── sync_manager.dart
│   │   ├── services/
│   │   │   ├── gps_service.dart
│   │   │   ├── media_service.dart
│   │   │   └── notification_service.dart
│   │   └── utils/
│   │       ├── env.dart
│   │       ├── extensions.dart
│   │       ├── validators.dart
│   │       └── logger.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   └── user_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── auth_cubit.dart
│   │   │   │   └── auth_state.dart
│   │   │   └── presentation/
│   │   │       ├── login_screen.dart
│   │   │       ├── profile_screen.dart
│   │   │       ├── user_management_screen.dart
│   │   │       └── widgets/
│   │   │           └── login_form.dart
│   │   ├── inspection/
│   │   │   ├── data/
│   │   │   │   ├── inspection_repository.dart
│   │   │   │   └── local_inspection_dao.dart
│   │   │   ├── domain/
│   │   │   │   ├── inspection_cubit.dart
│   │   │   │   └── inspection_state.dart
│   │   │   └── presentation/
│   │   │       ├── inspection_list_screen.dart
│   │   │       ├── inspection_detail_screen.dart
│   │   │       ├── create_inspection_screen.dart
│   │   │       ├── team_management_screen.dart
│   │   │       └── widgets/
│   │   │           ├── inspection_card.dart
│   │   │           ├── severity_badge.dart
│   │   │           ├── ai_result_card.dart
│   │   │           ├── media_picker_sheet.dart
│   │   │           ├── status_timeline.dart
│   │   │           └── assign_inspector_sheet.dart
│   │   ├── map/
│   │   │   ├── data/
│   │   │   │   └── map_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── map_cubit.dart
│   │   │   │   └── map_state.dart
│   │   │   └── presentation/
│   │   │       ├── map_screen.dart
│   │   │       ├── export_data_screen.dart
│   │   │       └── widgets/
│   │   │           ├── inspection_marker.dart
│   │   │           ├── heatmap_layer.dart
│   │   │           └── map_filter_sheet.dart
│   │   └── report/
│   │       ├── data/
│   │       │   └── report_repository.dart
│   │       ├── domain/
│   │       │   ├── report_cubit.dart
│   │       │   └── report_state.dart
│   │       └── presentation/
│   │           ├── report_list_screen.dart
│   │           └── report_viewer_screen.dart
│   │
│   └── shared/
│       ├── models/
│       │   ├── user.dart
│       │   ├── inspection.dart
│       │   ├── media.dart
│       │   └── report.dart
│       ├── screens/
│       │   └── offline_screen.dart
│       └── widgets/
│           ├── app_logo.dart
│           ├── offline_banner.dart
│           ├── sync_indicator.dart
│           ├── loading_overlay.dart
│           ├── error_snackbar.dart
│           ├── loading_state.dart
│           ├── error_state.dart
│           └── empty_state.dart
│
└── test/
    ├── features/
    │   ├── auth/
    │   │   └── auth_cubit_test.dart
    │   └── inspection/
    │       └── inspection_cubit_test.dart
    └── widgets/
        ├── severity_badge_test.dart
        ├── inspection_card_test.dart
        └── ai_result_card_test.dart
```

### Arquitetura: **Feature-First**

```
lib/
├── app/           → router, theme, app.dart
├── core/          → infraestrutura genérica (api, local, services, utils)
├── features/      → auth, inspection, map, report
└── shared/        → widgets e models usados por 2+ features
```

### Regra de dependência

- `core/` nunca importa nada de `features/`
- `shared/` nunca importa nada de `features/`
- `features/` pode importar `core/` e `shared/`
- Uma feature nunca importa outra feature diretamente

### Estrutura interna de cada feature

```
feature/
├── data/         → repositories (HTTP + local)
├── domain/       → cubit + states (Freezed)
└── presentation/ → screens + widget
```

---

## Padrões de código obrigatórios

### State management

- **Freezed obrigatório** para todos os estados de BLoC/Cubit
- **BlocBuilder** para rebuild de UI
- **BlocListener** para side effects (navegação, SnackBar) — nunca no builder
- Sempre tratar todos os estados: initial / loading / loaded / empty / error
- Nunca iniciar tela já no estado loaded — sempre passar por loading primeiro

### Widgets

- Widgets são **puramente declarativos** — zero lógica de negócio
- Nenhuma chamada HTTP direta em widget — sempre via repository → cubit
- Use `const` em construtores sempre que possível
- Alvos de toque mínimo: 48×48dp

### Navegação

- **Sempre** `AppRoutes.*` — nunca strings de rota soltas
- `context.push()` para empilhar, `context.go()` para substituir
- Guard de autenticação no redirect do GoRouter

### DTOs

- **Freezed** obrigatório para todos os models em `shared/models/`
- `fromJson` / `toJson` via `@JsonSerializable`
- Campos snake_case no JSON → camelCase no Dart via `@JsonKey`

---

## Tokens de design

> Consulte THEME.dart para valores exatos. Nunca hardcode cores.

- **Nunca** `Colors.blue`, `Colors.red` etc. — sempre `AppColors.*`
- **Nunca** `Color(0xFF...)` fora de `AppColors`
- **Nunca** `Icons.*` do Material — sempre `LucideIcons.*`
- **Nunca** `fontFamily: 'Inter'` literal — sempre `GoogleFonts.inter()`
- **Sempre** verificar `Theme.of(context).brightness` em componentes com glassmorphism

### Severidade — regra crítica

Badge de severidade usa **fundo sólido + texto branco**:

- critical: bg `#E53E3E`, texto branco
- moderate: bg `#DD6B20`, texto branco
- low: bg `#38A169`, texto branco
- pending: bg `#F3F4F6`, texto `#6B7280`

**Nunca** usar fundo claro + texto colorido para severidade.

### InspectionCard — regra crítica

Card de inspeção **não tem border-left** colorida.
A severidade é comunicada apenas pelo SeverityBadge.

---

## Padrão de telas

Toda tela com dados do backend segue este padrão:

```dart
BlocBuilder<XCubit, XState>(
  builder: (context, state) => state.when(
    initial: () => const SizedBox.shrink(),
    loading: () => const AppLoadingState(message: '...'),
    loaded:  (data) => _buildContent(data),
    empty:   () => AppEmptyState(title: '...', subtitle: '...'),
    error:   (msg) => AppErrorState(message: msg, onRetry: () => cubit.load()),
  ),
)
```

Nunca use `CircularProgressIndicator` solto — sempre `AppLoadingState`.
Nunca exiba `Exception` ao usuário — sempre mensagem amigável em português.

---

## Offline e sincronização

- Toda inspeção criada offline é salva no Drift com `isSynced = false`
- `SyncManager` detecta reconexão via `connectivity_plus` e sincroniza automaticamente
- `OfflineBanner` é exibido em todas as telas exceto Login e Splash
- `SyncIndicator` no AppBar mostra estado em tempo real
- Tokens JWT ficam **exclusivamente** no `FlutterSecureStorage`

---

## Telas implementadas

| Rota | Tela | Papel |
|---|---|---|
| `/` | Splash / Loading | todos |
| `/login` | Login | todos |
| `/inspections` | Home — Lista de inspeções | todos |
| `/inspections/create` | Nova Inspeção | inspetor |
| `/inspections/:id` | Detalhe da Inspeção | todos |
| `/map` | Mapa + Heatmap | todos |
| `/reports` | Laudos Técnicos | todos |
| `/reports/:id` | Visualizador de Laudo PDF | todos |
| `/profile` | Perfil + Configurações | todos |
| `/team` | Gestão de Equipe | gestor/admin |
| `/export` | Exportar Dados | gestor/admin |
| `/users` | Gestão de Usuários | admin |
| `/offline` | Tela Offline | todos |

---

## O que o agente NÃO deve fazer

- **Não use** `Icons.*` — sempre `LucideIcons.*`
- **Não use** `Colors.*` — sempre `AppColors.*`
- **Não use** `Color(0xFF...)` fora de `AppColors`
- **Não use** `Stepper` padrão Flutter — Nova Inspeção é formulário scrollável único
- **Não coloque** border-left em `InspectionCard` — sem border-left
- **Não use** fundo claro para `SeverityBadge` — sempre fundo sólido
- **Não use** `SharedPreferences` para tokens — sempre `FlutterSecureStorage`
- **Não use** strings de rota soltas — sempre `AppRoutes.*`
- **Não coloque** lógica de negócio em widgets
- **Não importe** uma feature dentro de outra feature
- **Não importe** nada de `features/` dentro de `core/` ou `shared/`
- **Não gere** código sem verificar dark mode em componentes com surface colorida

---

## Importações de contexto específico

- [`/docs/mobile/GEMINI.md`](./GEMINI.md)
- [`/docs/mobile/LAYOUT.md`](./LAYOUT.md)
- [`/docs/mobile/THEME.md`](./THEME.md)
- [`/docs/mobile/STATES.md`](./STATES.md)
- [`/docs/mobile/ROUTER.md`](./ROUTER.md)
