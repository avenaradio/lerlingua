import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/event_bus.dart';

void main() {
  group('EventBus Tests', () {
    test('wordA selected event', () async {
      // Create a variable to hold the received event
      String receivedWord = '';

      // Subscribe to the event bus
      eventBus.on<WordASelectedEvent>().listen((event) {
        receivedWord = event.wordA;
      });

      // Create and fire the event
      WordASelectedEvent event = WordASelectedEvent('Test Word');
      eventBus.fire(event);

      // Wait for the event to be received
      await Future.delayed(Duration(milliseconds: 100), () {});

      // Verify that the received word is correct
      expect(receivedWord, 'Test Word');
    });
  });
}