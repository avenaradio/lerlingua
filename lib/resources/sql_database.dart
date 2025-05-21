// Singleton
import 'package:flutter/cupertino.dart';
import 'package:lerlingua/resources/vocab_entry.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'file_handler.dart';

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

  /// SQL query to create the vocab table
  final String _setupQuery =
    '''CREATE TABLE IF NOT EXISTS vocab (
    vocab_key INTEGER PRIMARY KEY,
    language_a TEXT NOT NULL,
    word_a TEXT NOT NULL,
    language_b TEXT NOT NULL,
    word_b TEXT NOT NULL,
    sentence_b TEXT,
    article_b TEXT,
    comment TEXT,
    box_number INTEGER,
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

  /// Inserts or replaces an entry
  /// - Tested
  Future<int> insertOrReplaceEntry({required VocabEntry entry}) async {
    int key = await db.insert(
      'vocab',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return key;
  }

  /// Reads a single entry by its vocabKey
  /// - Tested
  Future<VocabEntry?> readSingleEntry({required int vocabKey}) async {
    List<Map<String, dynamic>> maps = await db.query(
      'vocab',
      where: 'vocab_key = ?',
      whereArgs: [vocabKey],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return VocabEntry.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Deletes an entry by its vocabKey
  /// - Tested
  Future<int> deleteEntry({required int vocabKey}) async {
    int key = await db.delete(
      'vocab',
      where: 'vocab_key = ?',
      whereArgs: [vocabKey],
    );
    return key;
  }

  /// Reads all entries
  /// - Tested
  Future<List<VocabEntry>> readAllEntries() async {
    List<Map<String, dynamic>> maps = await db.query('vocab');
    return List.generate(maps.length, (i) => VocabEntry.fromMap(maps[i]));
  }

  /// Overrides all entries with a new list of entries
  /// - Tested (not tested if entries are restored if transaction fails)
  Future<void> overrideAllEntries(List<VocabEntry> entries) async {
    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM vocab;');
      for (VocabEntry entry in entries) {
        await txn.insert('vocab', entry.toMap());
      }
    });
  }

  /// Deletes all entries
  /// - Tested
  Future<void> deleteAllEntries() async {
    await db.rawDelete('DELETE FROM vocab;');
  }

  /// Deletes the database file
  Future<void> deleteSqlDatabase() async {
    // delete the database file
    await deleteDatabase(dbDirectory);
  }
}