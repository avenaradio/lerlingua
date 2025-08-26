import 'package:flutter/material.dart';
import 'package:lerlingua/resources/epub_viewer/sentence_with_selection.dart';
import 'package:share_handler/share_handler.dart';

import 'event_bus.dart';

class ShareHandler {
  ShareHandler._internal();
  static final ShareHandler _instance = ShareHandler._internal();
  factory ShareHandler() => _instance;
  SharedMedia? media;

  Future<void> initPlatformState(BuildContext context) async {
    final handler = ShareHandlerPlatform.instance;
    media = await handler.getInitialSharedMedia();
    handler.sharedMediaStream.listen((SharedMedia media) {
      if (media.content == null) return;
      if (media.content!.isNotEmpty) {
        SentenceWithSelection sentenceWithSelection = SentenceWithSelection(words: [media.content!], selected: [0]);
        final event = WordBSelectedEvent(wordB: sentenceWithSelection.selectedWordsJoined, sentenceB: sentenceWithSelection.sentenceWrapped);
        eventBus.fire(event);
      }
    });
  }
}