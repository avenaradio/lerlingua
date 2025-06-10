import 'package:lerlingua/resources/database/sqlite/sqlite_database.dart';
import 'package:lerlingua/resources/database/sync/sync.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';

import '../../../general/tuple.dart';

extension SyncUtils on Sync {
  /// Converts a List&lt;VocabCard&gt; to a csv string.
  /// Returns csv string
  /// - Tested
  String vocabCardsToCsv({required List<VocabCard> cards, required String deletedCards}) {
    syncLog += ('Converting List of VocabCard to csv string...\n');
    // Convert each VocabCard to a csv string and join them with \n into a single string
    String csvString = cards.map((e) => e.toCsv()).join('\n');
    csvString = '${SqlDatabase().version}${List.filled(VocabCard.parametersCount - 1, ',').join()}$deletedCards\n$csvString'; // Add database version as first line
    return csvString;
  }

  /// Converts a csv string to a List&lt;String&gt; <br>
  /// - Indirect Test by vocabCardsFromCsv
  List<String> csvDecode(String csv) {
    syncLog += ('Decoding csv string...\n');
    List<String> csvList = csv.split('\n');
    List<String> cardStrings = [];
    for (int i = 0; i < csvList.length; i++) {
      String field = csvList[i];
      if (field.isNotEmpty) {
        // Count the number of quotes in the field
        int quoteCount = field.split('"').length - 1;
        while (quoteCount % 2 == 1 && i < csvList.length - 1) {
          field += '\n${csvList[++i]}';
          quoteCount = field.split('"').length - 1;
        }
      }
      cardStrings.add(field);
    }
    return cardStrings;
  }

  /// Converts a csv string back to a List&lt;VocabCard&gt. <br>
  /// Returns Tuple3&lt;int, String, List&lt;VocabCard&gt;&gt;:
  /// - csvDataVersion: [int]
  /// - deletedCards: [String]
  /// - cards: [List&lt;VocabCard&gt;]
  /// - null if error
  /// <br><br>
  /// - Tested
  Tuple3<int, String, List<VocabCard>>? vocabCardsFromCsv(String? csvString) {
    syncLog += ('Converting csv string to List of VocabCard...\n');
    if(csvString == '' || csvString == null) {
      syncLog += ('CSV string is empty, returning empty list\n');
      return Tuple3(0, '', []);
    }
    // Decode the csv string to a List of dynamic
    late List<String> csvList;
    try {
      csvList = csvDecode(csvString);
    } catch (e) {
      syncLog += ('Error decoding csv: $e\n');
      return null;
    }
    int csvDataVersion = int.tryParse(csvList.first.split(',').first) ?? 0; // DATABASE VERSION CHECK IF MERGE IS NEEDED
    syncLog += ('Database version of csv: ${csvDataVersion == 0 ? 'error' : csvDataVersion}\n');
    String deletedCards = csvList.first.split(',').last;
    csvList.removeAt(0);
    // Convert each String into VocabCard
    List<VocabCard> vocabCards = [];
    for (String cardString in csvList) {
      try {
        vocabCards.add(VocabCard.fromCsv(cardString));
      } catch (e) {
        syncLog += ('Error while converting card from csv: $e\n');
      }
    }
    syncLog += ('List of VocabCard created from csv\n');
    return Tuple3(csvDataVersion, deletedCards, vocabCards);
  }

  /// Merges two List&lt;VocabCard&gt;. <br>
  /// Uses newer cards for conflicts.
  /// - Tested
  List<VocabCard> mergeLists({required List<VocabCard> listA, required List<VocabCard> listB}) {
    syncLog += ('Merging lists...\n');
    int lehgthA = listA.length, lengthB = listB.length;
    List<VocabCard> listSync = [];
    // Copy listA to listSync
    for(VocabCard card in listA) {
      listSync.add(card);
    }
    // Merge listB into listSync (overwrite if newer)
    for(VocabCard card in listB) {
      // If sync list contains card with same vocabKey
      if(listSync.any((element) => element.vocabKey == card.vocabKey)) {
        // Use card where timeModified is newer
        if(card.timeModified > listSync.firstWhere((element) => element.vocabKey == card.vocabKey).timeModified) {
          listSync[listSync.indexOf(listSync.firstWhere((element) => element.vocabKey == card.vocabKey))] = card;
        }
      } else {
        // Add card to listSync if vocabKey does not exist
        listSync.add(card);
      }
    }
    syncLog += ('Lists merged: From: $lehgthA and $lengthB to ${listSync.length} cards.\n');
    return listSync;
  }
}