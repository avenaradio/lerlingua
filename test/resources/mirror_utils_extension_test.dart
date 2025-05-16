import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/enums/move_direction.dart';
import 'package:lerlingua/resources/mirror.dart';
import 'package:lerlingua/resources/mirror_utils_extension.dart';
import 'package:lerlingua/resources/mirror_undo_extension.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

void main () {
  test('time now propertys', () async {
    int now1 = DateTime.now().millisecondsSinceEpoch;

    await Future.delayed(const Duration(milliseconds: 20));
    int now2 = DateTime.now().millisecondsSinceEpoch;

    expect(now2, greaterThan(now1));
  });
  group('Mirror utils extension', () {
    test('get filtered entries from DatabaseMirror', () {
      VocabEntry entry = VocabEntry(
          vocabKey: 2,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          sentenceB: 'This is a sentence.',
          articleB: 'The',
          comment: 'This is a comment.',
          boxNumber: 1,
          timeLearned: 1,
          timeModified: 1);
      Mirror().dbMirror.clear();
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 1;
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 3;
      entry.boxNumber = 2;
      Mirror().writeEntry(entry: entry);
      // Assert
      expect(Mirror().filterEntries.filterByBoxNumber(1).sortByTimeLearned.entries.length, 2);
    });
    test('get oldest entry from DatabaseMirror', () {
      VocabEntry entry = VocabEntry(
          vocabKey: 2,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeLearned: 1,
          timeModified: 1);
      Mirror().dbMirror.clear();
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 1;
      entry.timeLearned = 50;
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 3;
      entry.timeLearned = 100;
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 4;
      entry.boxNumber = 0;
      entry.timeLearned = 0;
      Mirror().writeEntry(entry: entry);
      // Assert
      expect(Mirror().oldestLearnedBoxEntry(boxNumber: 1).timeLearned, 1);
    });
    test('get amount of entries in a box', () {
      VocabEntry entry = VocabEntry(
          vocabKey: 2,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeLearned: 1,
          timeModified: 1);
      Mirror().dbMirror.clear();
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 1;
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 3;
      entry.boxNumber = 2;
      Mirror().writeEntry(entry: entry);
      // Assert
      expect(Mirror().boxSize(boxNumber: 1), 2);
      expect(Mirror().boxSize(boxNumber: 2), 1);
    });
    test('Add stack to box', () {
      VocabEntry entry = VocabEntry(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 0,
          timeLearned: 1,
          timeModified: 1);
      Mirror().dbMirror.clear();
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 2;
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 3;
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 4;
      entry.boxNumber = 2;
      Mirror().writeEntry(entry: entry);
      // Act
      Mirror().addStack(stackSize: 2);
      // Assert
      expect(Mirror().boxSize(boxNumber: 0), 1);
      expect(Mirror().boxSize(boxNumber: 1), 2);
      expect(Mirror().boxSize(boxNumber: 2), 1);
      // Test Undo
      Mirror().undo();
      expect(Mirror().boxSize(boxNumber: 0), 3);
      expect(Mirror().boxSize(boxNumber: 1), 0);
      expect(Mirror().boxSize(boxNumber: 2), 1);
      expect(Mirror().readEntry(vocabKey: 1)?.timeModified, 1);
      expect(Mirror().readEntry(vocabKey: 1)?.timeLearned, 1);
      expect(Mirror().readEntry(vocabKey: 2)?.timeModified, 1);
      expect(Mirror().readEntry(vocabKey: 2)?.timeLearned, 1);
    });
    test('move entry to next', () {
      VocabEntry entry = VocabEntry(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeLearned: 1,
          timeModified: 1);
      Mirror().dbMirror.clear();
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 2;
      entry.timeModified = 2;
      entry.timeLearned = 2;
      entry.boxNumber = 5;
      Mirror().writeEntry(entry: entry);
      // Act
      entry = Mirror().oldestLearnedBoxEntry(boxNumber: 1);
      Mirror().move(entry: entry, direction: Direction.next, addNewUndo: true);
      entry = Mirror().oldestLearnedBoxEntry(boxNumber: 5);
      Mirror().move(entry: entry, direction: Direction.next, addNewUndo: true);
      // Assert
      // Time is updating
      expect(Mirror().readEntry(vocabKey: 2)?.timeModified, greaterThan(1747307675463));
      expect(Mirror().readEntry(vocabKey: 2)?.timeLearned, greaterThan(1747307675463));
      expect(Mirror().filterEntries.filterByBoxNumber(2).entries.length, 1);
      expect(Mirror().filterEntries.filterByBoxNumber(1).entries.length, 0);
      expect(Mirror().filterEntries.filterByBoxNumber(5).entries.length, 1);
      // Test Undo
      Mirror().undo();
      expect(Mirror().readEntry(vocabKey: 2)?.timeModified, 2);
      expect(Mirror().readEntry(vocabKey: 2)?.timeLearned, 2);
      expect(Mirror().readEntry(vocabKey: 1)?.timeModified, greaterThan(1747307675463));
      expect(Mirror().readEntry(vocabKey: 1)?.timeLearned, greaterThan(1747307675463));
      expect(Mirror().filterEntries.filterByBoxNumber(2).entries.length, 1);
      expect(Mirror().filterEntries.filterByBoxNumber(1).entries.length, 0);
      expect(Mirror().filterEntries.filterByBoxNumber(5).entries.length, 1);
    });
    test('move entry to previous', () {
      VocabEntry entry = VocabEntry(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeLearned: 1,
          timeModified: 1);
      Mirror().dbMirror.clear();
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 2;
      entry.timeModified = 2;
      entry.timeLearned = 2;
      entry.boxNumber = 5;
      Mirror().writeEntry(entry: entry);
      // Act
      entry = Mirror().oldestLearnedBoxEntry(boxNumber: 1);
      Mirror().move(entry: entry, direction: Direction.previous, addNewUndo: true);
      entry = Mirror().oldestLearnedBoxEntry(boxNumber: 5);
      Mirror().move(entry: entry, direction: Direction.previous, addNewUndo: true);
      // Assert
      expect(Mirror().filterEntries.filterByBoxNumber(0).entries.length, 0);
      expect(Mirror().filterEntries.filterByBoxNumber(1).entries.length, 1);
      expect(Mirror().filterEntries.filterByBoxNumber(4).entries.length, 1);
    });
    test('move entry to next', () {
      VocabEntry entry = VocabEntry(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeLearned: 1,
          timeModified: 1);
      Mirror().dbMirror.clear();
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 2;
      entry.timeModified = 2;
      entry.timeLearned = 2;
      entry.boxNumber = 5;
      Mirror().writeEntry(entry: entry);
      // Act
      entry = Mirror().oldestLearnedBoxEntry(boxNumber: 1);
      Mirror().move(entry: entry, direction: Direction.first, addNewUndo: true);
      entry = Mirror().oldestLearnedBoxEntry(boxNumber: 5);
      Mirror().move(entry: entry, direction: Direction.first, addNewUndo: true);
      // Assert
      expect(Mirror().filterEntries.filterByBoxNumber(2).entries.length, 0);
      expect(Mirror().filterEntries.filterByBoxNumber(1).entries.length, 2);
      expect(Mirror().filterEntries.filterByBoxNumber(5).entries.length, 0);
    });
  });
}