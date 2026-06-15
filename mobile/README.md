# Vistor AI — Mobile (Flutter)

Guia técnico de referência e documentação de desenvolvimento para o aplicativo móvel da plataforma Vistor AI.

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

## Setup Local para Desenvolvimento

Caso necessite compilar ou depurar o aplicativo móvel localmente, siga os passos abaixo para preparar o ambiente:

### 1. Instalação de Dependências e Pacotes

A partir da pasta `mobile/`, instale todas as dependências declaradas no pubspec.yaml:

```bash
cd mobile
flutter pub get
```

### 2. Configuração do Arquivo de Ambiente (.env)

O aplicativo utiliza o pacote `Envied` para injeção de variáveis de ambiente.

1. Crie o arquivo `.env` na pasta `mobile/` a partir do modelo de exemplo:

   ```bash
   cp .env.example .env
   ```

2. Abra o arquivo `.env` e configure a variável `API_BASE_URL` (geralmente apontando para `http://localhost:8000`).

### 3. Geração de Código e Invalidação de Cache do Envied

O app utiliza **Freezed**, **Drift** e **Envied** para geração de código. O projeto não compilará antes de gerar esses arquivos.

Execute o gerador na pasta `mobile/`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

> [!WARNING]
> **Invalidação de Cache do Envied:** O `build_runner` realiza cache agressivo. Se você alterar a URL da API no arquivo `.env` mas não fizer alterações em nenhum arquivo `.dart`, o gerador de código **restaurará o arquivo antigo do cache** (mantendo o IP anterior e impedindo a conexão).
>
> Para forçar a invalidação do cache e compilar com as novas credenciais/IP:
>
> 1. Abra o arquivo [lib/core/utils/env.dart](./lib/core/utils/env.dart).
> 2. Faça uma alteração sutil na última linha de comentário (ex: altere a versão do trigger no final).
> 3. Salve o arquivo e re-execute o comando `dart run build_runner build --delete-conflicting-outputs`.

### 4. Configuração de Rede e Mapeamento de Portas via ADB

Para que o emulador Android ou dispositivo físico conectado via USB consiga se comunicar com a API e o Storage MinIO que rodam no Docker Compose da máquina host, é necessário criar um túnel de redirecionamento de portas via ADB.

Com o dispositivo móvel/emulador conectado e reconhecido pelo comando `adb devices`, execute no host:

```bash
adb reverse tcp:8000 tcp:8000
adb reverse tcp:9000 tcp:9000
```

> [!IMPORTANT]
> A porta `8000` redireciona o tráfego da API FastAPI e a porta `9000` redireciona o tráfego do Object Storage MinIO. Se o redirecionamento da porta `9000` for omitido, o aplicativo móvel falhará ao realizar uploads de mídia durante as inspeções.
> **Nota:** Este mapeamento deve ser executado novamente sempre que o dispositivo ou emulador for reiniciado.

### 5. Aceitação de Licenças e Compilação Inicial

Para garantir que as dependências do Android Gradle sejam resolvidas corretamente:

```bash
flutter doctor --android-licenses
```

E realize a primeira compilação pelo terminal em modo de depuração para instalar os SDKs necessários e gerar o arquivo APK de depuração:

```bash
flutter build apk --debug
```

*O APK gerado ficará em `build/app/outputs/flutter-apk/app-debug.apk`.*

Para depurar ativamente no dispositivo conectado:

```bash
flutter run
```

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

---

## Documentos de Apoio Adicionais

Consulte também os demais guias específicos do módulo móvel:

- [`/docs/mobile/GEMINI.md`](../docs/mobile/GEMINI.md) — Contexto do Agente e convenções.
- [`/docs/mobile/LAYOUT.md`](../docs/mobile/LAYOUT.md) — Diretrizes de layouts e widgets visuais.
- [`/docs/mobile/THEME.md`](../docs/mobile/THEME.md) — Configurações de cores, fontes e tema.
- [`/docs/mobile/STATES.md`](../docs/mobile/STATES.md) — Manipulação e arquitetura de estados.
- [`/docs/mobile/ROUTER.md`](../docs/mobile/ROUTER.md) — Estrutura de rotas e guards do GoRouter.
