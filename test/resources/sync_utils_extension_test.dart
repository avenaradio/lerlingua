import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/sql_database.dart';
import 'package:lerlingua/resources/sync.dart';
import 'package:lerlingua/resources/sync_utils_extension.dart';
import 'package:lerlingua/resources/vocab_entry.dart';


void main() {
  group('Sync Tests', () {
    Sync().clearLog();
    test('vocabEntriesToCsv', () {
      VocabEntry entry1 = VocabEntry(
          vocabKey: 1,
          languageA: 'a',
          wordA: 'b',
          languageB: 'c',
          wordB: 'd',
          boxNumber: 1,
          timeModified: 1);
      VocabEntry entry2 = VocabEntry(
          vocabKey: 2,
          languageA: 'k',
          wordA: 'l',
          languageB: 'm',
          wordB: 'n',
          boxNumber: 2,
          timeModified: 2);
      String csvString = Sync().vocabEntriesToCsv([entry1, entry2]);
      if (kDebugMode) {
        // print test name
        print('\nvocabEntriesToCsv');
        print(Sync().syncLog);
      }
      expect(csvString, '${SqlDatabase().version}${List.filled(VocabEntry.parametersCount - 1, ',').join()}\n1,"a","b","c","d",,,,1,1\n2,"k","l","m","n",,,,2,2');
    });
  });
  group('csvToVocabEntries Tests', () {
    test('csvToVocabEntries should convert csv to list of VocabEntry', () {
      Sync().clearLog();
      String csvString = '${SqlDatabase().version}${List.filled(VocabEntry.parametersCount - 1, ',').join()}\n1,"a","b","c","d",,,,1,1';
      List<VocabEntry>? entries = Sync().vocabEntriesFromCsv(csvString);
      if (kDebugMode) {
        // print test name
        print('\ncsvToVocabEntries should convert csv to list of VocabEntry');
        print(Sync().syncLog);
      }
      expect(entries!.length, 1);
      expect(entries[0].vocabKey, 1);
      expect(entries[0].languageA, 'a');
      expect(entries[0].wordA, 'b');
      expect(entries[0].languageB, 'c');
      expect(entries[0].wordB, 'd');
      expect(entries[0].sentenceB, '');
      expect(entries[0].articleB, '');
      expect(entries[0].comment, '');
      expect(entries[0].boxNumber, 1);
      expect(entries[0].timeModified, 1);
    });
    test('csvToVocabEntries should return empty list if csv is empty or null', () {
      Sync().clearLog();
      String? csvString1 = '';
      String? csvString2;
      List<VocabEntry>? entries1 = Sync().vocabEntriesFromCsv(csvString1);
      List<VocabEntry>? entries2 = Sync().vocabEntriesFromCsv(csvString2);
      if (kDebugMode) {
        // print test name
        print('\ncsvToVocabEntries should return empty list if csv is empty or null');
        print(Sync().syncLog);
      }
      expect(entries1, []);
      expect(entries2, []);
    });
    test('csvToVocabEntries valid csv but broken card should skip broken card', () {
      Sync().clearLog();
      String csvString = '${SqlDatabase().version}${List.filled(VocabEntry.parametersCount - 1, ',').join()}\n1,"a","b","c","d",,,,1,1\n2,"k","l","m","n",,,,2,2\n3,,,,1,1\n4,"k","l","m","n",,,,2,2';
      List<VocabEntry>? entries = Sync().vocabEntriesFromCsv(csvString);
      if (kDebugMode) {
        // print test name
        print('\ncsvToVocabEntries valid csv but broken card should skip broken card');
        print(Sync().syncLog);
        print(entries);
      }
      expect(entries!.length, 3);
    });
  });
  group('mergeLists Tests', () {
    test('Should merge all when all vocabKey are different', () {
      List<VocabEntry> listA = [];
      List<VocabEntry> listB = [];
      listA.add(VocabEntry(vocabKey: 1, languageA: 'a', wordA: 'b', languageB: 'c', wordB: 'd', boxNumber: 1, timeModified: 1));
      listA.add(VocabEntry(vocabKey: 2, languageA: 'e', wordA: 'f', languageB: 'g', wordB: 'h', boxNumber: 1, timeModified: 1));
      listB.add(VocabEntry(vocabKey: 3, languageA: 'i', wordA: 'j', languageB: 'k', wordB: 'l', boxNumber: 1, timeModified: 1));
      List<VocabEntry> mergedList = Sync().mergeLists(listA: listA, listB: listB);
      expect(mergedList.length, 3);
    });
    test('Should keep newest when vocabKey are the same', () {
      List<VocabEntry> listA = [];
      List<VocabEntry> listB = [];
      listA.add(VocabEntry(vocabKey: 1, languageA: 'a', wordA: 'b', languageB: 'c', wordB: 'd', boxNumber: 1, timeModified: 1));
      listA.add(VocabEntry(vocabKey: 2, languageA: 'e', wordA: 'f', languageB: 'g', wordB: 'h', boxNumber: 1, timeModified: 1));
      listB.add(VocabEntry(vocabKey: 2, languageA: 'i', wordA: 'j', languageB: 'k', wordB: 'l', boxNumber: 1, timeModified: 2));
      List<VocabEntry> mergedList = Sync().mergeLists(listA: listA, listB: listB);
      expect(mergedList.length, 2);
      expect(mergedList[1].vocabKey, 2);
      expect(mergedList[1].timeModified, 2);
    });
  });
}