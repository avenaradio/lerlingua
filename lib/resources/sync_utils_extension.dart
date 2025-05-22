import 'package:lerlingua/resources/sql_database.dart';
import 'package:lerlingua/resources/sync.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

extension SyncUtils on Sync {
  /// Converts a List&lt;VocabEntry&gt; to a csv string.
  /// Returns csv string
  /// - Tested
  String vocabEntriesToCsv(List<VocabEntry> vocabEntries) {
    syncLog += ('Converting List of VocabEntry to csv string...\n');
    // Convert each VocabEntry to a csv string and join them with \n into a single string
    String csvString = vocabEntries.map((e) => e.toCsv()).join('\n');
    csvString = '${SqlDatabase().version}${List.filled(VocabEntry.parametersCount - 1, ',').join()}\n$csvString'; // Add database version as first line
    return csvString;
  }

  /// Converts a csv string to a List&lt;String&gt; <br>
  /// - Indirect Test of vocabEntriesFromCsv
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

  /// Converts a csv string back to a List&lt;VocabEntry&gt. <br>
  /// Returns List&lt;VocabEntry&gt;, null if error
  /// - Tested
  List<VocabEntry>? vocabEntriesFromCsv(String? csvString) {
    syncLog += ('Converting csv string to List of VocabEntry...\n');
    if(csvString == '' || csvString == null) {
      syncLog += ('CSV string is empty, returning empty list\n');
      return [];
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
    csvList.removeAt(0);
    // Convert each String into VocabEntry
    List<VocabEntry> vocabEntries = [];
    for (String cardString in csvList) {
      try {
        vocabEntries.add(VocabEntry.fromCsv(cardString));
      } catch (e) {
        syncLog += ('Error while converting card from csv: $e\n');
      }
    }
    syncLog += ('List of VocabEntry created from JSON csv\n');
    return vocabEntries;
  }

  /// Merges two List&lt;VocabEntry&gt;. <br>
  /// Uses newer entries for conflicts.
  /// - Tested
  List<VocabEntry> mergeLists({required List<VocabEntry> listA, required List<VocabEntry> listB}) {
    syncLog += ('Merging lists...\n');
    int lehgthA = listA.length, lengthB = listB.length;
    List<VocabEntry> listSync = [];
    // Copy listA to listSync
    for(VocabEntry entry in listA) {
      listSync.add(entry);
    }
    // Merge listB into listSync (overwrite if newer)
    for(VocabEntry entry in listB) {
      // If sync list contains entry with same vocabKey
      if(listSync.any((element) => element.vocabKey == entry.vocabKey)) {
        // Use entry where timeModified is newer
        if(entry.timeModified > listSync.firstWhere((element) => element.vocabKey == entry.vocabKey).timeModified) {
          listSync[listSync.indexOf(listSync.firstWhere((element) => element.vocabKey == entry.vocabKey))] = entry;
        }
      } else {
        // Add entry to listSync if vocabKey does not exist
        listSync.add(entry);
      }
    }
    syncLog += ('Lists merged: From: $lehgthA and $lengthB to ${listSync.length} cards.\n');
    return listSync;
  }
}