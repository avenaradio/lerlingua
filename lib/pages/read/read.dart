import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:lerlingua/pages/read/reader/test_page.dart';
import 'package:lerlingua/pages/read/web_view.dart';
import '../../resources/event_bus.dart';
import '../../resources/settings.dart';
import 'edit_language_page.dart';
import 'library.dart';

class Read extends StatefulWidget {
  const Read({super.key});

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> {
  EpubController epubController = EpubController();
  bool _showLibrary = false;
  double _libraryFlex = 65; // Initial flex for Library/TestPage
  double _webViewFlex = 40;  // Initial flex for WebView
  double _dragOffset = 0.0; // Track the drag offset

  @override
  void initState() {
    eventBus.on<CurrentBookChangedEvent>().listen((event) {
      _showLibrary = event.showLibrary;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children: [
            Expanded(
              flex: _libraryFlex.toInt(),
              child: _showLibrary ? Library() : TestPage(),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: 'Previous page',
                  icon: const Icon(Icons.navigate_before_rounded),
                  onPressed: () => epubController.prev(),
                ),
                IconButton(
                  tooltip: 'Next page',
                  icon: const Icon(Icons.navigate_next_rounded),
                  onPressed: () => epubController.next(),
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
                  icon: const Icon(Icons.language_rounded),
                  onPressed: () async {
                    await editLanguageDialog(context);
                  },
                ),
                Spacer(),
                IconButton(
                  tooltip: 'Previous page',
                  icon: const Icon(Icons.navigate_before_rounded),
                  onPressed: () => epubController.prev(),
                ),
                IconButton(
                  tooltip: 'Next page',
                  icon: const Icon(Icons.navigate_next_rounded),
                  onPressed: () => epubController.next(),
                ),
              ],
            ),
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
            Expanded(
              flex: _webViewFlex.toInt(), // TODO make this dynamic
              child: WebView(),
            ),

          ]
      ),

    );
  }
}
