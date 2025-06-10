import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/general/tuple.dart';
import 'package:lerlingua/resources/database/sqlite/sqlite_database.dart';
import 'package:lerlingua/resources/database/sync/sync.dart';
import 'package:lerlingua/resources/database/sync/sync_utils_extension.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';


void main() {
  group('Sync Tests', () {
    Sync().clearLog();
    test('vocabCardsToCsv', () {
      VocabCard card1 = VocabCard(
          vocabKey: 1,
          languageA: 'a',
          wordA: 'b',
          languageB: 'c',
          wordB: 'd',
          boxNumber: 1,
          timeModified: 1);
      VocabCard card2 = VocabCard(
          vocabKey: 2,
          languageA: 'k',
          wordA: 'l',
          languageB: 'm',
          wordB: 'n',
          boxNumber: 2,
          timeModified: 2);
      String csvString = Sync().vocabCardsToCsv(cards: [card1, card2], deletedCards: '55/40/100');
      if (kDebugMode) {
        // print test name
        print('\nvocabCardsToCsv');
        print(Sync().syncLog);
      }
      expect(csvString, '${SqlDatabase().version}${List.filled(VocabCard.parametersCount - 1, ',').join()}55/40/100\n1,"a","b","c","d",,,,1,1\n2,"k","l","m","n",,,,2,2');
    });
  });
  group('csvToVocabCards Tests', () {
    test('csvToVocabCards should convert csv to list of VocabCard', () {
      Sync().clearLog();
      String csvString = '${SqlDatabase().version}${List.filled(VocabCard.parametersCount - 1, ',').join()}1/5/9\n1,"a","b","c","d",,,,1,1';
      Tuple3<int, String, List<VocabCard>>? tupleFromCsv = Sync().vocabCardsFromCsv(csvString);
      int csvDataVersion = tupleFromCsv?.first ?? 0;
      String deletedCards = tupleFromCsv?.second ?? '';
      List<VocabCard>? cards = tupleFromCsv?.third;
      if (kDebugMode) {
        // print test name
        print('\ncsvToVocabCards should convert csv to list of VocabCard');
        print(Sync().syncLog);
      }
      expect(cards!.length, 1);
      expect(cards[0].vocabKey, 1);
      expect(cards[0].languageA, 'a');
      expect(cards[0].wordA, 'b');
      expect(cards[0].languageB, 'c');
      expect(cards[0].wordB, 'd');
      expect(cards[0].sentenceB, '');
      expect(cards[0].articleB, '');
      expect(cards[0].comment, '');
      expect(cards[0].boxNumber, 1);
      expect(cards[0].timeModified, 1);
      expect(csvDataVersion, SqlDatabase().version);
      expect(deletedCards, '1/5/9');
    });
    test('csvToVocabCards should return empty list if csv is empty or null', () {
      Sync().clearLog();
      String? csvString1 = '';
      String? csvString2;
      Tuple3<int, String, List<VocabCard>>? tupleFromCsv1 = Sync().vocabCardsFromCsv(csvString1);
      Tuple3<int, String, List<VocabCard>>? tupleFromCsv2 = Sync().vocabCardsFromCsv(csvString2);
      List<VocabCard>? cards1 = tupleFromCsv1?.third;
      List<VocabCard>? cards2 = tupleFromCsv2?.third;
      if (kDebugMode) {
        // print test name
        print('\ncsvToVocabCards should return empty list if csv is empty or null');
        print(Sync().syncLog);
      }
      expect(cards1, []);
      expect(cards2, []);
    });
    test('csvToVocabCards valid csv but broken card should skip broken card', () {
      Sync().clearLog();
      String csvString = '${SqlDatabase().version}${List.filled(VocabCard.parametersCount - 1, ',').join()}\n1,"a","b","c","d",,,,1,1\n2,"k","l","m","n",,,,2,2\n3,,,,1,1\n4,"k","l","m","n",,,,2,2';
      Tuple3<int, String, List<VocabCard>>? tupleFromCsv = Sync().vocabCardsFromCsv(csvString);
      List<VocabCard>? cards = tupleFromCsv?.third;
      if (kDebugMode) {
        // print test name
        print('\ncsvToVocabCards valid csv but broken card should skip broken card');
        print(Sync().syncLog);
        print(cards);
      }
      expect(cards!.length, 3);
    });
  });
  group('mergeLists Tests', () {
    test('Should merge all when all vocabKey are different', () {
      List<VocabCard> listA = [];
      List<VocabCard> listB = [];
      listA.add(VocabCard(vocabKey: 1, languageA: 'a', wordA: 'b', languageB: 'c', wordB: 'd', boxNumber: 1, timeModified: 1));
      listA.add(VocabCard(vocabKey: 2, languageA: 'e', wordA: 'f', languageB: 'g', wordB: 'h', boxNumber: 1, timeModified: 1));
      listB.add(VocabCard(vocabKey: 3, languageA: 'i', wordA: 'j', languageB: 'k', wordB: 'l', boxNumber: 1, timeModified: 1));
      List<VocabCard> mergedList = Sync().mergeLists(listA: listA, listB: listB);
      expect(mergedList.length, 3);
    });
    test('Should keep newest when vocabKey are the same', () {
      List<VocabCard> listA = [];
      List<VocabCard> listB = [];
      listA.add(VocabCard(vocabKey: 1, languageA: 'a', wordA: 'b', languageB: 'c', wordB: 'd', boxNumber: 1, timeModified: 1));
      listA.add(VocabCard(vocabKey: 2, languageA: 'e', wordA: 'f', languageB: 'g', wordB: 'h', boxNumber: 1, timeModified: 1));
      listB.add(VocabCard(vocabKey: 2, languageA: 'i', wordA: 'j', languageB: 'k', wordB: 'l', boxNumber: 1, timeModified: 2));
      List<VocabCard> mergedList = Sync().mergeLists(listA: listA, listB: listB);
      expect(mergedList.length, 2);
      expect(mergedList[1].vocabKey, 2);
      expect(mergedList[1].timeModified, 2);
    });
  });
}