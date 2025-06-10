
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';

void main() {
  group('VocabCard Tests', () {
    test('VocabCard creation', () {
      VocabCard card1 = VocabCard(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 0,
          timeModified: 1);
      expect(card1.vocabKey, 1);
      expect(card1.languageA, 'en');
      expect(card1.wordA, 'test');
      expect(card1.languageB, 'es');
      expect(card1.wordB, 'prueba');
      expect(card1.timeModified, 1);
      expect(card1.sentenceB, '');
      expect(card1.articleB, '');
      expect(card1.comment, '');
      expect(card1.boxNumber, 0);

      card1.sentenceB = 'This is a sentence.';
      card1.articleB = 'The';
      card1.comment = 'This is a comment.';
      card1.boxNumber = 1;

      expect(card1.sentenceB, 'This is a sentence.');
      expect(card1.articleB, 'The');
      expect(card1.comment, 'This is a comment.');
      expect(card1.boxNumber, 1);
    });
    test('VocabCard toMap', () {
      VocabCard card1 = VocabCard(
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
      Map<String, dynamic> map = card1.toMap();
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
    test('VocabCard fromMap', () {
      VocabCard card1 = VocabCard(
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
      Map<String, dynamic> map = card1.toMap();
      VocabCard card1CopyFromMap = VocabCard.fromMap(map);
      expect(card1CopyFromMap.vocabKey, 1);
      expect(card1CopyFromMap.languageA, 'en');
      expect(card1CopyFromMap.wordA, 'test');
      expect(card1CopyFromMap.languageB, 'es');
      expect(card1CopyFromMap.wordB, 'prueba');
      expect(card1CopyFromMap.sentenceB, 'This is a sentence.');
      expect(card1CopyFromMap.articleB, 'The');
      expect(card1CopyFromMap.comment, 'This is a comment.');
      expect(card1CopyFromMap.boxNumber, 1);
      expect(card1CopyFromMap.timeModified, 1);
      expect(card1.hashCode, isNot(card1CopyFromMap.hashCode));
      // Proof, that the hashCode is unique for an object
      VocabCard card1same = card1;
      expect(card1.hashCode, card1same.hashCode);
    });
    test('Copy constructor', () {
      VocabCard card1 = VocabCard(
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
      VocabCard card1Copy = card1.clone();
      expect(card1.hashCode, isNot(card1Copy.hashCode)); // Proof, that its not the same object
      // Proof, that the values are the same
      expect(card1.vocabKey, card1Copy.vocabKey);
      expect(card1.languageA, card1Copy.languageA);
      expect(card1.wordA, card1Copy.wordA);
      expect(card1.languageB, card1Copy.languageB);
      expect(card1.wordB, card1Copy.wordB);
      expect(card1.sentenceB, card1Copy.sentenceB);
      expect(card1.articleB, card1Copy.articleB);
      expect(card1.comment, card1Copy.comment);
      expect(card1.boxNumber, card1Copy.boxNumber);
      expect(card1.timeModified, card1Copy.timeModified);
    });
    group('toCsv', () {
      test('toCsv with null values', () {
        VocabCard card1 = VocabCard(
            vocabKey: 1,
            languageA: 'en',
            wordA: 'test',
            languageB: 'es',
            wordB: 'prueba',
            boxNumber: 1,
            timeModified: 1);
        String csv = card1.toCsv();
        expect(csv, '1,"en","test","es","prueba",,,,1,1');
      });
      test('toCsv without null values', () {
        VocabCard card1 = VocabCard(
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
        String csv = card1.toCsv();
        expect(csv, '1,"en","test","es","prueba","This is a sentence.","The","This is a comment.",1,1');
      });
      test('toCsv with comma, line break and double quote', () {
        VocabCard card1 = VocabCard(
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
        String csv = card1.toCsv();
        expect(csv, '1,"en","test","es","prueba","""This is a sentence with all combinations of comma, line\n break\n, double"""" ""quote"", and carriage\n\r return\r.","The","This is a comment.",1,1');
      });
    });
    group('fromCsv', () {
      test('fromCsv with null values', () {
        VocabCard card1 = VocabCard.fromCsv('1,"en","test","es","prueba",,,,1,1');
        expect(card1.vocabKey, 1);
        expect(card1.languageA, 'en');
        expect(card1.wordA, 'test');
        expect(card1.languageB, 'es');
        expect(card1.wordB, 'prueba');
        expect(card1.sentenceB, '');
        expect(card1.articleB, '');
        expect(card1.comment, '');
        expect(card1.boxNumber, 1);
        expect(card1.timeModified, 1);
      });
      test('fromCsv without null values', () {
        VocabCard card1 = VocabCard.fromCsv('1,"en","test","es","prueba","This is a sentence.","The","This is a comment.",1,1');
        expect(card1.vocabKey, 1);
        expect(card1.languageA, 'en');
        expect(card1.wordA, 'test');
        expect(card1.languageB, 'es');
        expect(card1.wordB, 'prueba');
        expect(card1.sentenceB, 'This is a sentence.');
        expect(card1.articleB, 'The');
        expect(card1.comment, 'This is a comment.');
        expect(card1.boxNumber, 1);
        expect(card1.timeModified, 1);
      });
      test('fromCsv with comma, line break and double quote', () {
        VocabCard card1 = VocabCard.fromCsv('1,"""","test","es","prueba","This is a sentence with all combinations of comma, line\n break\n, double"""" ""quote"", and carriage\n\r return\r.","The","This is a comment.",1,1');
        expect(card1.vocabKey, 1);
        expect(card1.languageA, '"');
        expect(card1.wordA, 'test');
        expect(card1.languageB, 'es');
        expect(card1.wordB, 'prueba');
        expect(card1.sentenceB, 'This is a sentence with all combinations of comma, line\n break\n, double"" "quote", and carriage\n\r return\r.');
        expect(card1.articleB, 'The');
        expect(card1.comment, 'This is a comment.');
        expect(card1.boxNumber, 1);
        expect(card1.timeModified, 1);
      });
      test('fromCsv with comma, line break and starting / ending with double quote', () {
        VocabCard card1 = VocabCard.fromCsv('1,"""en","","""""","prueba","""This is a sentence with all combinations of comma, line\n break\n, double"""" ""quote"", and carriage\n\r return\r.""","The","This is a comment.",1,1');
        expect(card1.vocabKey, 1);
        expect(card1.languageA, '"en');
        expect(card1.wordA, '');
        expect(card1.languageB, '""');
        expect(card1.wordB, 'prueba');
        expect(card1.sentenceB, '"This is a sentence with all combinations of comma, line\n break\n, double"" "quote", and carriage\n\r return\r."');
        expect(card1.articleB, 'The');
        expect(card1.comment, 'This is a comment.');
        expect(card1.boxNumber, 1);
        expect(card1.timeModified, 1);
      });
    });
  });
}