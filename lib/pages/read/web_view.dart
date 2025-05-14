import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../resources/event_bus.dart';
import '../../resources/mirror.dart';
import '../../resources/vocab_entry.dart';

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
  );
  late ContextMenu contextMenu;
  double progress = 0;
  final urlController = TextEditingController();
  String url = "";
  String wordA = "lerlingua";

  _search({required String wordA, required String url}) {
    WebUri webUri = WebUri(url + wordA);
    webViewController?.loadUrl(urlRequest: URLRequest(url: webUri));
  }

  _saveVocabEntry(String? selectedText) async {
    if (selectedText != null) {
      Mirror().writeEntry(entry: VocabEntry(
        vocabKey: -1,
        languageA: 'bookLanguage',
        wordA: wordA,
        languageB: 'translationLanguage',
        wordB: selectedText,
        boxNumber: 0,
        timeLearned: DateTime.now().millisecondsSinceEpoch,
        timeModified: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  @override
  void initState() {
    // Subscribe to the event bus
    eventBus.on<WordASelectedEvent>().listen((event) {
      wordA = event.wordA;
      _search(
        wordA: wordA,
        url: 'https://translate.google.de/?sl=auto&tl=en&text=',
      );
      /// TODO make this dynamic
    });
    // Set up context menu see https://inappwebview.dev/docs/webview/context-menu
    contextMenu = ContextMenu(
      settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: true),
      menuItems: [
        ContextMenuItem(
            id: 1,
            title: "Add",
            action: () async {
              _saveVocabEntry(await webViewController?.getSelectedText());
            })
      ],
        onCreateContextMenu: (hitTestResult) async {
          String selectedText = await webViewController?.getSelectedText() ?? "";
        },
        onContextMenuActionItemClicked: (menuItem) {
          final snackBar = SnackBar(
            content: Text(
                "Menu item with ID ${menuItem.id} and title '${menuItem.title}' clicked!"),
            duration: const Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          // copy id to clipboard
          Clipboard.setData(ClipboardData(text: menuItem.id.toString()));
        }
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(height: 1, color: Colors.grey),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'back',
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back),
                              SizedBox(width: 10),
                              Text("Back"),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'forward',
                          child: Row(
                            children: [
                              Icon(Icons.arrow_forward),
                              SizedBox(width: 10),
                              Text("Forward"),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'reload',
                          child: Row(
                            children: [
                              Icon(Icons.refresh),
                              SizedBox(width: 10),
                              Text("Reload"),
                            ],
                          ),
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
                          url = WebUri("https://www.linguee.de/deutsch-portugiesisch/search?query=$value",);
                          wordA = value;
                          ///TODO make this dynamic
                        }
                        webViewController?.loadUrl(
                          urlRequest: URLRequest(url: url),
                        );
                      },
                      onTap: () {
                        urlController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: urlController.text.length,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Container(height: 1, color: Colors.grey),
            ),
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    key: webViewKey,
                    initialUrlRequest: URLRequest(
                      url: WebUri(
                        "https://www.deepl.com/de/translator#pt/en-us/ler%20lingua",
                      ),
                    ),

                    ///TODO make this dynamic
                    contextMenu: contextMenu,
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
                        action: PermissionResponseAction.GRANT,
                      );
                    },

                    onLoadStop: (controller, url) async {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = wordA;
                      });
                    },
                    onReceivedError: (controller, request, error) {},
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {}
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
          ],
        ),
      ),
    );
  }
}
