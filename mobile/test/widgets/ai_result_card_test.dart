import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vistor_ai_mobile/features/inspection/presentation/widgets/ai_result_card.dart';

void main() {
  testWidgets('Deve habilitar o botão de confirmar quando score >= 0.55', (WidgetTester tester) async {
    bool confirmed = false;
    bool corrected = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiResultCard(
            label: 'Rachadura estrutural',
            confidence: 0.85,
            onConfirm: () => confirmed = true,
            onCorrect: () => corrected = true,
          ),
        ),
      ),
    );

    expect(find.text('Classificação IA'), findsOneWidget);
    expect(find.text('Classificação incerta'), findsNothing);

    final confirmBtnFinder = find.widgetWithText(ElevatedButton, 'Confirmar');
    expect(confirmBtnFinder, findsOneWidget);
    
    final confirmBtn = tester.widget<ElevatedButton>(confirmBtnFinder);
    expect(confirmBtn.enabled, isTrue);

    await tester.tap(confirmBtnFinder);
    await tester.pump();
    expect(confirmed, isTrue);
    expect(corrected, isFalse);
  });

  testWidgets('Deve desabilitar o botão de confirmar e mostrar classificação incerta quando score < 0.55', (WidgetTester tester) async {
    bool confirmed = false;
    bool corrected = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiResultCard(
            label: 'Mancha na viga',
            confidence: 0.45,
            onConfirm: () => confirmed = true,
            onCorrect: () => corrected = true,
          ),
        ),
      ),
    );

    expect(find.text('Classificação incerta'), findsOneWidget);
    expect(find.text('Classificação IA'), findsNothing);

    final confirmBtnFinder = find.widgetWithText(ElevatedButton, 'Confirmar');
    expect(confirmBtnFinder, findsOneWidget);
    
    final confirmBtn = tester.widget<ElevatedButton>(confirmBtnFinder);
    expect(confirmBtn.enabled, isFalse);

    await tester.tap(confirmBtnFinder);
    await tester.pump();
    expect(confirmed, isFalse);
    expect(corrected, isFalse);
  });
}
