import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class WordASelectedEvent {
  String wordA;

  WordASelectedEvent(this.wordA);
}

class WordBSelectedEvent {
  String wordB;

  WordBSelectedEvent(this.wordB);
}

class LearningPageSetStateEvent {}

class LearningPageNewDataEvent {}