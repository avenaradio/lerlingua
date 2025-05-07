import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/settings.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Create a Mock class for SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Settings', () {
    late Settings settings;

    setUp(() async {
      // Initialize the mock SharedPreferences
      settings = Settings();

      // Use the mock SharedPreferences in place of the real one
      SharedPreferences.setMockInitialValues({});
      await settings.loadSettings();
    });

    test('loadSettings should load wordA from SharedPreferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'wordA': 'testValue'});

      // Act
      await settings.loadSettings();

      // Assert
      expect(settings.wordA, 'testValue');
    });

    test('wordA getter and setter should work correctly', () async {
      // Act
      settings.wordA = 'newValue';

      // Assert
      expect(settings.wordA, 'newValue');
    });

    test('wordA setter should save to SharedPreferences', () async {
      // Act
      SharedPreferences.setMockInitialValues({'wordA': 'testValue'});
      settings.wordA = 'newValue';
      await settings.loadSettings();

      // Assert
      expect(settings.wordA, 'newValue');
    });

    test('loadSettings should set wordA to empty string if not found', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({}); // No value for 'wordA'

      // Act
      await settings.loadSettings();

      // Assert
      expect(settings.wordA, '');
    });
  });
}