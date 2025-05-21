import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/sql_database.dart';
import 'package:lerlingua/resources/vocab_entry.dart';
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
    test('Insert and Read one VocabEntry', () async {
      await SqlDatabase().loadSqlDatabase();
      int cardKey = 5;
      VocabEntry entry = VocabEntry(vocabKey: cardKey, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: 'This is a sentence.', articleB: 'The', comment: 'This is a comment.', boxNumber: 1, timeModified: 1);
      int key = await SqlDatabase().insertOrReplaceEntry(entry: entry);
      VocabEntry? entry2 = await SqlDatabase().readSingleEntry(vocabKey: cardKey);
      expect(entry2!.vocabKey, cardKey);
      expect(entry2.languageA, 'en');
      expect(entry2.wordA, 'test');
      expect(entry2.languageB, 'es');
      expect(entry2.wordB, 'prueba');
      expect(entry2.sentenceB, 'This is a sentence.');
      expect(entry2.articleB, 'The');
      expect(entry2.comment, 'This is a comment.');
      expect(entry2.boxNumber, 1);
      expect(entry2.timeModified, 1);
      expect(key, cardKey);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
    test('Override and Read VocabEntrys awaiting each insert', () async {
      await SqlDatabase().loadSqlDatabase();
      int cardKey1 = 0;
      int cardKey2 = 0;
      int cardKey3 = 3;
      int cardKey4 = 3;
      VocabEntry entry1 = VocabEntry(vocabKey: cardKey1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      VocabEntry entry2 = VocabEntry(vocabKey: cardKey2, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      VocabEntry entry3 = VocabEntry(vocabKey: cardKey3, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      VocabEntry entry4 = VocabEntry(vocabKey: cardKey4, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      int key1 = await SqlDatabase().insertOrReplaceEntry(entry: entry1);
      int key2 = await SqlDatabase().insertOrReplaceEntry(entry: entry2);
      int key3 = await SqlDatabase().insertOrReplaceEntry(entry: entry3);
      int key4 = await SqlDatabase().insertOrReplaceEntry(entry: entry4);
      VocabEntry? entry1read = await SqlDatabase().readSingleEntry(vocabKey: cardKey1);
      VocabEntry? entry2read = await SqlDatabase().readSingleEntry(vocabKey: cardKey2);
      VocabEntry? entry3read = await SqlDatabase().readSingleEntry(vocabKey: cardKey3);
      VocabEntry? entry4read = await SqlDatabase().readSingleEntry(vocabKey: cardKey4);
      // Assert
      expect(entry1read?.vocabKey, cardKey1);
      expect(entry2read?.vocabKey, cardKey2);
      expect(entry3read?.vocabKey, cardKey3);
      expect(entry4read?.vocabKey, cardKey4);
      expect(key1, cardKey1);
      expect(key2, cardKey2);
      expect(key3, cardKey3);
      expect(key4, cardKey4);
      List<VocabEntry> entries = await SqlDatabase().readAllEntries();
      expect(entries.length, 2);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
    test('Override and Read VocabEntrys not awaiting each insert', () async {
      await SqlDatabase().loadSqlDatabase();
      int cardKey1 = 0;
      int cardKey2 = 11;
      int cardKey3 = 3;
      int cardKey4 = 20;
      VocabEntry entry1 = VocabEntry(vocabKey: cardKey1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      VocabEntry entry2 = VocabEntry(vocabKey: cardKey2, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      VocabEntry entry3 = VocabEntry(vocabKey: cardKey3, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      VocabEntry entry4 = VocabEntry(vocabKey: cardKey4, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', boxNumber: 1, timeModified: 1);
      SqlDatabase().insertOrReplaceEntry(entry: entry1);
      SqlDatabase().insertOrReplaceEntry(entry: entry2);
      SqlDatabase().insertOrReplaceEntry(entry: entry3);
      SqlDatabase().insertOrReplaceEntry(entry: entry4);
      VocabEntry? entry1read = await SqlDatabase().readSingleEntry(vocabKey: cardKey1);
      VocabEntry? entry2read = await SqlDatabase().readSingleEntry(vocabKey: cardKey2);
      VocabEntry? entry3read = await SqlDatabase().readSingleEntry(vocabKey: cardKey3);
      VocabEntry? entry4read = await SqlDatabase().readSingleEntry(vocabKey: cardKey4);
      // Assert
      expect(entry1read?.vocabKey, cardKey1);
      expect(entry2read?.vocabKey, cardKey2);
      expect(entry3read?.vocabKey, cardKey3);
      expect(entry4read?.vocabKey, cardKey4);
      List<VocabEntry> entries = await SqlDatabase().readAllEntries();
      expect(entries.length, 4);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
    test('readAllEntries', () async {
      await SqlDatabase().loadSqlDatabase();
      VocabEntry entry = VocabEntry(
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
      List<VocabEntry> entries = await SqlDatabase().readAllEntries();
      expect(entries.length, 0);
      await SqlDatabase().insertOrReplaceEntry(entry: entry);
      entries = await SqlDatabase().readAllEntries();
      expect(entries.length, 1);
      VocabEntry entry2 = VocabEntry(
          vocabKey: 2,
          languageA: 'en',
          wordA: 'test2',
          languageB: 'es',
          wordB: 'prueba2',
          boxNumber: 0,
          timeModified: 1);
      await SqlDatabase().insertOrReplaceEntry(entry: entry2);
      entries = await SqlDatabase().readAllEntries();
      expect(entries.length, 2);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
    test('deleteEntry', () async {
      await SqlDatabase().loadSqlDatabase();
      VocabEntry entry = VocabEntry(
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
      await SqlDatabase().insertOrReplaceEntry(entry: entry);
      entry.vocabKey = 2;
      await SqlDatabase().insertOrReplaceEntry(entry: entry);
      List<VocabEntry> entries = await SqlDatabase().readAllEntries();
      expect(entries.length, 2);
      int key =await SqlDatabase().deleteEntry(vocabKey: 1);
      entries = await SqlDatabase().readAllEntries();
      expect(entries.length, 1);
      expect(key, 1);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
    test('overrideAllEntries', () async {
      await SqlDatabase().loadSqlDatabase();
      List<VocabEntry> entriesForOverride = [];
      VocabEntry entry = VocabEntry(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeModified: 1);
      await SqlDatabase().insertOrReplaceEntry(entry: entry);
      entry.vocabKey = 2;
      await SqlDatabase().insertOrReplaceEntry(entry: entry);
      entry.vocabKey = 3;
      entriesForOverride.add(entry);
      await SqlDatabase().overrideAllEntries(entriesForOverride);
      List<VocabEntry> entries = await SqlDatabase().readAllEntries();
      expect(entries.length, 1);
      expect(entries[0].vocabKey, 3);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
    test('deleteAllEntries', () async {
      await SqlDatabase().loadSqlDatabase();
      VocabEntry entry = VocabEntry(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeModified: 1);
      await SqlDatabase().insertOrReplaceEntry(entry: entry);
      entry.vocabKey = 2;
      await SqlDatabase().insertOrReplaceEntry(entry: entry);
      List<VocabEntry> entries = await SqlDatabase().readAllEntries();
      expect(entries.length, 2);
      await SqlDatabase().deleteAllEntries();
      entries = await SqlDatabase().readAllEntries();
      expect(entries.length, 0);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
  });
}