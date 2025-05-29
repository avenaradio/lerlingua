import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

// Word to learn
class WordBSelectedEvent {
  String wordB;
  WordBSelectedEvent(this.wordB);
}

// Known word
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