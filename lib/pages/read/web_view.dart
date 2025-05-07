import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebView extends StatefulWidget {
  const WebView({super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
    initialScale: 50,
  );

  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: <Widget>[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                  PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'back',
                        child: Row(children: [Icon(Icons.arrow_back), SizedBox(width: 10), Text("Back")]),
                      ),
                      PopupMenuItem<String>(
                        value: 'forward',
                        child: Row(children: [Icon(Icons.arrow_forward), SizedBox(width: 10), Text("Forward")]),
                      ),
                      PopupMenuItem<String>(
                        value: 'reload',
                        child: Row(children: [Icon(Icons.refresh), SizedBox(width: 10), Text("Reload")]),
                      ),
                    ];
                  },
                    onSelected: (String? value) {
                      if (value == 'back') {
                        webViewController?.goBack();
                      } else if (value == 'forward') {
                        webViewController?.goForward();
                      } else if (value == 'reload') {
                        webViewController?.reload();
                      }
                    },
                  icon: Icon(Icons.more_vert), // Menu button icon
                ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: urlController,
                        keyboardType: TextInputType.url,
                        onSubmitted: (value) {
                          var url = WebUri(value);
                          if (url.scheme.isEmpty) {
                            url = WebUri("https://www.linguee.de/deutsch-portugiesisch/search?query=$value");
                          }
                          webViewController?.loadUrl(urlRequest: URLRequest(url: url));
                        },
                        onTap: () {
                          urlController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: urlController.text.length,
                          );
                        },
                      )
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(url: WebUri("https://www.linguee.de/deutsch-portugiesisch/search?query=test")),
                      initialSettings: settings,
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      onLoadStart: (controller, url) {
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      onPermissionRequest: (controller, request) async {
                        return PermissionResponse(
                            resources: request.resources,
                            action: PermissionResponseAction.GRANT);
                      },

                      onLoadStop: (controller, url) async {
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      onReceivedError: (controller, request, error) {
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                        }
                        setState(() {
                          this.progress = progress / 100;
                          urlController.text = url;
                        });
                      },
                      onUpdateVisitedHistory: (controller, url, androidIsReload) {
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        if (kDebugMode) {
                          print(consoleMessage);
                        }
                      },
                    ),
                    progress < 1.0
                        ? LinearProgressIndicator(value: progress)
                        : Container(),
                  ],
                ),
              ),
            ])));
  }
}