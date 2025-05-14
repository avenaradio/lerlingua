import 'package:flutter/cupertino.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

class EntriesFilter {
  @visibleForTesting
  List<VocabEntry> entriesList;

  EntriesFilter({required this.entriesList});

  // Sort getters
  EntriesFilter get sortByLanguageA {
    List<VocabEntry> sortedEntries = List.from(entriesList);
    sortedEntries.sort((a, b) => a.languageA.compareTo(b.languageA));
    return EntriesFilter(entriesList: sortedEntries);
  }

  EntriesFilter get sortByWordA {
    List<VocabEntry> sortedEntries = List.from(entriesList);
    sortedEntries.sort((a, b) => a.wordA.compareTo(b.wordA));
    return EntriesFilter(entriesList: sortedEntries);
  }

  EntriesFilter get sortByLanguageB {
    List<VocabEntry> sortedEntries = List.from(entriesList);
    sortedEntries.sort((a, b) => a.languageB.compareTo(b.languageB));
    return EntriesFilter(entriesList: sortedEntries);
  }

  EntriesFilter get sortByWordB {
    List<VocabEntry> sortedEntries = List.from(entriesList);
    sortedEntries.sort((a, b) => a.wordB.compareTo(b.wordB));
    return EntriesFilter(entriesList: sortedEntries);
  }

  EntriesFilter get sortByBoxNumber {
    List<VocabEntry> sortedEntries = List.from(entriesList);
    sortedEntries.sort((a, b) => a.boxNumber.compareTo(b.boxNumber));
    return EntriesFilter(entriesList: sortedEntries);
  }

  EntriesFilter get sortByTimeLearned {
    List<VocabEntry> sortedEntries = List.from(entriesList);
    sortedEntries.sort((a, b) => a.timeLearned.compareTo(b.timeLearned));
    return EntriesFilter(entriesList: sortedEntries);
  }

  EntriesFilter get sortByTimeModified {
    List<VocabEntry> sortedEntries = List.from(entriesList);
    sortedEntries.sort((a, b) => a.timeModified.compareTo(b.timeModified));
    return EntriesFilter(entriesList: sortedEntries);
  }

  // Invert order
  EntriesFilter get invertedOrder {
    List<VocabEntry> invertedEntries = List.from(entriesList.reversed);
    return EntriesFilter(entriesList: invertedEntries);
  }

  // Filter getters
  EntriesFilter filterByLanguageA(String languageA) {
    List<VocabEntry> filteredEntries = entriesList.where((entry) => entry.languageA == languageA).toList();
    return EntriesFilter(entriesList: filteredEntries);
  }

  EntriesFilter filterByWordA(String wordA) {
    List<VocabEntry> filteredEntries = entriesList.where((entry) => entry.wordA == wordA).toList();
    return EntriesFilter(entriesList: filteredEntries);
  }

  EntriesFilter filterByLanguageB(String languageB) {
    List<VocabEntry> filteredEntries = entriesList.where((entry) => entry.languageB == languageB).toList();
    return EntriesFilter(entriesList: filteredEntries);
  }

  EntriesFilter filterByWordB(String wordB) {
    List<VocabEntry> filteredEntries = entriesList.where((entry) => entry.wordB == wordB).toList();
    return EntriesFilter(entriesList: filteredEntries);
  }

  EntriesFilter filterByBoxNumber(int boxNumber) {
    List<VocabEntry> filteredEntries = entriesList.where((entry) => entry.boxNumber == boxNumber).toList();
    return EntriesFilter(entriesList: filteredEntries);
  }

  EntriesFilter filterByTimeLearned(int timeLearned) {
    List<VocabEntry> filteredEntries = entriesList.where((entry) => entry.timeLearned == timeLearned).toList();
    return EntriesFilter(entriesList: filteredEntries);
  }

  EntriesFilter filterByTimeModified(int timeModified) {
    List<VocabEntry> filteredEntries = entriesList.where((entry) => entry.timeModified == timeModified).toList();
    return EntriesFilter(entriesList: filteredEntries);
  }

  List<VocabEntry> get entries => entriesList.toList();
}