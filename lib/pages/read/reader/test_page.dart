import 'package:epub_pro/epub_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lerlingua/resources/file_utils/epub_viewer.dart';

import '../../../resources/event_bus.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  EpubBook? book;
  List<Widget> items = [];

  _loadBook() async {
    var data = await rootBundle.load('assets/books/the_little_prince_public_domain.epub').then((value) => value.buffer.asUint8List());
    book = await EpubReader.readBook(data);
    if (book != null) {
      items = EpubViewer(epubBook: book!, readingPosition: '0/1/0').elements();
      setState(() {});
      //print(items.length);
    }
  }
  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items,
        ),
      ),
    );
  }
}
