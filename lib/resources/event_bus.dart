import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class WordSelectedEvent {
  String wordA;

  WordSelectedEvent(this.wordA);
}