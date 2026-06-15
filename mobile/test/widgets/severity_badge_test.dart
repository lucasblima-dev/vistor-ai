import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/widgets/severity_badge.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';

void main() {
  testWidgets('Deve renderizar SeverityBadge.critical com fundo vermelho e texto branco', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SeverityBadge(severity: InspectionSeverity.critical),
        ),
      ),
    );

    final containerFinder = find.byType(Container);
    final textFinder = find.text('CRÍTICA');

    expect(containerFinder, findsOneWidget);
    expect(textFinder, findsOneWidget);

    final container = tester.widget<Container>(containerFinder);
    final boxDecoration = container.decoration as BoxDecoration;
    expect(boxDecoration.color, const Color(0xFFE53E3E));

    final text = tester.widget<Text>(textFinder);
    expect(text.style?.color, Colors.white);
  });

  testWidgets('Deve renderizar SeverityBadge.moderate com fundo laranja e texto branco', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SeverityBadge(severity: InspectionSeverity.moderate),
        ),
      ),
    );

    final containerFinder = find.byType(Container);
    final textFinder = find.text('MODERADA');

    expect(containerFinder, findsOneWidget);
    expect(textFinder, findsOneWidget);

    final container = tester.widget<Container>(containerFinder);
    final boxDecoration = container.decoration as BoxDecoration;
    expect(boxDecoration.color, const Color(0xFFDD6B20));

    final text = tester.widget<Text>(textFinder);
    expect(text.style?.color, Colors.white);
  });

  testWidgets('Deve renderizar SeverityBadge.low com fundo verde e texto branco', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SeverityBadge(severity: InspectionSeverity.low),
        ),
      ),
    );

    final containerFinder = find.byType(Container);
    final textFinder = find.text('BAIXA');

    expect(containerFinder, findsOneWidget);
    expect(textFinder, findsOneWidget);

    final container = tester.widget<Container>(containerFinder);
    final boxDecoration = container.decoration as BoxDecoration;
    expect(boxDecoration.color, const Color(0xFF38A169));

    final text = tester.widget<Text>(textFinder);
    expect(text.style?.color, Colors.white);
  });

  testWidgets('Deve renderizar SeverityBadge.pendingReview com fundo cinza e texto cinza escuro', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SeverityBadge(severity: InspectionSeverity.pendingReview),
        ),
      ),
    );

    final containerFinder = find.byType(Container);
    final textFinder = find.text('PENDENTE');

    expect(containerFinder, findsOneWidget);
    expect(textFinder, findsOneWidget);

    final container = tester.widget<Container>(containerFinder);
    final boxDecoration = container.decoration as BoxDecoration;
    expect(boxDecoration.color, const Color(0xFFF3F4F6));

    final text = tester.widget<Text>(textFinder);
    expect(text.style?.color, const Color(0xFF6B7280));
  });
}
