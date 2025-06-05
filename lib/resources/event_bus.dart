import 'package:event_bus/event_bus.dart';
EventBus eventBus = EventBus();

/// Word in learning language selected
class WordBSelectedEvent {
  String wordB;
  String sentenceB;
  WordBSelectedEvent({required this.wordB, required this.sentenceB}) {
    print('eventBus: $wordB');
    print('eventBus: $sentenceB');
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