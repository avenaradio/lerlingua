import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/database/sqlite/sqlite_database.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future main() async {
  // Set directory to in-memory
  SqlDatabase().dbDirectory = inMemoryDatabasePath;

  // Setup sqflite_common_ffi for flutter test
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  });

  group('SqlDatabase query Tests', () {
    test('Scema creation',() async {
      await SqlDatabase().loadSqlDatabase();
      // Check if the table 'vocab' exists
      final List<Map<String, dynamic>> result = await SqlDatabase().db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='vocab';");
      // Verify that the table exists
      expect(result.isNotEmpty, true);
      expect(result[0]['name'], 'vocab');
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
    test('Insert and Read one VocabCard', () async {
      await SqlDatabase().loadSqlDatabase();
      int cardKey = 5;
      VocabCard card = VocabCard(vocabKey: cardKey, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: 'This is a sentence.', articleB: 'The', comment: 'This is a comment.', boxNumber: 1, timeModified: 1);
      int key = await SqlDatabase().insertOrReplaceCard(card: card);
      VocabCard? card2 = await SqlDatabase().readSingleCard(vocabKey: cardKey);
      expect(card2!.vocabKey, cardKey);
      expect(card2.languageA, 'en');
      expect(card2.wordA, 'test');
      expect(card2.languageB, 'es');
      expect(card2.wordB, 'prueba');
      expect(card2.sentenceB, 'This is a sentence.');
      expect(card2.articleB, 'The');
      expect(card2.comment, 'This is a comment.');
      expect(card2.boxNumber, 1);
      expect(card2.timeModified, 1);
      expect(key, cardKey);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
    test('Override and Read VocabCards awaiting each insert', () async {
      await SqlDatabase().loadSqlDatabase();
      int cardKey1 = 0;
      int cardKey2 = 0;
      int cardKey3 = 3;
      int cardKey4 = 3;
      VocabCard card1 = VocabCard(vocabKey: cardKey1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      VocabCard card2 = VocabCard(vocabKey: cardKey2, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      VocabCard card3 = VocabCard(vocabKey: cardKey3, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      VocabCard card4 = VocabCard(vocabKey: cardKey4, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      int key1 = await SqlDatabase().insertOrReplaceCard(card: card1);
      int key2 = await SqlDatabase().insertOrReplaceCard(card: card2);
      int key3 = await SqlDatabase().insertOrReplaceCard(card: card3);
      int key4 = await SqlDatabase().insertOrReplaceCard(card: card4);
      VocabCard? card1read = await SqlDatabase().readSingleCard(vocabKey: cardKey1);
      VocabCard? card2read = await SqlDatabase().readSingleCard(vocabKey: cardKey2);
      VocabCard? card3read = await SqlDatabase().readSingleCard(vocabKey: cardKey3);
      VocabCard? card4read = await SqlDatabase().readSingleCard(vocabKey: cardKey4);
      // Assert
      expect(card1read?.vocabKey, cardKey1);
      expect(card2read?.vocabKey, cardKey2);
      expect(card3read?.vocabKey, cardKey3);
      expect(card4read?.vocabKey, cardKey4);
      expect(key1, cardKey1);
      expect(key2, cardKey2);
      expect(key3, cardKey3);
      expect(key4, cardKey4);
      List<VocabCard> cards = await SqlDatabase().readAllCards();
      expect(cards.length, 2);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
    test('Override and Read VocabCards not awaiting each insert', () async {
      await SqlDatabase().loadSqlDatabase();
      int cardKey1 = 0;
      int cardKey2 = 11;
      int cardKey3 = 3;
      int cardKey4 = 20;
      VocabCard card1 = VocabCard(vocabKey: cardKey1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      VocabCard card2 = VocabCard(vocabKey: cardKey2, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      VocabCard card3 = VocabCard(vocabKey: cardKey3, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      VocabCard card4 = VocabCard(vocabKey: cardKey4, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      SqlDatabase().insertOrReplaceCard(card: card1);
      SqlDatabase().insertOrReplaceCard(card: card2);
      SqlDatabase().insertOrReplaceCard(card: card3);
      SqlDatabase().insertOrReplaceCard(card: card4);
      VocabCard? card1read = await SqlDatabase().readSingleCard(vocabKey: cardKey1);
      VocabCard? card2read = await SqlDatabase().readSingleCard(vocabKey: cardKey2);
      VocabCard? card3read = await SqlDatabase().readSingleCard(vocabKey: cardKey3);
      VocabCard? card4read = await SqlDatabase().readSingleCard(vocabKey: cardKey4);
      // Assert
      expect(card1read?.vocabKey, cardKey1);
      expect(card2read?.vocabKey, cardKey2);
      expect(card3read?.vocabKey, cardKey3);
      expect(card4read?.vocabKey, cardKey4);
      List<VocabCard> cards = await SqlDatabase().readAllCards();
      expect(cards.length, 4);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
    test('readAllCards', () async {
      await SqlDatabase().loadSqlDatabase();
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
          timeModified: 1);
      List<VocabCard> cards = await SqlDatabase().readAllCards();
      expect(cards.length, 0);
      await SqlDatabase().insertOrReplaceCard(card: card);
      cards = await SqlDatabase().readAllCards();
      expect(cards.length, 1);
      VocabCard card2 = VocabCard(
          vocabKey: 2,
          languageA: 'en',
          wordA: 'test2',
          languageB: 'es',
          wordB: 'prueba2',
          boxNumber: 0,
          timeModified: 1);
      await SqlDatabase().insertOrReplaceCard(card: card2);
      cards = await SqlDatabase().readAllCards();
      expect(cards.length, 2);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
    test('deleteCard', () async {
      await SqlDatabase().loadSqlDatabase();
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
          timeModified: 1);
      await SqlDatabase().insertOrReplaceCard(card: card);
      card.vocabKey = 2;
      await SqlDatabase().insertOrReplaceCard(card: card);
      List<VocabCard> cards = await SqlDatabase().readAllCards();
      expect(cards.length, 2);
      int key =await SqlDatabase().deleteCard(vocabKey: 1);
      cards = await SqlDatabase().readAllCards();
      expect(cards.length, 1);
      expect(key, 1);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
    test('overrideAllCards', () async {
      await SqlDatabase().loadSqlDatabase();
      List<VocabCard> cardsForOverride = [];
      VocabCard card = VocabCard(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeModified: 1);
      await SqlDatabase().insertOrReplaceCard(card: card);
      card.vocabKey = 2;
      await SqlDatabase().insertOrReplaceCard(card: card);
      card.vocabKey = 3;
      cardsForOverride.add(card);
      await SqlDatabase().overrideAllCards(cardsForOverride);
      List<VocabCard> cards = await SqlDatabase().readAllCards();
      expect(cards.length, 1);
      expect(cards[0].vocabKey, 3);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
    test('deleteAllCards', () async {
      await SqlDatabase().loadSqlDatabase();
      VocabCard card = VocabCard(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeModified: 1);
      await SqlDatabase().insertOrReplaceCard(card: card);
      card.vocabKey = 2;
      await SqlDatabase().insertOrReplaceCard(card: card);
      List<VocabCard> cards = await SqlDatabase().readAllCards();
      expect(cards.length, 2);
      await SqlDatabase().deleteAllCards();
      cards = await SqlDatabase().readAllCards();
      expect(cards.length, 0);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
  });
}