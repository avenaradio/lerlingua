/* This is the old wev view based reader, can be removed in the future
import 'dart:io';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:flutter/material.dart';
import '../../resources/settings.dart';
import 'edit_language_page.dart';

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
                  spread: EpubSpread.none,
                  snap: true,
                  useSnapAnimationAndroid: false,
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
                    await editLanguageDialog(context);
                  }

                },
              ),
            ),
          ],
        ),
    );
  }
}
 */
