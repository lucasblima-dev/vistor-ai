import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/widgets/inspection_card.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/widgets/severity_badge.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

void main() {
  setUpAll(() async {
    // Inicializa a localização em português para formatação de data
    await initializeDateFormatting('pt_BR', null);
  });

  testWidgets('Deve renderizar InspectionCard sem border-left, exibir SeverityBadge e navegar ao tocar', (WidgetTester tester) async {
    final testInspection = Inspection(
      id: 'test_id_123',
      inspectorId: 'inspector_123',
      title: 'Infiltração grave',
      category: 'Estrutura',
      description: 'Teste de infiltração na viga',
      location: const LocationPoint(lat: -5.7793, lon: -37.5689),
      gpsAccuracy: 5.0,
      address: 'Av. Universitária, UERN',
      status: InspectionStatus.open,
      severity: InspectionSeverity.critical,
      isSynced: true,
      createdAt: DateTime.now(),
    );

    int tapCount = 0;
    String? navigatedId;

    // Configurando um GoRouter real simplificado de teste para rastrear a navegação
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: InspectionCard(
              inspection: testInspection,
              onTap: () => tapCount++,
            ),
          ),
        ),
        GoRoute(
          path: '/inspections/:id',
          builder: (context, state) {
            navigatedId = state.pathParameters['id'];
            return const Scaffold(body: SizedBox.shrink());
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    // 1. Verificar se o card renderiza as informações básicas
    expect(find.text('Infiltração grave'), findsOneWidget);
    expect(find.text('ESTRUTURA'), findsOneWidget);

    // 2. Verificar se o SeverityBadge é renderizado
    expect(find.byType(SeverityBadge), findsOneWidget);
    expect(find.text('CRÍTICA'), findsOneWidget);

    // 3. Verificar que o card NÃO possui decoração de borda esquerda (border-left)
    // O container principal fica abaixo do AnimatedScale
    final containerFinder = find.descendant(
      of: find.byType(AnimatedScale),
      matching: find.byType(Container),
    ).first;

    final container = tester.widget<Container>(containerFinder);
    final boxDecoration = container.decoration as BoxDecoration;
    
    // O card não deve ter bordas (border: null) ou pelo menos não deve ter border-left específica
    expect(boxDecoration.border, isNull);

    // 4. Testar o Tap e a Navegação
    await tester.tap(find.byType(InspectionCard));
    await tester.pumpAndSettle();

    // O context.push retorna um Future que só completa após o fechamento (pop) da tela empilhada.
    // Damos o pop no router de teste para destravar a execução do onTap e testar o callback com sucesso:
    router.pop();
    await tester.pumpAndSettle();

    expect(tapCount, 1);
    expect(navigatedId, 'test_id_123');
  });
}
