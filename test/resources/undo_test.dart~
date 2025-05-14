import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/undo.dart';

Future main() async {
  test('undo', () async {
    Undo undo = Undo(description: 'test');
    List<String> strings = [];
    undo.addFunction(() => strings.add('test1'));
    undo.addFunction(() => strings.add('test2'));
    undo.addFunction(() => strings.add('test3'));
    undo.executeUndo();
    expect(strings, ['test3', 'test2', 'test1']);
  });
  test('empty undo', () async {
    Undo undo = Undo(description: 'test');
    undo.executeUndo();
  });
}