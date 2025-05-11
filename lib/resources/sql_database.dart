
// Singleton
import 'dart:io';

import 'package:sqflite/sqflite.dart';

import 'file_handler.dart';

class SqlDatabase {
  late Database _vocabDatabase;
  late String _appDirectory;
  String vocabDatabaseSubDirectory = '/lerlingua.db';
  List<VocabEntry> _vocabDatabaseMirror = [];

  // Private constructor
  SqlDatabase._internal();

  // Static instance of the class
  static final SqlDatabase _instance = SqlDatabase._internal();

  // Factory constructor to always return the same instance
  factory SqlDatabase() {
    return _instance;
  }

  // Getter and setter
  String get _vocabDatabaseDirectory => '$_appDirectory$vocabDatabaseSubDirectory';

  // Queries
  // Setup
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


  // Method to initialize the database
  Future<void> initSqlDatabase() async{
    _appDirectory = (await FileHandler.getAppDirectory()).path;
    // open the database
    _vocabDatabase = await openDatabase(_vocabDatabaseDirectory, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(setupQuery);
        });
    // for each in _db write to _dbMirror

  }

  // Method to insert or replace entry
  Future<void> insertEntry(VocabEntry entry) async {
    await _vocabDatabase.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
    });
  }

  saveSqlDatabase() async{

  }

  // Method to delete the database file
  Future<void> deleteSqlDatabase() async {
    // delete the database file
    await deleteDatabase(_vocabDatabaseDirectory);
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