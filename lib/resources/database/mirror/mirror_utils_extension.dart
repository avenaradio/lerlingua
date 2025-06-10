import 'package:lerlingua/resources/database/mirror/mirror.dart';
import 'package:lerlingua/resources/database/mirror/mirror_undo_extension.dart';
import 'package:lerlingua/resources/database/mirror/undo.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';

import '../../../general/move_direction.dart';
import 'cards_filter.dart';

extension MirrorGetExtension on Mirror {
  //Filter
  CardsFilter get filterCards => CardsFilter(cardsList: dbMirror);

  VocabCard oldestLearnedBoxCard({required int boxNumber}) => filterCards.filterByBoxNumber(boxNumber).sortByTimeModified.cards.first;

  int boxSize({required int boxNumber}) => filterCards.filterByBoxNumber(boxNumber).cards.length;

  // Add stack from box null to box number
  void addStack({required int stackSize}) {
    int boxSize = filterCards.filterByBoxNumber(0).cards.length;
    if (boxSize == 0) return;
    if (stackSize > boxSize) stackSize = boxSize;
    Undo undo = Undo(description: 'Move $stackSize Cards back.');
    List<VocabCard> stack = filterCards.filterByBoxNumber(0).sortByTimeModified.invertedOrder.cards.take(stackSize).toList();
    for(VocabCard card in stack) {
      VocabCard cardCopy = card.clone();
      undo.addFunction(() => writeCard(card: cardCopy, addNewUndo: false));
      move(card: card, direction: Direction.next, addNewUndo: false);
    }
    addUndo(undo: undo);
  }

  // Move in direction enum Directions next / previous / first
  void move({required VocabCard card, required Direction direction, required bool addNewUndo}) {
    if(card.vocabKey == -2) return;
    Undo undo = Undo(description: 'Undo: ${card.wordA} - ${card.wordB}');
    if(addNewUndo == true) {
      VocabCard cardCopy = card.clone();
      undo.addFunction(() => writeCard(card: cardCopy, addNewUndo: false));
      addUndo(undo: undo);
    }
    int timeNow = DateTime.now().millisecondsSinceEpoch;
    card.timeModified = timeNow;
    switch (direction) {
      case Direction.next:
        card.boxNumber++; // Move to next box
        if(card.boxNumber > 5) card.boxNumber = 5;
        writeCard(card: card, addNewUndo: false);
        break;
      case Direction.previous:
        card.boxNumber--; // Move to previous box
        if(card.boxNumber < 1) card.boxNumber = 1;
        writeCard(card: card, addNewUndo: false);
        break;
      case Direction.first:
        card.boxNumber = 1; // Move to first box
        writeCard(card: card, addNewUndo: false);
        break;
    }
  }

}