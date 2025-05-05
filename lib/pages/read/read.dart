import 'package:flutter/material.dart';
import 'package:lerlingua/pages/read/webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Read extends StatefulWidget {
  const Read({super.key});

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewExample(),
    );
  }
}
