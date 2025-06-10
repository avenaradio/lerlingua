import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/file_utils/book.dart';
import 'package:lerlingua/resources/settings/settings.dart';
import 'package:lerlingua/resources/translation_service.dart';
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
    });

    test('loadSettings should load currentBox from SharedPreferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'currentBox': 2, 'firstRun': false});

      // Act
      await settings.loadSettings();

      // Assert
      expect(settings.currentBox, 2);
    });

    test('currentBox getter and setter should work correctly', () async {
      SharedPreferences.setMockInitialValues({ 'firstRun': false });
      // Act
      settings.currentBox = 5;

      // Assert
      expect(settings.currentBox, 5);
    });

    test('currentBox setter should save to SharedPreferences', () async {
      // Act
      SharedPreferences.setMockInitialValues({'currentBox': 2, 'firstRun': false});
      await settings.loadSettings();
      settings.currentBox = 5;

      // Assert
      await settings.loadSettings();

      // Assert
      expect(settings.currentBox, 5);
    });

    test('loadSettings should set currentBox to empty string if not found', () async {
      // Arrange
       SharedPreferences.setMockInitialValues({ 'firstRun': false });

      // Act
      await settings.loadSettings();

      // Assert
      expect(settings.currentBox, 1);
    });

    test('addDeletedCards should save to SharedPreferences', () async {
      // Arrange
       SharedPreferences.setMockInitialValues({ 'firstRun': false });

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
    group('translationServices', () {
      test('currentTranslationService getter and setter should work correctly', () async {
         SharedPreferences.setMockInitialValues({ 'firstRun': false });
         await settings.loadSettings();
         Settings().translationServicesSet.clear();

        // Assert
        expect(settings.currentTranslationService?.key, null);
        expect(settings.translationServices.isEmpty, true);
        await settings.loadSettings();

        // Arrange
        TranslationService translationService = TranslationService(key: 101, icon: Icons.translate, languageA: 'en', languageB: 'es', url: 'https://translate.google.de/?sl=auto&tl=en&text=%search%', injectJs: '''function myFunction() {}''');

        // Act
        settings.currentTranslationService = translationService;
        await Future.delayed(const Duration(milliseconds: 500));

        // Assert
        await settings.loadSettings();
        expect(settings.currentTranslationService?.key, 101);

        // Clear
        settings.deleteTranslationService(translationService);
      });
      test('currentTranslationService getter should return first if none set', () async {
         SharedPreferences.setMockInitialValues({ 'firstRun': false });
         await settings.loadSettings();
         Settings().translationServicesSet.clear();

        // Arrange
        TranslationService translationService = TranslationService(key: 101, icon: Icons.translate, languageA: 'en', languageB: 'es', url: 'https://translate.google.de/?sl=auto&tl=en&text=%search%', injectJs: '''function myFunction() {}''');

        // Act
        settings.addOrUpdateTranslationService(translationService);

        // Assert
        expect(settings.currentTranslationService?.key, 101);
        expect(settings.translationServices.first.key, 101);

        // Act
        settings.deleteTranslationService(translationService);

        // Assert
        expect(settings.currentTranslationService?.key, null);
        expect(settings.translationServices.isEmpty, true);
      });
      test('add and delete translation services', () async {
         SharedPreferences.setMockInitialValues({ 'firstRun': false });
         await settings.loadSettings();
         Settings().translationServicesSet.clear();

        // Arrange
        TranslationService translationService1 = TranslationService(key: 1, icon: Icons.translate, languageA: 'en', languageB: 'es', url: 'https://translate.google.de/?sl=auto&tl=en&text=%search%', injectJs: '''function myFunction() {}''');
        TranslationService translationService2 = TranslationService(key: 2, icon: Icons.translate, languageA: 'en', languageB: 'fr', url: 'https://translate.google.de/?sl=auto&tl=en&text=%search%', injectJs: '''function myFunction() {}''');

        // Act
        settings.addOrUpdateTranslationService(translationService1);
        settings.addOrUpdateTranslationService(translationService2);

        // Assert
        expect(settings.translationServices.length, 2);
        expect(settings.translationServices.first.languageB, 'es');
        expect(settings.translationServices.last.languageB, 'fr');

        // Act
        settings.deleteTranslationService(translationService1);

        // Assert
        expect(settings.translationServices.length, 1);
        expect(settings.translationServices.first.languageB, 'fr');

        // Clear
        settings.deleteTranslationService(translationService2);
      });
      test('get translation services should order correctly', () async {
         SharedPreferences.setMockInitialValues({ 'firstRun': false });
         await settings.loadSettings();
         Settings().translationServicesSet.clear();

        // Arrange
        TranslationService translationService1 = TranslationService(key: 1, icon: Icons.translate, languageA: 'fr', languageB: 'en', url: '', injectJs: '');
        TranslationService translationService2 = TranslationService(key: 2, icon: Icons.translate, languageA: 'es', languageB: 'en', url: '', injectJs: '');
        TranslationService translationService3 = TranslationService(key: 3, icon: Icons.translate, languageA: 'fr', languageB: 'en', url: '', injectJs: '');
        TranslationService translationService4 = TranslationService(key: 4, icon: Icons.translate, languageA: 'es', languageB: 'en', url: '', injectJs: '');
        TranslationService translationService5 = TranslationService(key: 5, icon: Icons.translate, languageA: 'es', languageB: 'de', url: '', injectJs: '');

        // Act
        settings.addOrUpdateTranslationService(translationService1);
        settings.addOrUpdateTranslationService(translationService2);
        settings.addOrUpdateTranslationService(translationService3);
        settings.addOrUpdateTranslationService(translationService4);
        settings.addOrUpdateTranslationService(translationService5);

        // Assert
        expect(settings.translationServices.length, 5);
        expect(settings.translationServices[0].key, 5);
        expect(settings.translationServices[1].key, 2);
        expect(settings.translationServices[2].key, 4);
        expect(settings.translationServices[3].key, 1);
        expect(settings.translationServices[4].key, 3);

        // Act
        translationService3.languageB = 'de';
        settings.addOrUpdateTranslationService(translationService3);

        // Assert
        expect(settings.translationServices.length, 5);
        expect(settings.translationServices[0].key, 5);
        expect(settings.translationServices[1].key, 3);
        expect(settings.translationServices[2].key, 2);
        expect(settings.translationServices[3].key, 4);
        expect(settings.translationServices[4].key, 1);

        // Clear
        settings.deleteTranslationService(translationService1);
        settings.deleteTranslationService(translationService2);
        settings.deleteTranslationService(translationService3);
        settings.deleteTranslationService(translationService4);
        settings.deleteTranslationService(translationService5);
      });
      test('override default translation services on startup', () async {
        SharedPreferences.setMockInitialValues({});
        await settings.loadSettings();

        // Assert
        expect(settings.translationServices.length, TranslationService.defaults.length);

        Settings().translationServicesSet.clear();

        // Act
        TranslationService translationService1 = TranslationService(key: 1, icon: Icons.translate, languageA: 'fr', languageB: 'en', url: '', injectJs: '');
        TranslationService translationService2 = TranslationService(key: 2, icon: Icons.translate, languageA: 'es', languageB: 'en', url: '', injectJs: '');

        settings.addOrUpdateTranslationService(translationService1);
        settings.addOrUpdateTranslationService(translationService2);

        // Assert
        expect(settings.translationServices.length, 2);

        await Future.delayed(const Duration(milliseconds: 500));

        await settings.loadSettings();
        expect(settings.translationServices.length, TranslationService.defaults.length);
      });
    });
    group('books', () {
      test('currentBook getter and setter should work correctly', () async {
        SharedPreferences.setMockInitialValues({ 'firstRun': false });
        // Assert
        await settings.loadSettings();
        expect(settings.currentBook?.key, null);
        expect(settings.books.isEmpty, true);

        // Arrange
        Book book = Book(key: 1, path: 'test.epub', languageB: 'fr', readingLocation: 'test_location', title: 'test_title', author: 'test_author', lastReadTime: DateTime.now().millisecondsSinceEpoch, cover: Uint8List(1));

        // Act
        settings.currentBook = book;
        await Future.delayed(const Duration(milliseconds: 500));

        // Assert
        await settings.loadSettings();
        expect(settings.currentBook?.key, 1);
        expect(settings.books.first.key, 1);

        // Clear
        settings.deleteBook(book);
      });
      test('currentBook setter should save book if not existing yet', () async {
        SharedPreferences.setMockInitialValues({ 'firstRun': false });

        // Arrange
        Book book = Book(key: 3, path: 'test.epub', languageB: 'fr', readingLocation: 'test_location', title: 'test_title', author: 'test_author', lastReadTime: DateTime.now().millisecondsSinceEpoch, cover: Uint8List(1));

        // Act
        settings.currentBook = book;
        await Future.delayed(const Duration(milliseconds: 500));

        // Assert
        await settings.loadSettings();
        expect(settings.currentBook?.key, 3);
        expect(settings.books.first.key, 3);

        // Clear
        settings.deleteBook(book);
      });
      test('currentBook getter should return last read or null if book is deleted', () async {
        SharedPreferences.setMockInitialValues({ 'firstRun': false });

        // Arrange
        Book book2 = Book(key: 2, path: 'test2.epub', languageB: 'fr', readingLocation: 'test_location', title: 'test_title', author: 'test_author', lastReadTime: DateTime.now().millisecondsSinceEpoch, cover: Uint8List(1));
        Book book3 = Book(key: 3, path: 'test3.epub', languageB: 'fr', readingLocation: 'test_location', title: 'test_title', author: 'test_author', lastReadTime: DateTime.now().millisecondsSinceEpoch, cover: Uint8List(1));
        // Act
        settings.addOrUpdateBook(book2);
        settings.addOrUpdateBook(book3);
        settings.currentBook = book2;
        settings.deleteBook(book2);
        await Future.delayed(const Duration(milliseconds: 500));

        // Assert
        await settings.loadSettings();
        expect(settings.currentBook?.key, 3);
        expect(settings.books.length, 1);

        // Act
        settings.deleteBook(book3);
        await Future.delayed(const Duration(milliseconds: 500));

        // Assert
        await settings.loadSettings();
        expect(settings.currentBook, null);
        expect(settings.books.isEmpty, true);
      });
      test('currentBook getter should return null on first run', () async {
        Book book2 = Book(key: 2, path: 'test2.epub', languageB: 'fr', readingLocation: 'test_location', title: 'test_title', author: 'test_author', lastReadTime: DateTime.now().millisecondsSinceEpoch, cover: Uint8List(1));
        Book book3 = Book(key: 3, path: 'test3.epub', languageB: 'fr', readingLocation: 'test_location', title: 'test_title', author: 'test_author', lastReadTime: DateTime.now().millisecondsSinceEpoch, cover: Uint8List(1));
        SharedPreferences.setMockInitialValues({ 'firstRun': true });
        await settings.loadSettings();

        // Act
        settings.addOrUpdateBook(book2);
        settings.addOrUpdateBook(book3);
        await Future.delayed(const Duration(milliseconds: 500));

        // Assert
        await settings.loadSettings();
        expect(settings.currentBook, null);
        expect(settings.books.length, 2);

        // Clear
        settings.deleteBook(book2);
        settings.deleteBook(book3);
      });
      test('add and delete book', () async {
        SharedPreferences.setMockInitialValues({ 'firstRun': false });

        // Arrange
        Book book1 = Book(key: 1, path: 'test.epub', languageB: 'es', readingLocation: 'test_location', title: 'test_title', author: 'test_author', lastReadTime: DateTime.now().millisecondsSinceEpoch, cover: Uint8List(1));
        Book book2 = Book(key: 2, path: 'test.epub', languageB: 'fr', readingLocation: 'test_location', title: 'test_title', author: 'test_author', lastReadTime: DateTime.now().millisecondsSinceEpoch, cover: Uint8List(1));

        // Act
        settings.addOrUpdateBook(book1);
        settings.addOrUpdateBook(book2);
        await Future.delayed(const Duration(milliseconds: 500));

        // Assert
        await settings.loadSettings();
        expect(settings.books.length, 2);
        expect(settings.books.first.languageB, 'es');
        expect(settings.books.last.languageB, 'fr');

        // Act
        settings.deleteBook(book1);
        await Future.delayed(const Duration(milliseconds: 500));

        // Assert
        await settings.loadSettings();
        expect(settings.books.length, 1);
        expect(settings.books.first.languageB, 'fr');

        // Clear
        settings.deleteBook(book2);
      });
      test('get book should order correctly', () async {
        SharedPreferences.setMockInitialValues({ 'firstRun': false });

        // Arrange
        Book book1 = Book(key: 1, path: 'test.epub', languageB: 'es', readingLocation: 'test_location', title: 'test_title', author: 'test_author', lastReadTime: DateTime.now().millisecondsSinceEpoch, cover: Uint8List(1));
        Book book2 = Book(key: 2, path: 'test.epub', languageB: 'fr', readingLocation: 'test_location', title: 'test_title', author: 'test_author', lastReadTime: DateTime.now().millisecondsSinceEpoch + 1000, cover: Uint8List(1));

        // Act
        settings.addOrUpdateBook(book1);
        settings.addOrUpdateBook(book2);
        await Future.delayed(const Duration(milliseconds: 500));

        // Assert
        await settings.loadSettings();
        expect(settings.books.length, 2);
        expect(settings.books[0].key, 2);
        expect(settings.books[1].key, 1);

        // Act
        book1.lastReadTime = DateTime.now().millisecondsSinceEpoch + 2000;
        settings.addOrUpdateBook(book1);
        await Future.delayed(const Duration(milliseconds: 500));

        // Assert
        await settings.loadSettings();
        expect(settings.books.length, 2);
        expect(settings.books[0].key, 1);
        expect(settings.books[1].key, 2);

        // Clear
        settings.deleteBook(book1);
        settings.deleteBook(book2);
      });
      test('set current book to null on first run', () async {
        SharedPreferences.setMockInitialValues({});

        // Assert
        await settings.loadSettings();
        expect(settings.currentBook?.key, null);
      });
    });
  });
}