import 'package:lerlingua/resources/database/mirror/mirror.dart';
import 'package:lerlingua/resources/database/mirror/undo.dart';

extension MirrorUndoExtension on Mirror {
  //List<Undo> undoList = []; in mirror class

  // Method to add Undo
  void addUndo({required Undo undo}) => undoList.add(undo);

  // Method to execute and remove last Undo
  void undo() {
    undoList.last.executeUndo();
    undoList.removeLast();
  }

}