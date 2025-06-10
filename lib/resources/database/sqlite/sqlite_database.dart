// Singleton
import 'package:flutter/cupertino.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../file_utils/file_handler.dart';

class SqlDatabase {
  @visibleForTesting
  late Database db;
  @visibleForTesting
  late String dbDirectory;

  // Private constructor
  SqlDatabase._internal();

  // Static instance of the class
  static final SqlDatabase _instance = SqlDatabase._internal();

  // Factory constructor to always return the same instance
  factory SqlDatabase() {
    return _instance;
  }

  /// Database version
  final int _version = 1;
  get version => _version;
  /// SQL query to create the vocab table
  final String _setupQuery =
    '''CREATE TABLE IF NOT EXISTS vocab (
    vocab_key INTEGER PRIMARY KEY NOT NULL,
    language_a TEXT NOT NULL,
    word_a TEXT NOT NULL,
    language_b TEXT NOT NULL,
    word_b TEXT NOT NULL,
    sentence_b TEXT NOT NULL,
    article_b TEXT NOT NULL,
    comment TEXT NOT NULL,
    box_number INTEGER NOT NULL,
    time_modified INTEGER NOT NULL
    );''';


  /// Gets the database directory
  Future<void> getDirectory() async {
    dbDirectory = '${(await FileHandler.getAppDirectory()).path}/lerlingua.db';
  }

  /// Loads the database file
  /// - Tested
  Future<void> loadSqlDatabase() async{
    databaseFactory = databaseFactoryFfi;
    // open the database
    db = await openDatabase(dbDirectory, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(_setupQuery);
        });
  }

  /// Initializes the database
  Future<void> initSqlDatabase() async{
    await getDirectory();
    await loadSqlDatabase();
  }

  /// Inserts or replaces an card
  /// - Tested
  Future<int> insertOrReplaceCard({required VocabCard card}) async {
    int key = await db.insert(
      'vocab',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return key;
  }

  /// Reads a single card by its vocabKey
  /// - Tested
  Future<VocabCard?> readSingleCard({required int vocabKey}) async {
    List<Map<String, dynamic>> maps = await db.query(
      'vocab',
      where: 'vocab_key = ?',
      whereArgs: [vocabKey],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return VocabCard.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Deletes an card by its vocabKey
  /// - Tested
  Future<int> deleteCard({required int vocabKey}) async {
    int key = await db.delete(
      'vocab',
      where: 'vocab_key = ?',
      whereArgs: [vocabKey],
    );
    return key;
  }

  /// Reads all cards
  /// - Tested
  Future<List<VocabCard>> readAllCards() async {
    List<Map<String, dynamic>> maps = await db.query('vocab');
    return List.generate(maps.length, (i) => VocabCard.fromMap(maps[i]));
  }

  /// Overrides all cards with a new list of cards
  /// - Tested (not tested if cards are restored if transaction fails)
  Future<void> overrideAllCards(List<VocabCard> cards) async {
    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM vocab;');
      for (VocabCard card in cards) {
        await txn.insert('vocab', card.toMap());
      }
    });
  }

  /// Deletes all cards
  /// - Tested
  Future<void> deleteAllCards() async {
    await db.rawDelete('DELETE FROM vocab;');
  }

  /// Deletes the database file
  Future<void> deleteSqlDatabase() async {
    // delete the database file
    await deleteDatabase(dbDirectory);
  }
}