import 'dart:convert';
import 'package:lerlingua/resources/sync.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

extension SyncUtils on Sync {
  /// Converts a list of VocabEntry to a JSON string.
  /// Returns JSON string
  /// - Tested
  String vocabEntriesToJson(List<VocabEntry> vocabEntries) {
    syncLog += ('Converting List of VocabEntry to JSON string...\n');
    // Map each VocabEntry to a Map and then convert the list to JSON
    return jsonEncode(vocabEntries.map((entry) => entry.toMap()).toList());
  }

  /// Converts a JSON string back to a List of VocabEntry. <br>
  /// Returns List&lt;VocabEntry&gt;, null if error
  /// - Tested
  List<VocabEntry>? vocabEntriesFromJson(String? jsonString) {
    syncLog += ('Converting JSON string to List of VocabEntry...\n');
    if(jsonString == '' || jsonString == null) {
      syncLog += ('JSON string is empty, returning empty list\n');
      return [];
    }
    // Decode the JSON string to a List of dynamic
    late List<dynamic> jsonList;
    try {
      jsonList = jsonDecode(jsonString);
    } catch (e) {
      syncLog += ('Error decoding JSON: $e\n');
      return null;
    }
    // Map each dynamic to a VocabEntry using fromMap
    List<VocabEntry> vocabEntries = [];
    for (var map in jsonList) {
      try {
        vocabEntries.add(VocabEntry.fromMap(map));
      } catch (e) {
        syncLog += ('Error while converting card from JSON: $e\n');
      }
    }
    syncLog += ('List of VocabEntry created from JSON string\n');
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