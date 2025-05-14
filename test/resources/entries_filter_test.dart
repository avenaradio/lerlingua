import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/vocab_entry.dart';
import 'package:lerlingua/resources/entries_filter.dart';

void main() {
  group('EntriesFilter', () {
    late List<VocabEntry> entries;
    late EntriesFilter entriesFilter;

    setUp(() {
      entries = [
        VocabEntry(
          vocabKey: 1,
          languageA: 'English',
          wordA: 'Hello',
          languageB: 'Spanish',
          wordB: 'Hola',
          boxNumber: 1,
          timeLearned: 10,
          timeModified: 5,
        ),
        VocabEntry(
          vocabKey: 2,
          languageA: 'English',
          wordA: 'Goodbye',
          languageB: 'Spanish',
          wordB: 'Adiós',
          boxNumber: 2,
          timeLearned: 20,
          timeModified: 15,
        ),
        VocabEntry(
          vocabKey: 3,
          languageA: 'French',
          wordA: 'Bonjour',
          languageB: 'English',
          wordB: 'Hello',
          boxNumber: 1,
          timeLearned: 5,
          timeModified: 2,
        ),
      ];
      entriesFilter = EntriesFilter(entriesList: entries);
    });

    test('sorts by languageA', () {
      final sortedEntries = entriesFilter.sortByLanguageA.entries;
      expect(sortedEntries[0].languageA, 'English');
      expect(sortedEntries[1].languageA, 'English');
      expect(sortedEntries[2].languageA, 'French');
    });

    test('sorts by wordA', () {
      final sortedEntries = entriesFilter.sortByWordA.entries;
      expect(sortedEntries[0].wordA, 'Bonjour');
      expect(sortedEntries[1].wordA, 'Goodbye');
      expect(sortedEntries[2].wordA, 'Hello');
    });

    test('sorts by languageB', () {
      final sortedEntries = entriesFilter.sortByLanguageB.entries;
      expect(sortedEntries[0].languageB, 'English');
      expect(sortedEntries[1].languageB, 'Spanish');
      expect(sortedEntries[2].languageB, 'Spanish');
    });

    test('sorts by wordB', () {
      final sortedEntries = entriesFilter.sortByWordB.entries;
      expect(sortedEntries[0].wordB, 'Adiós');
      expect(sortedEntries[1].wordB, 'Hello');
      expect(sortedEntries[2].wordB, 'Hola');
    });

    test('sorts by boxNumber', () {
      final sortedEntries = entriesFilter.sortByBoxNumber.entries;
      expect(sortedEntries[0].boxNumber, 1);
      expect(sortedEntries[1].boxNumber, 1);
      expect(sortedEntries[2].boxNumber, 2);
    });

    test('sorts by timeLearned', () {
      final sortedEntries = entriesFilter.sortByTimeLearned.entries;
      expect(sortedEntries[0].timeLearned, 5);
      expect(sortedEntries[1].timeLearned, 10);
      expect(sortedEntries[2].timeLearned, 20);
    });

    test('sorts by timeModified', () {
      final sortedEntries = entriesFilter.sortByTimeModified.entries;
      expect(sortedEntries[0].timeModified, 2);
      expect(sortedEntries[1].timeModified, 5);
      expect(sortedEntries[2].timeModified, 15);
    });

    test('inverts order', () {
      final invertedEntries = entriesFilter.invertedOrder.entries;
      expect(invertedEntries[0].vocabKey, 3);
      expect(invertedEntries[1].vocabKey, 2);
      expect(invertedEntries[2].vocabKey, 1);
    });

    test('filters by languageA', () {
      final filteredEntries = entriesFilter.filterByLanguageA('English').entries;
      expect(filteredEntries.length, 2);
      expect(filteredEntries[0].wordA, 'Hello');
      expect(filteredEntries[1].wordA, 'Goodbye');
    });

    test('filters by wordA', () {
      final filteredEntries = entriesFilter.filterByWordA('Hello').entries;
      expect(filteredEntries.length, 1);
      expect(filteredEntries[0].wordA, 'Hello');
    });

    test('filters by languageB', () {
      final filteredEntries = entriesFilter.filterByLanguageB('Spanish').entries;
      expect(filteredEntries.length, 2);
    });

    test('filters by wordB', () {
      final filteredEntries = entriesFilter.filterByWordB('Hola').entries;
      expect(filteredEntries.length, 1);
      expect(filteredEntries[0].wordB, 'Hola');
    });

    test('filters by boxNumber', () {
      final filteredEntries = entriesFilter.filterByBoxNumber(1).entries;
      expect(filteredEntries.length, 2);
    });

    test('filters by timeLearned', () {
      final filteredEntries = entriesFilter.filterByTimeLearned(10).entries;
      expect(filteredEntries.length, 1);
      expect(filteredEntries[0].timeLearned, 10);
    });

    test('filters by timeModified', () {
      final filteredEntries = entriesFilter.filterByTimeModified(5).entries;
      expect(filteredEntries.length, 1);
      expect(filteredEntries[0].timeModified, 5);
    });

    test('original List should not be modified', () {
      expect(entries.length, 3);
      expect(entries[0].vocabKey, 1);
      expect(entries[1].vocabKey, 2);
      expect(entries[2].vocabKey, 3);
      final filteredEntries = entriesFilter.filterByLanguageA('English').entries;
      expect(filteredEntries.length, 2);
      expect(entries.hashCode, isNot(filteredEntries.hashCode));
    });
  });
}