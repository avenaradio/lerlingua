import 'package:flutter/cupertino.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';

class CardsFilter {
  @visibleForTesting
  List<VocabCard> cardsList;

  CardsFilter({required this.cardsList});

  // Sort getters
  CardsFilter get sortByLanguageA {
    List<VocabCard> sortedCards = List.from(cardsList);
    sortedCards.sort((a, b) => a.languageA.compareTo(b.languageA));
    return CardsFilter(cardsList: sortedCards);
  }

  CardsFilter get sortByWordA {
    List<VocabCard> sortedCards = List.from(cardsList);
    sortedCards.sort((a, b) => a.wordA.compareTo(b.wordA));
    return CardsFilter(cardsList: sortedCards);
  }

  CardsFilter get sortByLanguageB {
    List<VocabCard> sortedCards = List.from(cardsList);
    sortedCards.sort((a, b) => a.languageB.compareTo(b.languageB));
    return CardsFilter(cardsList: sortedCards);
  }

  CardsFilter get sortByWordB {
    List<VocabCard> sortedCards = List.from(cardsList);
    sortedCards.sort((a, b) => a.wordB.compareTo(b.wordB));
    return CardsFilter(cardsList: sortedCards);
  }

  CardsFilter get sortByBoxNumber {
    List<VocabCard> sortedCards = List.from(cardsList);
    sortedCards.sort((a, b) => a.boxNumber.compareTo(b.boxNumber));
    return CardsFilter(cardsList: sortedCards);
  }

  CardsFilter get sortByTimeModified {
    List<VocabCard> sortedCards = List.from(cardsList);
    sortedCards.sort((a, b) => a.timeModified.compareTo(b.timeModified));
    return CardsFilter(cardsList: sortedCards);
  }

  // Invert order
  CardsFilter get invertedOrder {
    List<VocabCard> invertedCards = List.from(cardsList.reversed);
    return CardsFilter(cardsList: invertedCards);
  }

  // Filter getters
  CardsFilter filterByLanguageA(String languageA) {
    List<VocabCard> filteredCards = cardsList.where((card) => card.languageA == languageA).toList();
    return CardsFilter(cardsList: filteredCards);
  }

  CardsFilter filterByWordA(String wordA) {
    List<VocabCard> filteredCards = cardsList.where((card) => card.wordA == wordA).toList();
    return CardsFilter(cardsList: filteredCards);
  }

  CardsFilter filterByLanguageB(String languageB) {
    List<VocabCard> filteredCards = cardsList.where((card) => card.languageB == languageB).toList();
    return CardsFilter(cardsList: filteredCards);
  }

  CardsFilter filterByWordB(String wordB) {
    List<VocabCard> filteredCards = cardsList.where((card) => card.wordB == wordB).toList();
    return CardsFilter(cardsList: filteredCards);
  }

  CardsFilter filterByBoxNumber(int boxNumber) {
    List<VocabCard> filteredCards = cardsList.where((card) => card.boxNumber == boxNumber).toList();
    return CardsFilter(cardsList: filteredCards);
  }

  CardsFilter filterByTimeModified(int timeModified) {
    List<VocabCard> filteredCards = cardsList.where((card) => card.timeModified == timeModified).toList();
    return CardsFilter(cardsList: filteredCards);
  }

  List<VocabCard> get cards {
    // Return a copy of cardsList to avoid modifying the original list
    List<VocabCard> filteredCards = [];
    filteredCards.addAll(cardsList);
    return filteredCards;
  }
}