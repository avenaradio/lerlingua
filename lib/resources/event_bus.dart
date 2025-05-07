import 'package:event_bus/event_bus.dart';
import 'package:lerlingua/resources/settings.dart';

EventBus eventBus = EventBus();

class WordSelectedEvent {
  String wordA;

  WordSelectedEvent(this.wordA){
    Settings().wordA = wordA;
  }
}