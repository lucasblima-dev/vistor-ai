# Vistor AI — Padrão de Estados de UI

> Aplicar em TODA tela com dados assíncronos.

> Nunca exiba dados sem tratar loading, erro e vazio.

---

## Os 5 estados obrigatórios

| Estado | Quando ocorre | Widget padrão |
|---|---|---|
| `initial` | Antes de qualquer ação | `SizedBox.shrink()` |
| `loading` | Aguardando resposta | `AppLoadingState` |
| `loaded` | Dados disponíveis | Conteúdo real |
| `empty` | Lista retornou vazia | `AppEmptyState` |
| `error` | Falha na requisição | `AppErrorState` |

---

## Estrutura Freezed obrigatória

```dart
@freezed
class InspectionState with _$InspectionState {
  const factory InspectionState.initial()                       = _Initial;
  const factory InspectionState.loading()                       = _Loading;
  const factory InspectionState.loaded(List<Inspection> items)  = _Loaded;
  const factory InspectionState.empty()                         = _Empty;
  const factory InspectionState.error(String message)           = _Error;
}
```

---

## AppLoadingState

```dart
// shared/widgets/loading_state.dart
class AppLoadingState extends StatelessWidget {
  final String? message;
  const AppLoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
          strokeWidth: 2.5,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )),
        ],
      ]),
    );
  }
}
```

---

## AppErrorState

```dart
// shared/widgets/error_state.dart
class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const AppErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.cardLg),
            ),
            child: const Icon(Icons.error_outline,
              color: AppColors.error, size: 32),
          ),
          const SizedBox(height: 16),
          Text('Algo deu errado',
            style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Tentar novamente'),
            ),
          ],
        ]),
      ),
    );
  }
}
```

---

## AppEmptyState

```dart
// shared/widgets/empty_state.dart
class AppEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;
  const AppEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.cardLg),
            ),
            child: Icon(Icons.inbox_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 40),
          ),
          const SizedBox(height: 20),
          Text(title,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(subtitle,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 24),
            action!,
          ],
        ]),
      ),
    );
  }
}
```

---

## SnackBars padrão

```dart
// shared/widgets/error_snackbar.dart
void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.error_outline, color: Colors.white, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(message,
        style: const TextStyle(color: Colors.white, fontFamily: 'Inter'))),
    ]),
    backgroundColor: AppColors.error,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.input)),
    margin: const EdgeInsets.all(AppSpacing.md),
    duration: const Duration(seconds: 4),
  ));
}

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(message,
        style: const TextStyle(color: Colors.white, fontFamily: 'Inter'))),
    ]),
    backgroundColor: AppColors.success,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.input)),
    margin: const EdgeInsets.all(AppSpacing.md),
    duration: const Duration(seconds: 3),
  ));
}
```

---

## Como usar em qualquer tela

```dart
BlocBuilder<InspectionCubit, InspectionState>(
  builder: (context, state) => state.when(
    initial: () => const SizedBox.shrink(),
    loading: () => const AppLoadingState(message: 'Carregando...'),
    loaded:  (items) => _buildList(items),
    empty:   () => AppEmptyState(
      title: 'Nenhuma inspeção',
      subtitle: 'Toque em Nova Inspeção para começar',
      action: ElevatedButton(
        onPressed: () => context.push(AppRoutes.createInspection),
        child: const Text('Nova Inspeção'),
      ),
    ),
    error: (msg) => AppErrorState(
      message: msg,
      onRetry: () => context.read<InspectionCubit>().load(),
    ),
  ),
)
```

---

## Estados por tela

| Tela | Loading msg | Empty msg |
|---|---|---|
| Home | `'Carregando inspeções...'` | `'Nenhuma inspeção encontrada'` |
| Mapa | `'Carregando mapa...'` | `'Nenhuma inspeção no mapa'` |
| Laudos | `'Carregando laudos...'` | `'Nenhum laudo gerado ainda'` |
| Gestão de Equipe | `'Carregando fila...'` | `'Nenhuma inspeção aguardando'` |
| Usuários | `'Carregando usuários...'` | `'Nenhum usuário encontrado'` |

---

## Regras que o agente NÃO deve quebrar

- Nunca renderize lista sem checar se está vazia — sempre `empty` state
- Nunca inicie tela já no estado `loaded` — sempre passe por `loading`
- Nunca use `CircularProgressIndicator` solto — sempre `AppLoadingState`
- Nunca exiba `Exception` ou stack trace ao usuário
- Sempre forneça `onRetry` quando a ação for repetível
- Sempre use `BlocListener` para side effects separado do `BlocBuilder`
