import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/general/move_direction.dart';
import 'package:lerlingua/resources/database/mirror/mirror.dart';
import 'package:lerlingua/resources/database/mirror/mirror_utils_extension.dart';
import 'package:lerlingua/resources/database/mirror/mirror_undo_extension.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';

void main () {
  test('time now propertys', () async {
    int now1 = DateTime.now().millisecondsSinceEpoch;

    await Future.delayed(const Duration(milliseconds: 20));
    int now2 = DateTime.now().millisecondsSinceEpoch;

    expect(now2, greaterThan(now1));
  });
  group('Mirror utils extension', () {
    test('get filtered cards from DatabaseMirror', () {
      VocabCard card = VocabCard(
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
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 1;
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 3;
      card.boxNumber = 2;
      Mirror().writeCard(card: card, addNewUndo: false);
      // Assert
      expect(Mirror().filterCards.filterByBoxNumber(1).sortByTimeModified.cards.length, 2);
    });
    test('get oldest card from DatabaseMirror', () {
      VocabCard card = VocabCard(
          vocabKey: 2,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeModified: 1);
      Mirror().dbMirror.clear();
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 1;
      card.timeModified = 50;
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 3;
      card.timeModified = 100;
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 4;
      card.boxNumber = 0;
      card.timeModified = 0;
      Mirror().writeCard(card: card, addNewUndo: false);
      // Assert
      expect(Mirror().oldestLearnedBoxCard(boxNumber: 1).timeModified, 1);
    });
    test('get amount of cards in a box', () {
      VocabCard card = VocabCard(
          vocabKey: 2,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeModified: 1);
      Mirror().dbMirror.clear();
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 1;
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 3;
      card.boxNumber = 2;
      Mirror().writeCard(card: card, addNewUndo: false);
      // Assert
      expect(Mirror().boxSize(boxNumber: 1), 2);
      expect(Mirror().boxSize(boxNumber: 2), 1);
    });
    test('Add stack to box', () {
      VocabCard card = VocabCard(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 0,
          timeModified: 1);
      Mirror().dbMirror.clear();
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 2;
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 3;
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 4;
      card.boxNumber = 2;
      Mirror().writeCard(card: card, addNewUndo: false);
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
      expect(Mirror().readCard(vocabKey: 1)?.timeModified, 1);
      expect(Mirror().readCard(vocabKey: 2)?.timeModified, 1);
    });
    test('move card to next', () {
      VocabCard card = VocabCard(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeModified: 1);
      Mirror().dbMirror.clear();
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 2;
      card.timeModified = 2;
      card.boxNumber = 5;
      Mirror().writeCard(card: card, addNewUndo: false);
      // Act
      card = Mirror().oldestLearnedBoxCard(boxNumber: 1);
      Mirror().move(card: card, direction: Direction.next, addNewUndo: true);
      card = Mirror().oldestLearnedBoxCard(boxNumber: 5);
      Mirror().move(card: card, direction: Direction.next, addNewUndo: true);
      // Assert
      // Time is updating
      expect(Mirror().readCard(vocabKey: 2)?.timeModified, greaterThan(1747307675463));
      expect(Mirror().filterCards.filterByBoxNumber(2).cards.length, 1);
      expect(Mirror().filterCards.filterByBoxNumber(1).cards.length, 0);
      expect(Mirror().filterCards.filterByBoxNumber(5).cards.length, 1);
      // Test Undo
      Mirror().undo();
      expect(Mirror().readCard(vocabKey: 2)?.timeModified, 2);
      expect(Mirror().readCard(vocabKey: 1)?.timeModified, greaterThan(1747307675463));
      expect(Mirror().filterCards.filterByBoxNumber(2).cards.length, 1);
      expect(Mirror().filterCards.filterByBoxNumber(1).cards.length, 0);
      expect(Mirror().filterCards.filterByBoxNumber(5).cards.length, 1);
    });
    test('move card to previous', () {
      VocabCard card = VocabCard(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeModified: 1);
      Mirror().dbMirror.clear();
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 2;
      card.timeModified = 2;
      card.boxNumber = 5;
      Mirror().writeCard(card: card, addNewUndo: false);
      // Act
      card = Mirror().oldestLearnedBoxCard(boxNumber: 1);
      Mirror().move(card: card, direction: Direction.previous, addNewUndo: true);
      card = Mirror().oldestLearnedBoxCard(boxNumber: 5);
      Mirror().move(card: card, direction: Direction.previous, addNewUndo: true);
      // Assert
      expect(Mirror().filterCards.filterByBoxNumber(0).cards.length, 0);
      expect(Mirror().filterCards.filterByBoxNumber(1).cards.length, 1);
      expect(Mirror().filterCards.filterByBoxNumber(4).cards.length, 1);
    });
    test('move card to next', () {
      VocabCard card = VocabCard(
          vocabKey: 1,
          languageA: 'en',
          wordA: 'test',
          languageB: 'es',
          wordB: 'prueba',
          boxNumber: 1,
          timeModified: 1);
      Mirror().dbMirror.clear();
      Mirror().writeCard(card: card, addNewUndo: false);
      card.vocabKey = 2;
      card.timeModified = 2;
      card.boxNumber = 5;
      Mirror().writeCard(card: card, addNewUndo: false);
      // Act
      card = Mirror().oldestLearnedBoxCard(boxNumber: 1);
      Mirror().move(card: card, direction: Direction.first, addNewUndo: true);
      card = Mirror().oldestLearnedBoxCard(boxNumber: 5);
      Mirror().move(card: card, direction: Direction.first, addNewUndo: true);
      // Assert
      expect(Mirror().filterCards.filterByBoxNumber(2).cards.length, 0);
      expect(Mirror().filterCards.filterByBoxNumber(1).cards.length, 2);
      expect(Mirror().filterCards.filterByBoxNumber(5).cards.length, 0);
    });
  });
}