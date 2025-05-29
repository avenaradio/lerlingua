import 'dart:io';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:flutter/material.dart';
import '../../resources/event_bus.dart';
import '../../resources/settings.dart';

class EpubView extends StatefulWidget {
  const EpubView({super.key, required this.epubController});
  final EpubController epubController;

  @override
  State<EpubView> createState() => _EpubViewState();
}

class _EpubViewState extends State<EpubView> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
          children: [
            Flexible(
              child: EpubViewer(
                epubSource: Settings().currentBook?.path != null ? EpubSource.fromFile(File(Settings().currentBook!.path)) : EpubSource.fromAsset('assets/books/lerlingua_en.epub'),
                epubController: widget.epubController,
                displaySettings: EpubDisplaySettings(
                  flow: EpubFlow.paginated,
                  snap: true,
                  //theme: EpubTheme.dark(),
                ),
                initialCfi: Settings().currentBook?.readingLocation, // Start location
                onChaptersLoaded: (chapters) {},
                onEpubLoaded: () async {},
                onRelocated: (value) {
                  Settings().currentBook?.readingLocation = value.endCfi;
                  if (Settings().currentBook != null) {
                    Settings().addOrUpdateBook(Settings().currentBook!);
                  }
                }, //Call back when epub page changes
                selectionContextMenu: ContextMenu(
                  settings: ContextMenuSettings(
                    hideDefaultSystemContextMenuItems: true,
                  ),
                  menuItems: [
                    // Add a custom menu itmes here
                  ],
                ),
                onTextSelected: (epubTextSelection) async {
                  if (Settings().currentBook?.languageB == '') {
                    await showDialog<String>(
                      context: context,
                      // Text field to set book language
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Set language'),
                        content: TextField(
                          controller: TextEditingController(text: Settings().currentBook?.languageB ?? ''),
                          onChanged: (value) {
                            Settings().currentBook?.languageB = value;
                            Settings().addOrUpdateBook(Settings().currentBook!);
                          },
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                          ),
                          TextButton(
                            child: const Text('Save'),
                            onPressed: () => Navigator.pop(context, 'Save'),
                          ),
                        ],
                      ),
                    );
                  }
                  // Create and fire the event
                  final event = WordBSelectedEvent(
                    epubTextSelection.selectedText,
                  );
                  eventBus.fire(event);
                },
              ),
            ),
          ],
        ),
    );
  }
}
