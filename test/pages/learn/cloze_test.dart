
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/user_interface/learn/cloze.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';

void main() {
  group('Cloze creation', () {
    test('Splits sentenceB on %%', () {
      VocabCard card =  VocabCard(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: 'This is a %%cloze%% with percent %%signs%%.', boxNumber: 1, timeModified: 1,);
      Cloze cloze = Cloze(card: card,);
      expect(cloze.parts, ['es: This is a ', 'cloze', ' with percent ', 'signs', '.']);
    });
    test('if sentenceB starts with %% first String should be empty', () {
      VocabCard card =  VocabCard(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: '%%This%% is a %%cloze%% with percent %%signs%%.', boxNumber: 1, timeModified: 1,);
      Cloze cloze = Cloze(card: card,);
      expect(cloze.parts, ['es: ', 'This', ' is a ', 'cloze', ' with percent ', 'signs', '.']);
    });
    test('if sentenceB is empty use wordB', () {
      VocabCard card =  VocabCard(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: null, boxNumber: 1, timeModified: 1,);
      Cloze cloze = Cloze(card: card,);
      expect(cloze.parts, ['es: ', 'prueba']);
    });
    test('createWidgets', () {
      VocabCard card =  VocabCard(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: '%%This%% is a %%cloze%% with percent %%signs%%.', boxNumber: 1, timeModified: 1,);
      Cloze cloze = Cloze(card: card,);
      // Act
      int textWidgets = 0;
      int inputWidgets = 0;
      for (int i = 0; i < cloze.widgets.length; i++) {
        if (cloze.widgets[i].runtimeType == Text) {
          textWidgets++;
        } else if (cloze.widgets[i].runtimeType == SizedBox) {
          inputWidgets++;
        }
      }
      expect(textWidgets, 6);
      expect(inputWidgets, 3);
    });
    /// #showCharacterOnSpace
    group('showCharacterOnSpace Tests', () {
      test('if not ending on space, do nothing', () {
        VocabCard card =  VocabCard(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: 'This is a %%cloze%% with percent %%signs%%.', boxNumber: 1, timeModified: 1,);
        Cloze cloze = Cloze(card: card,); // Any cloze object will do
        // Arrange
        TextEditingController controller = TextEditingController(text: 'wrong input');
        String hiddenText = 'test word';
        // Act
        cloze.showCharacterOnSpace(hiddenText: hiddenText, controller: controller);
        // Assert
        expect(controller.text, 'wrong input');
      });
      test('space should show next correct character', () {
        VocabCard card =  VocabCard(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: 'This is a %%cloze%% with percent %%signs%%.', boxNumber: 1, timeModified: 1,);
        Cloze cloze = Cloze(card: card,); // Any cloze object will do
        // Arrange
        TextEditingController controller = TextEditingController(text: 'inp ');
        String hiddenText = 'input should be this';
        // Act
        cloze.showCharacterOnSpace(hiddenText: hiddenText, controller: controller);
        // Assert
        expect(controller.text, 'inpu');
      });
      test('show next correct character if input ends with space and next correct character is space', () {
        VocabCard card =  VocabCard(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: 'This is a %%cloze%% with percent %%signs%%.', boxNumber: 1, timeModified: 1,);
        Cloze cloze = Cloze(card: card,); // Any cloze object will do
        // Arrange
        TextEditingController controller = TextEditingController(text: 'inputtt ');
        String hiddenText = 'input should be this';
        // Act
        cloze.showCharacterOnSpace(hiddenText: hiddenText, controller: controller);
        // Assert
        expect(controller.text, 'input ');
      });
      test('correct input ending with space should leave the space', () {
        VocabCard card =  VocabCard(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: 'This is a %%cloze%% with percent %%signs%%.', boxNumber: 1, timeModified: 1,);
        Cloze cloze = Cloze(card: card,); // Any cloze object will do
        // Arrange
        TextEditingController controller = TextEditingController(text: 'input ');
        String hiddenText = 'input should be this';
        // Act
        cloze.showCharacterOnSpace(hiddenText: hiddenText, controller: controller);
        // Assert
        expect(controller.text, 'input ');
      });
      test('if first part of input is correct but input is longer, cut off the rest', () {
        VocabCard card =  VocabCard(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: 'This is a %%cloze%% with percent %%signs%%.', boxNumber: 1, timeModified: 1,);
        Cloze cloze = Cloze(card: card,); // Any cloze object will do
        // Arrange
        TextEditingController controller = TextEditingController(text: 'input should be this and some wrong stuff ');
        String hiddenText = 'input should be this';
        // Act
        cloze.showCharacterOnSpace(hiddenText: hiddenText, controller: controller);
        // Assert
        expect(controller.text, 'input should be this');
      });
      test('if input and hidden text are the same, do nothing', () {
        VocabCard card =  VocabCard(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: 'This is a %%cloze%% with percent %%signs%%.', boxNumber: 1, timeModified: 1,);
        Cloze cloze = Cloze(card: card,); // Any cloze object will do
        // Arrange
        TextEditingController controller = TextEditingController(text: 'input should be this');
        String hiddenText = 'input should be this';
        // Act
        cloze.showCharacterOnSpace(hiddenText: hiddenText, controller: controller);
        // Assert
        expect(controller.text, 'input should be this');
      });
    });
    group('toggleShowAnswers Tests', () {
      test('toggle show answers', () {
        VocabCard card =  VocabCard(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: 'This is a %%cloze%% with percent %%signs%%.', boxNumber: 1, timeModified: 1,);
        Cloze cloze = Cloze(card: card,); // Any cloze object will do
        bool showAnswersOnCreation = cloze.showAnswers;
        // Act
        cloze.toggleShowAnswers();
        // Assert
        expect(cloze.showAnswers, !showAnswersOnCreation);
      });
      test('controllers should contain hiddenTexts when showAnswers is true', () {
        VocabCard card =  VocabCard(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: 'This is a %%cloze%% with percent %%signs%%.', boxNumber: 1, timeModified: 1,);
        Cloze cloze = Cloze(card: card,); // Any cloze object will do
        expect(cloze.controllersForRestore.length, 0);
        // Act
        cloze.toggleShowAnswers();
        // Assert
        for(var controller in cloze.controllers) {
          expect(controller.text, cloze.hiddenTexts[cloze.controllers.indexOf(controller)]);
        }
      });
      test('controllers should be restored when showAnswers is false', () {
        VocabCard card =  VocabCard(vocabKey: 1, languageA: 'en', wordA: 'test', languageB: 'es', wordB: 'prueba', sentenceB: 'This is a %%cloze%% with percent %%signs%%.', boxNumber: 1, timeModified: 1,);
        Cloze cloze = Cloze(card: card,); // Any cloze object will do
        expect(cloze.controllersForRestore.length, 0);
        // Act
        cloze.toggleShowAnswers();
        cloze.toggleShowAnswers();
        // Assert
        for(var controller in cloze.controllers) {
          expect(controller.text, '');
        }
      });
    });
  });
}