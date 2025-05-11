
// Singleton
import 'package:flutter/cupertino.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'file_handler.dart';

class SqlDatabase {
  @visibleForTesting
  late Database db;
  @visibleForTesting
  late String dbDirectory;
  List<VocabEntry> _dbMirror = [];

  // Private constructor
  SqlDatabase._internal();

  // Static instance of the class
  static final SqlDatabase _instance = SqlDatabase._internal();

  // Factory constructor to always return the same instance
  factory SqlDatabase() {
    return _instance;
  }

  // Queries
  @visibleForTesting
  String setupQuery =
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

  // Method to load the database
  Future<void> loadSqlDatabase() async{
    databaseFactory = databaseFactoryFfi;
    // open the database
    db = await openDatabase(dbDirectory, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(setupQuery);
        });
  }

  // Method to initialize the database
  Future<void> initSqlDatabase() async{
    await getDirectory();
    await loadSqlDatabase();
  }

  // Method to insert or replace entry
  Future<void> insertEntry(VocabEntry entry) async {
    await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
    });
  }

  saveSqlDatabase() async{

  }

  // Method to delete the database file
  Future<void> deleteSqlDatabase() async {
    // delete the database file
    await deleteDatabase(dbDirectory);
  }
}

class VocabEntry {
  int vocabKey;
  String languageA;
  String wordA;
  String languageB;
  String wordB;
  String? sentenceB;
  String? articleB;
  String? comment;
  int? boxNumber;
  int timeLearned;
  int timeModified;

  VocabEntry({
    required this.vocabKey,
    required this.languageA,
    required this.wordA,
    required this.languageB,
    required this.wordB,
    this.sentenceB,
    this.articleB,
    this.comment,
    this.boxNumber,
    required this.timeLearned,
    required this.timeModified});
}