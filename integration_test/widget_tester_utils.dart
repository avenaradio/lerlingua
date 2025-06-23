import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterExtension on WidgetTester {
  Future<void> pumpUntilFound(Finder finder,
      {Duration timeout = const Duration(seconds: 10)}) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await pump();
      if (any(finder)) return;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    throw Exception('Timeout waiting for $finder');
  }
}