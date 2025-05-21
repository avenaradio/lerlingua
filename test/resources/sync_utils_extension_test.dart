import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/sync.dart';
import 'package:lerlingua/resources/sync_utils_extension.dart';
import 'package:lerlingua/resources/vocab_entry.dart';


void main() {
  group('Sync Tests', () {
    test('vocabEntriesToJson', () {
      VocabEntry entry1 = VocabEntry(
          vocabKey: 1,
          languageA: 'a',
          wordA: 'b',
          languageB: 'c',
          wordB: 'd',
          boxNumber: 1,
          timeModified: 1);
      String jsonString = Sync().vocabEntriesToJson([entry1]);
      expect(jsonString, '[{"vocab_key":1,"language_a":"a","word_a":"b","language_b":"c","word_b":"d","sentence_b":null,"article_b":null,"comment":null,"box_number":1,"time_modified":1}]');
    });
  });
  group('jsonToVocabEntries Tests', () {
    test('jsonToVocabEntries should convert json to list of VocabEntry', () {
      String jsonString = '[{"vocab_key":1,"language_a":"a","word_a":"b","language_b":"c","word_b":"d","sentence_b":null,"article_b":null,"comment":null,"box_number":1,"time_modified":1}]';
      List<VocabEntry>? entries = Sync().vocabEntriesFromJson(jsonString);
      expect(entries!.length, 1);
      expect(entries[0].vocabKey, 1);
      expect(entries[0].languageA, 'a');
      expect(entries[0].wordA, 'b');
      expect(entries[0].languageB, 'c');
      expect(entries[0].wordB, 'd');
      expect(entries[0].sentenceB, null);
      expect(entries[0].articleB, null);
      expect(entries[0].comment, null);
      expect(entries[0].boxNumber, 1);
      expect(entries[0].timeModified, 1);
    });
    test('jsonToVocabEntries should return null if jsin not ending with ]', () {
      String jsonString = '[{"vocab_key":1,"language_a":"a","word_a":"b","language_b":"c","word_b":"d","sentence_b":null,"article_b":null,"comment":null,"box_number":1,"time_modified":1';
      List<VocabEntry>? entries = Sync().vocabEntriesFromJson(jsonString);
      expect(entries, null);
    });
    test('jsonToVocabEntries should return empty list if json is empty or []', () {
      String jsonString1 = '[]';
      String jsonString2 = '';
      List<VocabEntry>? entries1 = Sync().vocabEntriesFromJson(jsonString1);
      List<VocabEntry>? entries2 = Sync().vocabEntriesFromJson(jsonString2);
      expect(entries1, []);
      expect(entries2, []);
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