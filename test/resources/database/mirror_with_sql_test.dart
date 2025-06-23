import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/database/mirror/mirror.dart';
import 'package:lerlingua/resources/settings/settings.dart';
import 'package:lerlingua/resources/database/sqlite/sqlite_database.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

//Must run with 'flutter test test/resources/mirror_with_sql_test.dart --dart-define=IS_TEST=false' otherwise mirror will skip using sql database
Future main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Settings settings;
  // Set directory to in-memory
  SqlDatabase().dbDirectory = inMemoryDatabasePath;
  // Setup sqflite_common_ffi for flutter test
  setUpAll(() async {
    // Initialize the mock SharedPreferences
    settings = Settings();
    // Use the mock SharedPreferences in place of the real one
    SharedPreferences.setMockInitialValues({});
    await settings.loadSettings();
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  });
  await SqlDatabase().loadSqlDatabase();
  group('DatabaseMirror Tests', () {
    test('writeCard to DatabaseMirror (without updating sql database)', () {
      VocabCard card = VocabCard(
        vocabKey: 1,
        languageA: 'en',
        wordA: 'test',
        languageB: 'es',
        wordB: 'prueba',
        sentenceB: 'This is a sentence.',
        articleB: 'The',
        comment: 'This is a comment.',
        boxNumber: 1,
        timeModified: 1,
      );
      Mirror().dbMirror.clear();
      // Write card to DatabaseMirror
      VocabCard cardClone = Mirror().writeCard(card: card, addNewUndo: false);
      expect(card.hashCode, isNot(cardClone.hashCode));
      expect(Mirror().dbMirror.length, 1);
      expect(Mirror().dbMirror[0].hashCode, cardClone.hashCode);
      expect(Mirror().dbMirror[0].vocabKey, 1);
      // Add second card
      card.vocabKey = 2;
      VocabCard cardClone2 = Mirror().writeCard(card: card, addNewUndo: false);
      expect(card.hashCode, isNot(cardClone2.hashCode));
      expect(
        cardClone.hashCode,
        isNot(cardClone2.hashCode),
      ); // 3 different objects
      expect(Mirror().dbMirror.length, 2);
      expect(Mirror().dbMirror[1].vocabKey, 2);
      // override first card
      card.vocabKey = 1;
      Mirror().writeCard(card: card, addNewUndo: false);
      expect(Mirror().dbMirror.length, 2);
      expect(Mirror().dbMirror[0].vocabKey, 1);
      // Add card without key (key = -1)
      card.vocabKey = -1;
      Mirror().writeCard(card: card, addNewUndo: false);
      expect(Mirror().dbMirror.length, 3);
      expect(Mirror().dbMirror[2].vocabKey, greaterThan(1747913373956));
      // Add card with key not in DatabaseMirror (key = 21)
      card.vocabKey = 21;
      Mirror().writeCard(card: card, addNewUndo: false);
      expect(Mirror().dbMirror.length, 4);
      expect(Mirror().dbMirror[3].vocabKey, 21);
    });
    test('writeCard should not save if vocabKey is -2', () {
      VocabCard card = VocabCard(
        vocabKey: -2,
        languageA: 'en',
        wordA: 'test',
        languageB: 'es',
        wordB: 'prueba',
        boxNumber: 1,
        timeModified: 1,
      );
      Mirror().dbMirror.clear();
      Mirror().writeCard(card: card, addNewUndo: false);
      expect(Mirror().dbMirror.length, 0);
    });
    test('get card from DatabaseMirror', () {
      VocabCard card = VocabCard(
        vocabKey: 2,
        languageA: 'en',
        wordA: 'test',
        languageB: 'es',
        wordB: 'prueba',
        sentenceB: 'This is a sentence.',
        articleB: 'The',
        comment: 'This is a comment.',
        boxNumber: 1,
        timeModified: 1,
      );
      Mirror().dbMirror.clear();
      expect(Mirror().readCard(vocabKey: 0), null);
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 1;
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 3;
      Mirror().writeCard(card: card, addNewUndo: false);
      expect(Mirror().readCard(vocabKey: 2)!.vocabKey, 2);
      expect(Mirror().readCard(vocabKey: 99), null);
    });
    test('delete card from DatabaseMirror', () {
      VocabCard card = VocabCard(
        vocabKey: 2,
        languageA: 'en',
        wordA: 'test',
        languageB: 'es',
        wordB: 'prueba',
        sentenceB: 'This is a sentence.',
        articleB: 'The',
        comment: 'This is a comment.',
        boxNumber: 1,
        timeModified: 1,
      );
      Mirror().dbMirror.clear();
      bool deleted = Mirror().deleteCard(card: card);
      expect(deleted, false);
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 1;
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 3;
      Mirror().writeCard(card: card, addNewUndo: false);
      deleted = Mirror().deleteCard(card: card);
      expect(Mirror().dbMirror.length, 2);
      expect(Mirror().dbMirror[0].vocabKey, 2);
      expect(Mirror().dbMirror[1].vocabKey, 1);
      expect(deleted, true);
      deleted = Mirror().deleteCard(card: card);
      expect(deleted, false);
    });
  });
}
