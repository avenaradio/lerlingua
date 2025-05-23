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

    test('loadSettings should load currentBox from SharedPreferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'currentBox': 2});

      // Act
      await settings.loadSettings();

      // Assert
      expect(settings.currentBox, 2);
    });

    test('currentBox getter and setter should work correctly', () async {
      // Act
      settings.currentBox = 5;

      // Assert
      expect(settings.currentBox, 5);
    });

    test('currentBox setter should save to SharedPreferences', () async {
      // Act
      SharedPreferences.setMockInitialValues({'currentBox': 2});
      settings.currentBox = 5;

      // Assert
      await settings.loadSettings();

      // Assert
      expect(settings.currentBox, 5);
    });

    test('loadSettings should set currentBox to empty string if not found', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({}); // No value

      // Act
      await settings.loadSettings();

      // Assert
      expect(settings.currentBox, 1);
    });

    test('addDeletedCards should save to SharedPreferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({}); // No value

      // Act
      settings.addDeletedCards('24/24/524/5');
      settings.addDeletedCards('');
      await Future.delayed(const Duration(milliseconds: 500));

      // Assert
      await settings.loadSettings();
      expect(settings.deletedCards, {24, 524, 5}); // Expect set of int
      expect(Settings().deletedCardsString, '24/524/5');

      // Act
      settings.removeDeletedCards('24/24/524');
      settings.removeDeletedCards('');
      await Future.delayed(const Duration(milliseconds: 500));

      // Assert
      await settings.loadSettings();
      expect(settings.deletedCards, {5});
      expect(Settings().deletedCardsString, '5');
    });
  });
}