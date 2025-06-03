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
    test('wordB selected event', () async {
      String receivedWordB = '';
      String receivedSentenceB = '';

      // Subscribe to the event bus
      eventBus.on<WordBSelectedEvent>().listen((event) {
        receivedWordB = event.wordB;
        receivedSentenceB = event.sentenceB;
      });

      // Create and fire the event
      List<String> sentenceListB = ['This', 'is', 'a', 'test', 'sentence.'];
      List<String> wordsB = [sentenceListB[3], sentenceListB[0]];
      WordBSelectedEvent event = WordBSelectedEvent(wordsB: wordsB, sentenceListB: sentenceListB);
      eventBus.fire(event);

      // Wait for the event to be received
      await Future.delayed(Duration(milliseconds: 100), () {});

      // Verify that the received word is correct
      expect(receivedWordB, 'This test');
      expect(receivedSentenceB, '%%This%% is a %%test%% sentence.');
    });
  });
}