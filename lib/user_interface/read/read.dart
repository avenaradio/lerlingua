import 'package:flutter/material.dart';
import 'package:lerlingua/resources/epub_viewer/epub_viewer_widget.dart';
import 'package:lerlingua/user_interface/read/web_view.dart';
import '../../resources/epub_viewer/epub_viewer_controller.dart';
import '../../resources/event_bus.dart';
import '../../resources/settings/settings.dart';
import 'edit_language_page.dart';
import 'library.dart';

class Read extends StatefulWidget {
  const Read({super.key});

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> {
  EpubViewerController epubViewerController = EpubViewerController();
  bool _showLibrary = false;
  double _dragStartPosition = 0;

  final double _libraryFlex = 65; // Initial flex for Library/TestPage
  final double _webViewFlex = 40;  // Initial flex for WebView
  // double _dragOffset = 0.0; // Track the drag offset

  String _readingProgress = '0|0';

  void _textSelected() async {
    if (Settings().currentBook?.languageB == '') {
      await editLanguageDialog(context);
    }
  }

  @override
  void initState() {
    eventBus.on<CurrentBookChangedEvent>().listen((event) { // Listen for book changes
      _showLibrary = event.showLibrary;
      setState(() {});
    });
    epubViewerController.onRendered((value) { // Listen for page changes
      _readingProgress = value;
      setState(() {});
    });
    epubViewerController.onTextSelected(_textSelected); // Listen for text selection
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children: [
            Expanded(
              flex: _libraryFlex.toInt(),
              child: _showLibrary ? Library() : GestureDetector(
                onHorizontalDragStart: (details) {
                  _dragStartPosition = details.localPosition.dx;
                },
                onHorizontalDragEnd: (details) {
                  // On swipe left
                  if (details.localPosition.dx - _dragStartPosition < 0) {
                    epubViewerController.nextPage();
                  }
                  // On swipe right
                  else if (details.localPosition.dx - _dragStartPosition > 0) {
                    epubViewerController.previousPage();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: EpubViewerWidget(epubViewerController: epubViewerController, book: Settings().currentBook,),
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: 'Previous page',
                  icon: const Icon(Icons.navigate_before_rounded),
                  onPressed: _showLibrary ? null : () {
                    epubViewerController.previousPage();
                  },
                  onLongPress: _showLibrary ? null : () {
                    epubViewerController.previousChapter(goToFirstPage: true);
                  },
                ),
                IconButton(
                  key: const Key('nextPageButton'),
                  tooltip: 'Next page',
                  icon: const Icon(Icons.navigate_next_rounded),
                  onPressed: _showLibrary ? null : () {
                    epubViewerController.nextPage();
                  },
                  onLongPress: _showLibrary ? null : () {
                    epubViewerController.nextChapter();
                  },
                ),
                IconButton(
                  tooltip: _showLibrary ? 'Book' : 'Library',
                  icon: const Icon(Icons.book_rounded),
                  onPressed: () {
                    _showLibrary = !_showLibrary;
                    setState(() {});
                  },
                ),
                (_showLibrary || Settings().currentBook == null) ? Container() : IconButton(
                  tooltip: 'Book language: ${Settings().currentBook?.languageB}',
                  icon: const Icon(Icons.translate_rounded),
                  onPressed: () async {
                    await editLanguageDialog(context);
                  },
                ),
                //epubViewerController.isLoading ? SizedBox(height: 16, width: 16, child: const CircularProgressIndicator()) : Container(),
                Spacer(),
                Text(_readingProgress),
                IconButton(
                  tooltip: 'Previous page',
                  icon: const Icon(Icons.navigate_before_rounded),
                  onPressed: _showLibrary ? null : () {
                    epubViewerController.previousPage();
                  },
                  onLongPress: _showLibrary ? null : () {
                    epubViewerController.previousChapter(goToFirstPage: true);
                  },
                ),
                IconButton(
                  tooltip: 'Next page',
                  icon: const Icon(Icons.navigate_next_rounded),
                  onPressed: _showLibrary ? null : () {
                    epubViewerController.nextPage();
                  },
                  onLongPress: _showLibrary ? null : () {
                    epubViewerController.nextChapter();
                  },
                ),
              ],
            ),
            /*
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _dragOffset += details.delta.dy / 6;
                  // Adjust the flex values based on the drag offset
                  _libraryFlex = 60 + _dragOffset;
                  _webViewFlex = 40 - _dragOffset;
                  if (_libraryFlex > 80) {
                    _libraryFlex = 80;
                  } else if (_libraryFlex < 40) {
                    _libraryFlex = 40;
                  }
                  if (_webViewFlex < 20) {
                    _webViewFlex = 20;
                  } else if (_webViewFlex > 60) {
                    _webViewFlex = 60;
                  }
                });
              },
              child: Container(
                height: 10, // Height of the draggable spacer
                width: double.infinity,
                color: Theme.of(context).colorScheme.inversePrimary, // Color of the spacer
                child: Center(
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.primary,
                      ),
                  ),
                ), // Optional: Add an icon
              ),
            ),
             */
            Container(
              height: 2,
              width: double.infinity,
              color: Theme.of(context).colorScheme.primary,
            ),
            Expanded(
              flex: _webViewFlex.toInt(),
              child: WebView(),
            ),

          ]
      ),

    );
  }
}
