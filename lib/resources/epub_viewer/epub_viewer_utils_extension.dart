import 'dart:async';
import 'package:flutter/material.dart';
import 'epub_viewer_controller.dart';

extension EpubViewerUtilsExtension on EpubViewerController {
  Future<double> measureWidgetHeight(BuildContext context, Widget widget) async {
    final GlobalKey key = GlobalKey();
    final completer = Completer<double>();

    final offstage = Offstage(
      child: Material(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Add dummy content before
              const SizedBox(height: 1000),
              _MeasurableWidget(
                key: key,
                onBuild: () {
                  final RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
                  final height = box.size.height;
                  completer.complete(height);
                },
                child: widget,
              ),
              // Add dummy content after
              const SizedBox(height: 1000),
            ],
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(builder: (_) => offstage);
    overlay.insert(entry);

    final height = await completer.future;

    entry.remove();

    return height;
  }
}

class _MeasurableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onBuild;

  const _MeasurableWidget({
    required Key key,
    required this.child,
    required this.onBuild,
  }) : super(key: key);

  @override
  State<_MeasurableWidget> createState() => _MeasurableWidgetState();
}

class _MeasurableWidgetState extends State<_MeasurableWidget> {
  @override
  void initState() {
    super.initState();
    // Schedule after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onBuild();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material( // Optional but helps in ensuring layout works properly
      child: widget.child,
    );
  }
}
