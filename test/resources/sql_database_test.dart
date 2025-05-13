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
    test('Scema creation', () async {
      await SqlDatabase().loadSqlDatabase();
      // Check if the table 'vocab' exists
      final List<Map<String, dynamic>> result = await SqlDatabase().db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='vocab';");

      // Verify that the table exists
      expect(result.isNotEmpty, true);
      expect(result[0]['name'], 'vocab');
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
    test('Insert and Read VocabEntry', () async {
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
          timeLearned: 1,
          timeModified: 1);
      await SqlDatabase().insertOrReplaceEntry(entry: entry);
      VocabEntry? entry2 = await SqlDatabase().readSingleEntry(vocabKey: 1);
      expect(entry2!.vocabKey, 1);
      expect(entry2.languageA, 'en');
      expect(entry2.wordA, 'test');
      expect(entry2.languageB, 'es');
      expect(entry2.wordB, 'prueba');
      expect(entry2.sentenceB, 'This is a sentence.');
      expect(entry2.articleB, 'The');
      expect(entry2.comment, 'This is a comment.');
      expect(entry2.boxNumber, 1);
      expect(entry2.timeLearned, 1);
      expect(entry2.timeModified, 1);
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
          timeLearned: 1,
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
          timeLearned: 1,
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
          timeLearned: 1,
          timeModified: 1);
      await SqlDatabase().insertOrReplaceEntry(entry: entry);
      entry.vocabKey = 2;
      await SqlDatabase().insertOrReplaceEntry(entry: entry);
      List<VocabEntry> entries = await SqlDatabase().readAllEntries();
      expect(entries.length, 2);
      await SqlDatabase().deleteEntry(vocabKey: 1);
      entries = await SqlDatabase().readAllEntries();
      expect(entries.length, 1);
      await SqlDatabase().deleteSqlDatabase(); // Delete the database
    });
  });
}