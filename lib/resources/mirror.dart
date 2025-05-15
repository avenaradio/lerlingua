// Singleton
import 'package:lerlingua/global_variables.dart';
import 'package:lerlingua/resources/sql_database.dart';
import 'package:lerlingua/resources/undo.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

class Mirror {
  List<VocabEntry> dbMirror = [];
  List<Undo> undoList = [];

  // Private constructor
  Mirror._internal();

  // Static instance of the class
  static final Mirror _instance = Mirror._internal();

  // Factory constructor to always return the same instance
  factory Mirror() {
    return _instance;
  }

  List<VocabEntry> get mirrorEntries => dbMirror;

  // Method to initialize the database
  Future<void> initDatabase() async{
    if (dbMirror.isNotEmpty) return;
    await SqlDatabase().initSqlDatabase();
    dbMirror = await SqlDatabase().readAllEntries();
  }

  // Method to add or replace entry in mirror
  VocabEntry writeEntry({required VocabEntry entry}) {
    if (entry.vocabKey == -2) return entry;
    entry = entry.clone(); // Hard Copy
    bool replaced = false;
    for (int i = 0; i < dbMirror.length; i++) {
      if (dbMirror[i].vocabKey == entry.vocabKey) {
        dbMirror[i] = entry; // Replace
        replaced = true;
        break;
      }
    }
    if (replaced == false) {
      if (entry.vocabKey == -1 || entry.vocabKey == 0) entry.vocabKey = dbMirror.length; // Add new key if -1 or null TODO TEST FOR  if entry.vocabKey == 0
      // if key already exists find a new one
      while (dbMirror.any((element) => element.vocabKey == entry.vocabKey)) {
        entry.vocabKey++;
      }
      dbMirror.add(entry);
    } // Add
    if (isTesting == true) return entry;
    SqlDatabase().insertOrReplaceEntry(entry: entry); // Update SQL database
    return entry;
  }

  // Method to get entry from mirror
  VocabEntry? readEntry({required int vocabKey}) {
    for (int i = 0; i < dbMirror.length; i++) {
      if (dbMirror[i].vocabKey == vocabKey) return dbMirror[i];
    }
    return null;
  }

  // Method to delete entry from mirror
  bool deleteEntry({required int vocabKey}) {
    bool deleted = false;
    for (int i = 0; i < dbMirror.length; i++) {
      if (dbMirror[i].vocabKey == vocabKey) {
        dbMirror.removeAt(i);
        deleted = true;
      }
    }
    if (isTesting == true) return deleted;
    SqlDatabase().deleteEntry(vocabKey: vocabKey);
    return deleted;
  }
}