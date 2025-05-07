import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/event_bus.dart';
import 'package:lerlingua/resources/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_test.dart';

void main() {
  group('EventBus Tests', () {
    late MockSharedPreferences mockSharedPreferences;
    late Settings settings;

    setUp(() async {
      // Initialize the mock SharedPreferences
      mockSharedPreferences = MockSharedPreferences();
      settings = Settings();

      // Use the mock SharedPreferences in place of the real one
      SharedPreferences.setMockInitialValues({});
      await settings.loadSettings();
    });
    test('should receive WordSelectedEvent', () async {
      // Create a variable to hold the received event
      String receivedWord = '';
      String settingsWord = '';

      // Subscribe to the event bus
      eventBus.on<WordSelectedEvent>().listen((event) {
        receivedWord = event.wordA;
      });

      // Create and fire the event
      final event = WordSelectedEvent('Test Word');
      eventBus.fire(event);

      // Allow some time for the event to be processed
      await Future.delayed(Duration(milliseconds: 100));

      // Read the word from settings
      settingsWord = Settings().wordA;

      // Verify that the received word is correct
      expect(receivedWord, 'Test Word');
      expect(settingsWord, 'Test Word');
    });
  });
}