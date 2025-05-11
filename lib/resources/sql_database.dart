
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

  // Method to load the database
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
    _dbMirror = await readAllEntries();
  }

  // Method to insert or replace an entry
  Future<void> insertOrReplaceEntry(VocabEntry entry) async {
    await db.insert(
      'vocab',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Method to read an entry by its vocab_key
  Future<VocabEntry?> readSingleEntry(int vocabKey) async {
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

  // Convert VocabEntry to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'vocab_key': vocabKey == 0 ? null : vocabKey,
      'language_a': languageA,
      'word_a': wordA,
      'language_b': languageB,
      'word_b': wordB,
      'sentence_b': sentenceB,
      'article_b': articleB,
      'comment': comment,
      'box_number': boxNumber,
      'time_learned': timeLearned,
      'time_modified': timeModified,
    };
  }

  // Converts a Map to a VocabEntry instance
  static VocabEntry fromMap(Map<String, dynamic> map) {
    return VocabEntry(
      vocabKey: map['vocab_key'] as int,
      languageA: map['language_a'] as String,
      wordA: map['word_a'] as String,
      languageB: map['language_b'] as String,
      wordB: map['word_b'] as String,
      sentenceB: map['sentence_b'] as String?,
      articleB: map['article_b'] as String?,
      comment: map['comment'] as String?,
      boxNumber: map['box_number'] as int?,
      timeLearned: map['time_learned'] as int,
      timeModified: map['time_modified'] as int,
    );
  }
}