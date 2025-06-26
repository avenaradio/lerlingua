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
        widget.epubViewerController.loadBook(context: context, parentWidgetSize: parentWidgetSize, book: widget.book, onRendered: (value) {if (mounted) setState(() {});});
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
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // SingleChildScrollView allows scroll if content is bigger
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                // IntrinsicHeight lets the Column size itself properly
                child: ChildColumn(children: widget.epubViewerController.currentPage(context)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChildColumn extends StatefulWidget {
  const ChildColumn({super.key, required this.children});
  final List<Widget> children;
  @override
  State<ChildColumn> createState() => _ChildColumnState();
}

class _ChildColumnState extends State<ChildColumn> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start, // vertical center when content fits
      crossAxisAlignment: CrossAxisAlignment.start, // horizontal center
      children: widget.children.isEmpty ? [] : widget.children,
    );
  }
}
