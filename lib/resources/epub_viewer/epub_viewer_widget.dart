import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lerlingua/resources/epub_viewer/epub_viewer_controller.dart';

import '../file_utils/book.dart';

class EpubViewerWidget extends StatefulWidget {
  final EpubViewerController epubViewerController;
  final Book? book;

  const EpubViewerWidget({super.key, required this.epubViewerController, this.book});

  @override
  State<EpubViewerWidget> createState() => _EpubViewerWidgetState();
}

class _EpubViewerWidgetState extends State<EpubViewerWidget> {
  double parentWidgetHeight = 0;
  bool isLoading = true;

  Future<double> getWidgetHeightAfterBuild(BuildContext context) {
    final completer = Completer<double>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size;
      final height = size?.height;
      parentWidgetHeight = height ?? parentWidgetHeight;
      completer.complete(height);
    });
    return completer.future;
  }

  _loadBook() async {
    // Render page
    if (mounted) {
      await getWidgetHeightAfterBuild(context);
      if (mounted) {
        widget.epubViewerController.loadBook(context: context, parentWidgetHeight: parentWidgetHeight, book: widget.book, onRendered: () {setState(() {});});
        isLoading = false;
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getWidgetHeightAfterBuild(context);
    _loadBook();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Padding(
          padding: EpubViewerController.padding,
          child: Wrap(
            children: widget.epubViewerController.pageWidgets,
          ),
        ),
      ),
    );
  }
}
