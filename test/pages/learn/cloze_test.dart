
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/pages/learn/cloze.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

void main() {
  group('Cloze', () {
    test('Splits sentenceB on %', () {
      VocabEntry card =  VocabEntry(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: 'This is a %cloze% with percent %signs%.', boxNumber: 1, timeLearned: 1, timeModified: 1,);
      Cloze cloze = Cloze(card: card,);
      expect(cloze.parts, ['This is a ', 'cloze', ' with percent ', 'signs', '.']);
    });
    test('if sentenceB starts with % first String should be empty', () {
      VocabEntry card =  VocabEntry(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: '%This% is a %cloze% with percent %signs%.', boxNumber: 1, timeLearned: 1, timeModified: 1,);
      Cloze cloze = Cloze(card: card,);
      expect(cloze.parts, ['', 'This', ' is a ', 'cloze', ' with percent ', 'signs', '.']);
    });
    test('createWidgets', () {
      VocabEntry card =  VocabEntry(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: '%This% is a %cloze% with percent %signs%.', boxNumber: 1, timeLearned: 1, timeModified: 1,);
      Cloze cloze = Cloze(card: card,);
      // Act
      int textWidgets = 0;
      int inputWidgets = 0;
      for (int i = 0; i < cloze.widgets.length; i++) {
        if (cloze.widgets[i].runtimeType == Text) {
          textWidgets++;
        } else if (cloze.widgets[i].runtimeType == TextFormField) {
          inputWidgets++;
        }
      }
      expect(textWidgets, 4);
      expect(inputWidgets, 3);
    });
  });
}