import 'dart:io';

import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:flutter/material.dart';

import '../../resources/event_bus.dart';

class EpubView extends StatefulWidget {
  const EpubView({super.key, required this.title, required this.file});

  final String title;
  final File file;

  @override
  State<EpubView> createState() => _EpubViewState();
}

class _EpubViewState extends State<EpubView> {
  final epubController = EpubController();

  var textSelectionCfi = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: EpubViewer(
                  epubSource: EpubSource.fromFile(widget.file),
                  epubController: epubController,
                  displaySettings:
                  EpubDisplaySettings(flow: EpubFlow.paginated, snap: true),
                  onChaptersLoaded: (chapters) {},
                  onEpubLoaded: () async {},
                  onRelocated: (value) {},
                  onTextSelected: (epubTextSelection) {
                    // Create and fire the event
                    final event = WordSelectedEvent(epubTextSelection.selectedText);
                    eventBus.fire(event);
                  },
                ),
              ),
            ],
          )),
    );
  }
}