import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/epub_viewer/sentence_with_selection.dart';

void main() {
  test('get selected words list', () {
    List<String> words = ['..Hello.', 'World!', 'How', 'are', 'you?', '+'];
    List<int> selection = [4, 5, 0];
    SentenceWithSelection sentence = SentenceWithSelection(words: words, selected: selection);
    String selectedWords = sentence.selectedWordsJoined;
    expect(selectedWords, ['Hello', 'you', '+'].join(' '));
  });
  test('sentenceWithPercentWrap', () {
    List<String> words = ['..Hello.', 'World!', 'How', 'are', 'you?', '+'];
    List<int> selection = [4, 5, 0];
    SentenceWithSelection sentence = SentenceWithSelection(words: words, selected: selection);
    String sentenceWrapped = sentence.sentenceWrapped;
    String w = sentence.wrapper;
    expect(sentenceWrapped, '..${w}Hello$w. World! How are ${w}you$w? $w+$w');
  });
}