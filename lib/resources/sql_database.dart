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

  // Queries
  final String _setupQuery =
    '''CREATE TABLE IF NOT EXISTS vocab (
    vocab_key INTEGER PRIMARY KEY AUTOINCREMENT,
    language_a TEXT NOT NULL,
    word_a TEXT NOT NULL,
    language_b TEXT NOT NULL,
    word_b TEXT NOT NULL,
    sentence_b TEXT,
    article_b TEXT,
    comment TEXT,
    box_number INTEGER,
    time_learned INTEGER NOT NULL,
    time_modified INTEGER NOT NULL
    );''';


  // Retrieve directory
  Future<void> getDirectory() async {
    dbDirectory = '${(await FileHandler.getAppDirectory()).path}/lerlingua.db';
  }

  // Method to load the database file
  Future<void> loadSqlDatabase() async{
    databaseFactory = databaseFactoryFfi;
    // open the database
    db = await openDatabase(dbDirectory, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(_setupQuery);
        });
  }

  // Method to initialize the database
  Future<void> initSqlDatabase() async{
    await getDirectory();
    await loadSqlDatabase();
  }

  // Method to insert or replace an entry
  Future<void> insertOrReplaceEntry({required VocabEntry entry}) async {
    await db.insert(
      'vocab',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Method to read an entry by its vocab_key
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

  // Method to delete an entry by its vocab_key
  Future<void> deleteEntry({required int vocabKey}) async {
    await db.delete(
      'vocab',
      where: 'vocab_key = ?',
      whereArgs: [vocabKey],
    );
  }

  // Method to read all entries
  Future<List<VocabEntry>> readAllEntries() async {
    List<Map<String, dynamic>> maps = await db.query('vocab');
    return List.generate(maps.length, (i) => VocabEntry.fromMap(maps[i]));
  }

  // Method to delete the database file
  Future<void> deleteSqlDatabase() async {
    // delete the database file
    await deleteDatabase(dbDirectory);
  }
}