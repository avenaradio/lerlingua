import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/pages/settings/event_bus.dart';

void main() {
  group('EventBus Tests', () {
    test('should receive WordSelectedEvent', () async {
      // Create a variable to hold the received event
      String receivedWord = '';

      // Subscribe to the event bus
      eventBus.on<WordSelectedEvent>().listen((event) {
        receivedWord = event.wordA;
      });

      // Create and fire the event
      final event = WordSelectedEvent('Test Word');
      eventBus.fire(event);

      // Allow some time for the event to be processed
      await Future.delayed(Duration(milliseconds: 100));

      // Verify that the received word is correct
      expect(receivedWord, 'Test Word');
    });
  });
}