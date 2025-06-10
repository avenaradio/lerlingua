// Singleton
import 'package:lerlingua/global_variables/global_variables.dart';
import 'package:lerlingua/resources/database/mirror/mirror_undo_extension.dart';
import 'package:lerlingua/resources/settings/settings.dart';
import 'package:lerlingua/resources/database/sqlite/sqlite_database.dart';
import 'package:lerlingua/resources/database/mirror/undo.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';

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

  /// Clears the undo list
  void clearUndo() {
    undoList = [];
  }

  /// Initializes the database
  Future<void> initDatabase() async{
    if (dbMirror.isNotEmpty) return;
    await SqlDatabase().initSqlDatabase();
    dbMirror = await SqlDatabase().readAllCards();
  }

  /// Adds or replaces card in mirror
  /// - Tested
  VocabCard writeCard({required VocabCard card, required bool addNewUndo}) {
    if (card.vocabKey == -2) return card;
    Undo undo = Undo(description: 'Undo: Edit card');
    card = card.clone(); // Hard Copy
    bool replaced = false;
    for (int i = 0; i < dbMirror.length; i++) {
      if (dbMirror[i].vocabKey == card.vocabKey) {
        if (addNewUndo == true) {
          VocabCard oldCardCopy = dbMirror[i].clone();
          undo.addFunction(() => writeCard(card: oldCardCopy, addNewUndo: false));
          addUndo(undo: undo);
        }
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

  /// Reads card from mirror
  /// - Tested
  VocabCard? readCard({required int vocabKey}) {
    for (int i = 0; i < dbMirror.length; i++) {
      if (dbMirror[i].vocabKey == vocabKey) return dbMirror[i];
    }
    return null;
  }

  /// Deletes card from mirror
  /// - Tested
  bool deleteCard({required VocabCard card}) {
    if(card.vocabKey == -2) return false;
    Undo undo = Undo(description: 'Undo: Delete card');
    bool deleted = false;
    for (int i = 0; i < dbMirror.length; i++) {
      if (dbMirror[i].vocabKey == card.vocabKey) {
        VocabCard cardCopy = card.clone();
        undo.addFunction(() => writeCard(card: cardCopy, addNewUndo: false));
        undo.addFunction(() => Settings().removeDeletedCards(card.vocabKey.toString()));
        addUndo(undo: undo);
        dbMirror.removeAt(i);
        deleted = true;
      }
    }
    Settings().addDeletedCards(card.vocabKey.toString());
    if (isTesting == true) return deleted;
    SqlDatabase().deleteCard(vocabKey: card.vocabKey);
    return deleted;
  }
}