import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';
import 'package:lerlingua/resources/database/mirror/cards_filter.dart';

void main() {
  group('CardsFilter', () {
    late List<VocabCard> cards;
    late CardsFilter cardsFilter;

    setUp(() {
      cards = [
        VocabCard(
          vocabKey: 1,
          languageA: 'English',
          wordA: 'Hello',
          languageB: 'Spanish',
          wordB: 'Hola',
          boxNumber: 1,
          timeModified: 5,
        ),
        VocabCard(
          vocabKey: 2,
          languageA: 'English',
          wordA: 'Goodbye',
          languageB: 'Spanish',
          wordB: 'Adiós',
          boxNumber: 2,
          timeModified: 15,
        ),
        VocabCard(
          vocabKey: 3,
          languageA: 'French',
          wordA: 'Bonjour',
          languageB: 'English',
          wordB: 'Hello',
          boxNumber: 1,
          timeModified: 2,
        ),
      ];
      cardsFilter = CardsFilter(cardsList: cards);
    });

    test('sorts by languageA', () {
      final sortedCards = cardsFilter.sortByLanguageA.cards;
      expect(sortedCards[0].languageA, 'English');
      expect(sortedCards[1].languageA, 'English');
      expect(sortedCards[2].languageA, 'French');
    });

    test('sorts by wordA', () {
      final sortedCards = cardsFilter.sortByWordA.cards;
      expect(sortedCards[0].wordA, 'Bonjour');
      expect(sortedCards[1].wordA, 'Goodbye');
      expect(sortedCards[2].wordA, 'Hello');
    });

    test('sorts by languageB', () {
      final sortedCards = cardsFilter.sortByLanguageB.cards;
      expect(sortedCards[0].languageB, 'English');
      expect(sortedCards[1].languageB, 'Spanish');
      expect(sortedCards[2].languageB, 'Spanish');
    });

    test('sorts by wordB', () {
      final sortedCards = cardsFilter.sortByWordB.cards;
      expect(sortedCards[0].wordB, 'Adiós');
      expect(sortedCards[1].wordB, 'Hello');
      expect(sortedCards[2].wordB, 'Hola');
    });

    test('sorts by boxNumber', () {
      final sortedCards = cardsFilter.sortByBoxNumber.cards;
      expect(sortedCards[0].boxNumber, 1);
      expect(sortedCards[1].boxNumber, 1);
      expect(sortedCards[2].boxNumber, 2);
    });

    test('sorts by timeModified', () {
      final sortedCards = cardsFilter.sortByTimeModified.cards;
      expect(sortedCards[0].timeModified, 2);
      expect(sortedCards[1].timeModified, 5);
      expect(sortedCards[2].timeModified, 15);
    });

    test('inverts order', () {
      final invertedCards = cardsFilter.invertedOrder.cards;
      expect(invertedCards[0].vocabKey, 3);
      expect(invertedCards[1].vocabKey, 2);
      expect(invertedCards[2].vocabKey, 1);
    });

    test('filters by languageA', () {
      final filteredCards = cardsFilter.filterByLanguageA('English').cards;
      expect(filteredCards.length, 2);
      expect(filteredCards[0].wordA, 'Hello');
      expect(filteredCards[1].wordA, 'Goodbye');
    });

    test('filters by wordA', () {
      final filteredCards = cardsFilter.filterByWordA('Hello').cards;
      expect(filteredCards.length, 1);
      expect(filteredCards[0].wordA, 'Hello');
    });

    test('filters by languageB', () {
      final filteredCards = cardsFilter.filterByLanguageB('Spanish').cards;
      expect(filteredCards.length, 2);
    });

    test('filters by wordB', () {
      final filteredCards = cardsFilter.filterByWordB('Hola').cards;
      expect(filteredCards.length, 1);
      expect(filteredCards[0].wordB, 'Hola');
    });

    test('filters by boxNumber', () {
      final filteredCards = cardsFilter.filterByBoxNumber(1).cards;
      expect(filteredCards.length, 2);
    });

    test('filters by timeModified', () {
      final filteredCards = cardsFilter.filterByTimeModified(5).cards;
      expect(filteredCards.length, 1);
      expect(filteredCards[0].timeModified, 5);
    });

    test('original List should not be modified', () {
      expect(cards.length, 3);
      expect(cards[0].vocabKey, 1);
      expect(cards[1].vocabKey, 2);
      expect(cards[2].vocabKey, 3);
      final filteredCards = cardsFilter.filterByLanguageA('English').cards;
      expect(filteredCards.length, 2);
      expect(cards.hashCode, isNot(filteredCards.hashCode));
    });

    test('cards should return a different list', () {
      final cardsFilter2 = cardsFilter.filterByLanguageA('English');
      expect(cardsFilter2.cards.hashCode, isNot(cardsFilter.cardsList.hashCode));
    });
  });
}