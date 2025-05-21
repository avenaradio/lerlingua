import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:lerlingua/resources/sync.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

extension SyncUtils on Sync {
  /// Converts a List of VocabEntry to a JSON string.
  /// - Tested
  @visibleForTesting
  String vocabEntriesToJson(List<VocabEntry> vocabEntries) {
    // Map each VocabEntry to a Map and then convert the list to JSON
    return jsonEncode(vocabEntries.map((entry) => entry.toMap()).toList());
  }

  /// Converts a JSON string back to a List of VocabEntry.
  /// - Tested
  @visibleForTesting
  List<VocabEntry>? vocabEntriesFromJson(String jsonString) {
    if(jsonString == '') {
      return [];
    }
    if(!jsonString.endsWith(']')) {
      return null;
    }
    // Decode the JSON string to a List of dynamic
    final List<dynamic> jsonList = jsonDecode(jsonString);
    // Map each dynamic to a VocabEntry using fromMap
    return jsonList.map((json) => VocabEntry.fromMap(json)).toList();
  }

  /// Uploads a List of VocabEntry to GitHub.
  Future<int> uploadEntries(List<VocabEntry> entries) async {
    String jsonString = vocabEntriesToJson(entries);
    return await uploadJsonToGitHub(jsonString: jsonString, fileType: FileType.cards);
  }

  /// Downloads a List of VocabEntry from GitHub.
  Future<List<VocabEntry>?> downloadEntries() async {
    String? jsonString = await downloadJsonFromGithub(fileType: FileType.cards);
    if (jsonString == null) return null;
    return vocabEntriesFromJson(jsonString);
  }

  /// Merges two lists of VocabEntry. Uses newer entries for conflicts.
  /// Tested
  List<VocabEntry> mergeLists({required List<VocabEntry> listA, required List<VocabEntry> listB}) {
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
    return listSync;
  }
}