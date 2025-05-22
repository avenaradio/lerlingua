// Singleton
import 'package:lerlingua/global_variables.dart';
import 'package:lerlingua/resources/sql_database.dart';
import 'package:lerlingua/resources/undo.dart';
import 'package:lerlingua/resources/vocab_card.dart';

class Mirror {
  List<VocabCard> dbMirror = [];
  List<Undo> undoList = [];

  // Private constructor
  Mirror._internal();

  // Static instance of the class
  static final Mirror _instance = Mirror._internal();

  // Factory constructor to always return the same instance
  factory Mirror() {
    return _instance;
  }

  List<VocabCard> get mirrorCards => dbMirror;

  // Method to initialize the database
  Future<void> initDatabase() async{
    if (dbMirror.isNotEmpty) return;
    await SqlDatabase().initSqlDatabase();
    dbMirror = await SqlDatabase().readAllCards();
  }

  // Method to add or replace card in mirror
  VocabCard writeCard({required VocabCard card}) {
    if (card.vocabKey == -2) return card;
    card = card.clone(); // Hard Copy
    bool replaced = false;
    for (int i = 0; i < dbMirror.length; i++) {
      if (dbMirror[i].vocabKey == card.vocabKey) {
        dbMirror[i] = card; // Replace
        replaced = true;
        break;
      }
    }
    if (replaced == false) {
      if (card.vocabKey == -1 || card.vocabKey == 0) {
        card.vocabKey = DateTime.now().millisecondsSinceEpoch; // Add new key if -1 or 0
      }
      dbMirror.add(card);
    } // Add
    if (isTesting == true) return card;
    SqlDatabase().insertOrReplaceCard(card: card); // Update SQL database
    return card;
  }

  // Method to get card from mirror
  VocabCard? readCard({required int vocabKey}) {
    for (int i = 0; i < dbMirror.length; i++) {
      if (dbMirror[i].vocabKey == vocabKey) return dbMirror[i];
    }
    return null;
  }

  // Method to delete card from mirror
  bool deleteCard({required int vocabKey}) {
    bool deleted = false;
    for (int i = 0; i < dbMirror.length; i++) {
      if (dbMirror[i].vocabKey == vocabKey) {
        dbMirror.removeAt(i);
        deleted = true;
      }
    }
    if (isTesting == true) return deleted;
    SqlDatabase().deleteCard(vocabKey: vocabKey);
    return deleted;
  }
}