
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

void main() {
  late VocabEntry entry1;

  group('VocabEntry Tests', () {
    entry1 = VocabEntry(
        vocabKey: 1,
        languageA: 'en',
        wordA: 'test',
        languageB: 'es',
        wordB: 'prueba',
        boxNumber: 0,
        timeLearned: 1,
        timeModified: 1);
    Map<String, dynamic> map = {};
    test('VocabEntry creation', () {
      expect(entry1.vocabKey, 1);
      expect(entry1.languageA, 'en');
      expect(entry1.wordA, 'test');
      expect(entry1.languageB, 'es');
      expect(entry1.wordB, 'prueba');
      expect(entry1.timeLearned, 1);
      expect(entry1.timeModified, 1);
      expect(entry1.sentenceB, null);
      expect(entry1.articleB, null);
      expect(entry1.comment, null);
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
      map = entry1.toMap();
      expect(map['vocab_key'], 1);
      expect(map['language_a'], 'en');
      expect(map['word_a'], 'test');
      expect(map['language_b'], 'es');
      expect(map['word_b'], 'prueba');
      expect(map['sentence_b'], 'This is a sentence.');
      expect(map['article_b'], 'The');
      expect(map['comment'], 'This is a comment.');
      expect(map['box_number'], 1);
      expect(map['time_learned'], 1);
      expect(map['time_modified'], 1);
    });
    test('VocabEntry fromMap', () {
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
      expect(entry1CopyFromMap.timeLearned, 1);
      expect(entry1CopyFromMap.timeModified, 1);
      expect(entry1.hashCode, isNot(entry1CopyFromMap.hashCode));
      // Proof, that the hashCode is unique for an object
      VocabEntry entry1same = entry1;
      expect(entry1.hashCode, entry1same.hashCode);
    });
    test('Copy constructor', () {
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
      expect(entry1.timeLearned, entry1Copy.timeLearned);
      expect(entry1.timeModified, entry1Copy.timeModified);
    });
  });
}