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
  Size parentWidgetSize = Size.zero;
  bool isLoading = true;

  Future<Size> getWidgetSizeAfterBuild(BuildContext context) {
    final completer = Completer<Size>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size;
      parentWidgetSize = size ?? parentWidgetSize;
      completer.complete(size);
    });
    return completer.future;
  }

  _loadBook() async {
    // Render page
    if (mounted) {
      await getWidgetSizeAfterBuild(context);
      if (mounted) {
        widget.epubViewerController.loadBook(context: context, parentWidgetSize: parentWidgetSize, book: widget.book, onRendered: () {setState(() {});});
        isLoading = false;
        setState(() {});
      }
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
      child: isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Wrap(
          children: widget.epubViewerController.pageWidgets,
        ),
      ),
    );
  }
}
