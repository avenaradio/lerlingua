import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lerlingua/pages/read/epub_view.dart';
import 'package:lerlingua/pages/read/web_view.dart';

import '../../resources/file_handler.dart';

class Read extends StatefulWidget {
  const Read({super.key});

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> {
  File? file;

  loadFile() async {
    file = await FileHandler.loadEpubFile();
    setState(() {});
  }

  @override
  void initState() {
    loadFile();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children: [
            Expanded(
              flex: 50,
              child: file != null ? EpubView(title: 'dummy title', file: file!) : const Placeholder(),
            ),
            Expanded(
              flex: 40, // TODO make this dynamic
              child: WebView(),
            ),

          ]
      ),

    );
  }
}
