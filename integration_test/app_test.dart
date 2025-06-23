import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:lerlingua/main.dart' as app;
import 'widget_tester_utils.dart';

// Only use keys to find widgets
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Test Reader translation on tap", (WidgetTester tester) async {
    // Launch the app
    app.main();
    await tester.pumpAndSettle();

    // TEST WORD TRANSLATION ON TAP
    // Next page button
    final Finder nextPageButton = find.byKey(ValueKey('nextPageButton'));
    await tester.tap(nextPageButton);
    await tester.pumpAndSettle();
    expect(find.text('Wundererscheinungen '), findsOneWidget);

    // Tap Text
    final Finder text = find.text('Wundererscheinungen ');
    await tester.tap(text);
    await tester.pumpAndSettle();

    // Wait until WebView is loaded
    await tester.pumpUntilFound(find.byKey(Key('webViewIsLoaded')));
    final Finder wordB = find.text('Wundererscheinungen');
    expect(wordB, findsOneWidget);


    // TEST ADD WORD MANUALLY
    // Next page button
    final Finder cardList = find.byTooltip('Cards');
    await tester.tap(cardList);
    await tester.pumpAndSettle();
    final Finder addButton = find.byTooltip('Add card');
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Wait forever
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(days: 1));
  });
}
