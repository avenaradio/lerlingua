import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:lerlingua/pages/read/epub_view.dart';
import 'package:lerlingua/pages/read/web_view.dart';
import '../../resources/event_bus.dart';
import 'library.dart';

class Read extends StatefulWidget {
  const Read({super.key});

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> {
  EpubController epubController = EpubController();
  bool _showLibrary = false;

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
              flex: 65,
              child: _showLibrary ? Library() : EpubView(epubController: epubController),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: 'Previous page',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => epubController.prev(),
                ),
                IconButton(
                  tooltip: 'Next page',
                  icon: const Icon(Icons.arrow_forward),
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
              ],
            ),
            Container(height: 2, color: Colors.black54), // TODO Set color
            Expanded(
              flex: 40, // TODO make this dynamic
              child: WebView(),
            ),

          ]
      ),

    );
  }
}
