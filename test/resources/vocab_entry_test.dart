
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

void main() {
  group('VocabEntry Tests', () {
    test('VocabEntry creation', () {
      VocabEntry entry1 = VocabEntry(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 0,
          timeModified: 1);
      expect(entry1.vocabKey, 1);
      expect(entry1.languageA, 'en');
      expect(entry1.wordA, 'test');
      expect(entry1.languageB, 'es');
      expect(entry1.wordB, 'prueba');
      expect(entry1.timeModified, 1);
      expect(entry1.sentenceB, '');
      expect(entry1.articleB, '');
      expect(entry1.comment, '');
      expect(entry1.boxNumber, 0);

      entry1.sentenceB = 'This is a sentence.';
      entry1.articleB = 'The';
      entry1.comment = 'This is a comment.';
      entry1.boxNumber = 1;

      expect(entry1.sentenceB, 'This is a sentence.');
      expect(entry1.articleB, 'The');
      expect(entry1.comment, 'This is a comment.');
      expect(entry1.boxNumber, 1);
    });
    test('VocabEntry toMap', () {
      VocabEntry entry1 = VocabEntry(
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
      Map<String, dynamic> map = entry1.toMap();
      expect(map['vocab_key'], 1);
      expect(map['language_a'], 'en');
      expect(map['word_a'], 'test');
      expect(map['language_b'], 'es');
      expect(map['word_b'], 'prueba');
      expect(map['sentence_b'], 'This is a sentence.');
      expect(map['article_b'], 'The');
      expect(map['comment'], 'This is a comment.');
      expect(map['box_number'], 1);
      expect(map['time_modified'], 1);
    });
    test('VocabEntry fromMap', () {
      VocabEntry entry1 = VocabEntry(
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
      Map<String, dynamic> map = entry1.toMap();
      VocabEntry entry1CopyFromMap = VocabEntry.fromMap(map);
      expect(entry1CopyFromMap.vocabKey, 1);
      expect(entry1CopyFromMap.languageA, 'en');
      expect(entry1CopyFromMap.wordA, 'test');
      expect(entry1CopyFromMap.languageB, 'es');
      expect(entry1CopyFromMap.wordB, 'prueba');
      expect(entry1CopyFromMap.sentenceB, 'This is a sentence.');
      expect(entry1CopyFromMap.articleB, 'The');
      expect(entry1CopyFromMap.comment, 'This is a comment.');
      expect(entry1CopyFromMap.boxNumber, 1);
      expect(entry1CopyFromMap.timeModified, 1);
      expect(entry1.hashCode, isNot(entry1CopyFromMap.hashCode));
      // Proof, that the hashCode is unique for an object
      VocabEntry entry1same = entry1;
      expect(entry1.hashCode, entry1same.hashCode);
    });
    test('Copy constructor', () {
      VocabEntry entry1 = VocabEntry(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          sentenceB: 'This is a sentence.',
          articleB: 'The',
          comment: 'This is a comment.',
          boxNumber: 0,
          timeModified: 1);
      VocabEntry entry1Copy = entry1.clone();
      expect(entry1.hashCode, isNot(entry1Copy.hashCode)); // Proof, that its not the same object
      // Proof, that the values are the same
      expect(entry1.vocabKey, entry1Copy.vocabKey);
      expect(entry1.languageA, entry1Copy.languageA);
      expect(entry1.wordA, entry1Copy.wordA);
      expect(entry1.languageB, entry1Copy.languageB);
      expect(entry1.wordB, entry1Copy.wordB);
      expect(entry1.sentenceB, entry1Copy.sentenceB);
      expect(entry1.articleB, entry1Copy.articleB);
      expect(entry1.comment, entry1Copy.comment);
      expect(entry1.boxNumber, entry1Copy.boxNumber);
      expect(entry1.timeModified, entry1Copy.timeModified);
    });
    group('toCsv', () {
      test('toCsv with null values', () {
        VocabEntry entry1 = VocabEntry(
            vocabKey: 1,
            languageA: 'en',
            wordA: 'test',
            languageB: 'es',
            wordB: 'prueba',
            boxNumber: 1,
            timeModified: 1);
        String csv = entry1.toCsv();
        expect(csv, '1,"en","test","es","prueba",,,,1,1');
      });
      test('toCsv without null values', () {
        VocabEntry entry1 = VocabEntry(
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
        String csv = entry1.toCsv();
        expect(csv, '1,"en","test","es","prueba","This is a sentence.","The","This is a comment.",1,1');
      });
      test('toCsv with comma, line break and double quote', () {
        VocabEntry entry1 = VocabEntry(
            vocabKey: 1,
            languageA: 'en',
            wordA: 'test',
            languageB: 'es',
            wordB: 'prueba',
            sentenceB: '"This is a sentence with all combinations of comma, line\n break\n, double"" "quote", and carriage\n\r return\r.',
            articleB: 'The',
            comment: 'This is a comment.',
            boxNumber: 1,
            timeModified: 1);
        String csv = entry1.toCsv();
        expect(csv, '1,"en","test","es","prueba","""This is a sentence with all combinations of comma, line\n break\n, double"""" ""quote"", and carriage\n\r return\r.","The","This is a comment.",1,1');
      });
    });
    group('fromCsv', () {
      test('fromCsv with null values', () {
        VocabEntry entry1 = VocabEntry.fromCsv('1,"en","test","es","prueba",,,,1,1');
        expect(entry1.vocabKey, 1);
        expect(entry1.languageA, 'en');
        expect(entry1.wordA, 'test');
        expect(entry1.languageB, 'es');
        expect(entry1.wordB, 'prueba');
        expect(entry1.sentenceB, '');
        expect(entry1.articleB, '');
        expect(entry1.comment, '');
        expect(entry1.boxNumber, 1);
        expect(entry1.timeModified, 1);
      });
      test('fromCsv without null values', () {
        VocabEntry entry1 = VocabEntry.fromCsv('1,"en","test","es","prueba","This is a sentence.","The","This is a comment.",1,1');
        expect(entry1.vocabKey, 1);
        expect(entry1.languageA, 'en');
        expect(entry1.wordA, 'test');
        expect(entry1.languageB, 'es');
        expect(entry1.wordB, 'prueba');
        expect(entry1.sentenceB, 'This is a sentence.');
        expect(entry1.articleB, 'The');
        expect(entry1.comment, 'This is a comment.');
        expect(entry1.boxNumber, 1);
        expect(entry1.timeModified, 1);
      });
      test('fromCsv with comma, line break and double quote', () {
        VocabEntry entry1 = VocabEntry.fromCsv('1,"""","test","es","prueba","This is a sentence with all combinations of comma, line\n break\n, double"""" ""quote"", and carriage\n\r return\r.","The","This is a comment.",1,1');
        expect(entry1.vocabKey, 1);
        expect(entry1.languageA, '"');
        expect(entry1.wordA, 'test');
        expect(entry1.languageB, 'es');
        expect(entry1.wordB, 'prueba');
        expect(entry1.sentenceB, 'This is a sentence with all combinations of comma, line\n break\n, double"" "quote", and carriage\n\r return\r.');
        expect(entry1.articleB, 'The');
        expect(entry1.comment, 'This is a comment.');
        expect(entry1.boxNumber, 1);
        expect(entry1.timeModified, 1);
      });
      test('fromCsv with comma, line break and starting / ending with double quote', () {
        VocabEntry entry1 = VocabEntry.fromCsv('1,"""en","","""""","prueba","""This is a sentence with all combinations of comma, line\n break\n, double"""" ""quote"", and carriage\n\r return\r.""","The","This is a comment.",1,1');
        expect(entry1.vocabKey, 1);
        expect(entry1.languageA, '"en');
        expect(entry1.wordA, '');
        expect(entry1.languageB, '""');
        expect(entry1.wordB, 'prueba');
        expect(entry1.sentenceB, '"This is a sentence with all combinations of comma, line\n break\n, double"" "quote", and carriage\n\r return\r."');
        expect(entry1.articleB, 'The');
        expect(entry1.comment, 'This is a comment.');
        expect(entry1.boxNumber, 1);
        expect(entry1.timeModified, 1);
      });
    });
  });
}