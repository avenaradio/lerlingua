import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

/// Word in learning language selected
class WordBSelectedEvent {
  List<String> wordsB;
  List<String> sentenceListB;
  String wordB = '';
  String sentenceB = '';
  WordBSelectedEvent({required this.wordsB, required this.sentenceListB}) {
    for (String sentenceWord in sentenceListB) {
      if (wordsB.contains(sentenceWord)) {
        sentenceB += '%%$sentenceWord%% ';
        wordB += '$sentenceWord ';
      } else {
        sentenceB += '$sentenceWord ';
      }
    }
    sentenceB = sentenceB.trim();
    wordB = wordB.trim();
  }
}

/// Word in known language selected
class WordASelectedEvent {
  String wordA;
  WordASelectedEvent(this.wordA);
}

class LearningPageSetStateEvent {}

class LearningPageNewDataEvent {}

class CurrentBookChangedEvent {
  bool showLibrary = false;
  CurrentBookChangedEvent(this.showLibrary);
}