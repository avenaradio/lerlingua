import 'package:event_bus/event_bus.dart';
import 'package:lerlingua/resources/settings.dart';

EventBus eventBus = EventBus();

class WordASelectedEvent {
  String wordA;

  WordASelectedEvent(this.wordA){
    Settings().wordA = wordA;
  }
}

class WordBSelectedEvent {
  String wordB;

  WordBSelectedEvent(this.wordB);
}