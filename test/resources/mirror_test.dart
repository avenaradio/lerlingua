import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/mirror.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

void main() {
    group('DatabaseMirror Tests', () {
    test('writeEntry to DatabaseMirror (without updating sql database)', () {
      VocabEntry entry = VocabEntry(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          sentenceB: 'This is a sentence.',
          articleB: 'The',
          comment: 'This is a comment.',
          boxNumber: 1,
          timeModified: 1);
      Mirror().dbMirror.clear();
      // Write entry to DatabaseMirror
      VocabEntry entryClone = Mirror().writeEntry(entry: entry);
      expect(entry.hashCode, isNot(entryClone.hashCode));
      expect(Mirror().dbMirror.length, 1);
      expect(Mirror().dbMirror[0].hashCode, entryClone.hashCode);
      expect(Mirror().dbMirror[0].vocabKey, 1);
      // Add second entry
      entry.vocabKey = 2;
      VocabEntry entryClone2 = Mirror().writeEntry(entry: entry);
      expect(entry.hashCode, isNot(entryClone2.hashCode));
      expect(entryClone.hashCode, isNot(entryClone2.hashCode)); // 3 different objects
      expect(Mirror().dbMirror.length, 2);
      expect(Mirror().dbMirror[1].vocabKey, 2);
      // override first entry
      entry.vocabKey = 1;
      Mirror().writeEntry(entry: entry);
      expect(Mirror().dbMirror.length, 2);
      expect(Mirror().dbMirror[0].vocabKey, 1);
      // Add entry without key (key = -1)
      entry.vocabKey = -1;
      Mirror().writeEntry(entry: entry);
      expect(Mirror().dbMirror.length, 3);
      expect(Mirror().dbMirror[2].vocabKey, 3);
      // Add entry with key not in DatabaseMirror (key = 21)
      entry.vocabKey = 21;
      Mirror().writeEntry(entry: entry);
      expect(Mirror().dbMirror.length, 4);
      expect(Mirror().dbMirror[3].vocabKey, 21);
    });
    test('writeEntry should not save if vocabKey is -2', () {
      VocabEntry entry = VocabEntry(
          vocabKey: -2,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeModified: 1);
      Mirror().dbMirror.clear();
      Mirror().writeEntry(entry: entry);
      expect(Mirror().dbMirror.length, 0);
    });
    test('get entry from DatabaseMirror', () {
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
          timeModified: 1);
      Mirror().dbMirror.clear();
      expect(Mirror().readEntry(vocabKey: 0), null);
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 1;
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 3;
      Mirror().writeEntry(entry: entry);
      expect(Mirror().readEntry(vocabKey: 2)!.vocabKey, 2);
      expect(Mirror().readEntry(vocabKey: 99), null);
    });
    test('delete entry from DatabaseMirror', () {
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
          timeModified: 1);
      Mirror().dbMirror.clear();
      bool deleted = Mirror().deleteEntry(vocabKey: 0);
      expect(deleted, false);
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 1;
      Mirror().writeEntry(entry: entry);
      entry.vocabKey = 3;
      Mirror().writeEntry(entry: entry);
      deleted = Mirror().deleteEntry(vocabKey: 2);
      expect(Mirror().dbMirror.length, 2);
      expect(Mirror().dbMirror[0].vocabKey, 1);
      expect(Mirror().dbMirror[1].vocabKey, 3);
      expect(deleted, true);
      deleted = Mirror().deleteEntry(vocabKey: 99);
      expect(deleted, false);
    });
  });
}