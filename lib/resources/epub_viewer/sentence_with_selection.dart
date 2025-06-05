import 'package:lerlingua/general/string_extension.dart';

class SentenceWithSelection {
  final String wrapper = '%%';
  final List<String> words;
  final List<int> selected; // Indexes of selected words in sentenceWords list>
  SentenceWithSelection({required this.words, required this.selected});

  /// Returns selected words non alphanumeric trimmed
  /// - Tested
  String get selectedWordsJoined {
    List<String> selectedWords = [];
    for (int i = 0; i < words.length; i++) {
      if (selected.contains(i)) {
        selectedWords.add(words[i].trimNonAlphanumeric());
      }
    }
    return selectedWords.join(' ');
  }

  /// Returns sentence with percent wrap
  /// - Tested
  String get sentenceWrapped {
    List<String> sentence = [];
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      String trimmedWord = word.trimNonAlphanumeric();
      if (selected.contains(i)) {
        word = word.replaceAll(trimmedWord, '$wrapper$trimmedWord$wrapper'); // Wrapping selected words
      }
      sentence.add(word);
    }
    return sentence.join(' ');
  }
}