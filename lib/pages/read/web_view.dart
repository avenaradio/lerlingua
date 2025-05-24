import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../resources/event_bus.dart';
import '../../resources/database/mirror.dart';
import '../../resources/database/vocab_card.dart';
import '../../resources/settings.dart';
import '../../resources/translation_service.dart';

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
  String wordB = "lerlingua";
  TranslationService _translationService = TranslationService(key: 0, icon: Icons.translate, languageA: 'en', languageB: 'xx', url: 'https://translate.google.com/?sl=auto&tl=en&text=%search%', injectJs: '');

  _search() {
    _translationService = Settings().currentTranslationService ?? _translationService;
    String url = _translationService.getUrl(wordB);
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This translation service has not placeholder %search%.')),
      );
      return;
    }
    WebUri webUri = WebUri(url);
    if(webUri.isValidUri && webUri.hasAuthority) {
      webViewController?.loadUrl(urlRequest: URLRequest(url: webUri));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This translation service has no valid url.')),
      );
    }
    setState(() {});
  }

  _saveVocabCard(String? selectedText) async {
    if (selectedText != null) {
      Mirror().writeCard(card: VocabCard(
        vocabKey: -1,
        languageA: _translationService.languageA,
        wordB: wordB,
        languageB: 'bookLanguage',
        wordA: selectedText,
        boxNumber: 0,
        timeModified: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  @override
  void initState() {
    // Subscribe to the event bus
    eventBus.on<WordBSelectedEvent>().listen((event) {
      wordB = event.wordB;
      _search();
    });
    // Set up context menu see https://inappwebview.dev/docs/webview/context-menu
    contextMenu = ContextMenu(
      settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: true),
      menuItems: [
        ContextMenuItem(
            id: 1,
            title: "Add",
            action: () async {
              _saveVocabCard(await webViewController?.getSelectedText());
            })
      ],
    );
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _search();
    });
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
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) {
                      return Settings().translationServices.map((service) {
                        return PopupMenuItem<String>(
                          value: service.key.toString(),
                          child: Row(
                            children: [
                              Icon(service.icon),
                              SizedBox(width: 10),
                              Text('${service.languageB} -> ${service.languageA}'),
                            ],
                          ),
                        );
                      }).toList()
                        ..add(
                          PopupMenuItem<String>(
                            value: '0',
                            child: Row(
                              children: [
                                Icon(Icons.settings_rounded),
                                SizedBox(width: 10),
                                Text('Edit Services'),
                              ],
                            ),
                          ),
                        );
                    },
                    onSelected: (String? value) {
                      final key = int.parse(value!);
                      if (key == 0) {
                        // Push translation service settings page
                        Navigator.pushNamed(context, '/settings/translation_services');
                        return;
                      }
                      Settings().currentTranslationService = Settings().translationServices.firstWhere((service) => service.key == key);
                      _search();
                    },
                    icon: Icon(_translationService.icon), // Current translation service icon
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: urlController,
                      keyboardType: TextInputType.url,
                      onSubmitted: (value) {
                        var url = WebUri(value);
                        if (url.scheme.isEmpty) {
                          wordB = value;
                          _search();
                          return;
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
                        "https://translate.google.com/?sl=auto&tl=en&text=ler%20lingua",
                      ),
                    ),
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
                      await controller.evaluateJavascript(source: _translationService.injectJs);
                      setState(() {
                        this.url = url.toString();
                        urlController.text = wordB;
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
