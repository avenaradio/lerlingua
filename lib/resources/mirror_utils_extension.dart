import 'package:lerlingua/resources/mirror.dart';
import 'package:lerlingua/resources/mirror_undo_extension.dart';
import 'package:lerlingua/resources/undo.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

import '../enums/move_direction.dart';
import 'entries_filter.dart';

extension MirrorGetExtension on Mirror {
  //Filter
  EntriesFilter get filterEntries => EntriesFilter(entriesList: dbMirror);

  VocabEntry oldestLearnedBoxEntry({required int boxNumber}) => filterEntries.filterByBoxNumber(boxNumber).sortByTimeLearned.entries.first;

  int boxSize({required int boxNumber}) => filterEntries.filterByBoxNumber(boxNumber).entries.length;

  // Add stack from box null to box number
  void addStack({required int stackSize}) {
    int boxSize = filterEntries.filterByBoxNumber(0).entries.length;
    if (boxSize == 0) return;
    if (stackSize > boxSize) stackSize = boxSize;
    Undo undo = Undo(description: 'Move $stackSize Cards back.');
    List<VocabEntry> stack = filterEntries.filterByBoxNumber(0).sortByTimeLearned.invertedOrder.entries.take(stackSize).toList();
    for(VocabEntry entry in stack) {
      VocabEntry entryCopy = entry.clone();
      undo.addFunction(() => writeEntry(entry: entryCopy));
      move(entry: entry, direction: Direction.next, addNewUndo: false);
    }
    addUndo(undo: undo);
  }

  // Move in direction enum Directions next / previous / first
  void move({required VocabEntry entry, required Direction direction, required bool addNewUndo}) {
    if(entry.vocabKey == -2) return;
    Undo undo = Undo(description: 'Undo: ${entry.wordA} - ${entry.wordB}');
    if(addNewUndo == true) {
      VocabEntry entryCopy = entry.clone();
      undo.addFunction(() => writeEntry(entry: entryCopy));
      addUndo(undo: undo);
    }
    int timeNow = DateTime.now().millisecondsSinceEpoch;
    entry.timeModified = timeNow;
    entry.timeLearned = timeNow;
    switch (direction) {
      case Direction.next:
        entry.boxNumber++; // Move to next box
        if(entry.boxNumber > 5) entry.boxNumber = 5;
        writeEntry(entry: entry);
        break;
      case Direction.previous:
        entry.boxNumber--; // Move to previous box
        if(entry.boxNumber < 1) entry.boxNumber = 1;
        writeEntry(entry: entry);
        break;
      case Direction.first:
        entry.boxNumber = 1; // Move to first box
        writeEntry(entry: entry);
        break;
    }
  }

}