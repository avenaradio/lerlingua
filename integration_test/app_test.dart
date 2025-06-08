import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:lerlingua/main.dart' as app;
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Test app functionality", (WidgetTester tester) async {
    // Launch the app
    app.main();
    await tester.pumpAndSettle();
    // The Littele
    // Next page button
    final Finder nextPageButton = find.byKey(ValueKey('nextPageButton'));
    await tester.tap(nextPageButton);
    await tester.pumpAndSettle();
    expect(find.text('apologize '), findsOneWidget);

    // Tap Text
    final Finder text = find.text('apologize ');
    await tester.tap(text);
    await tester.pumpAndSettle();
    expect(find.text('apologize'), findsOneWidget);
  });
}
