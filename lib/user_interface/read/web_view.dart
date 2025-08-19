import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../resources/event_bus.dart';
import '../../resources/database/mirror/mirror.dart';
import '../../resources/database/mirror/vocab_card.dart';
import '../../resources/settings/settings.dart';
import '../../resources/translation_service.dart';
import '../cards/edit_card_page.dart';
import 'edit_language_page.dart';

class WebView extends StatefulWidget {
  const WebView({super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  bool _isLoading = false;
  final String _initialJs = '''
  // Override the matchMedia method to block dark theme detection
(function() {
    const originalMatchMedia = window.matchMedia;

    window.matchMedia = function(query) {
        // Check if the query is for prefers-color-scheme
        if (query.includes('prefers-color-scheme')) {
            // Return a MediaQueryList object indicating light mode preference
            return {
                matches: false, // Indicate that dark mode is not preferred
                media: query,
                onchange: null,
                addListener: function() {},
                removeListener: function() {},
            };
        }
        // Call the original matchMedia for other queries
        return originalMatchMedia.apply(this, arguments);
    };
})();
  ''';
  static final String _lightThemeJs = '''
// Create a new div element for the overlay
var overlay = document.createElement('div');

// Set the style for the overlay
overlay.style.position = 'fixed';
overlay.style.top = '0';
overlay.style.left = '0';
overlay.style.width = '100%';
overlay.style.height = '100%';
overlay.style.backgroundColor = 'rgba(232, 207, 170, 0.05)'; // Beige color with some transparency
overlay.style.pointerEvents = 'none'; // Allow clicks to pass through the overlay
overlay.style.zIndex = '9999'; // Ensure it is on top of other elements

// Append the overlay to the body
document.body.appendChild(overlay);
  ''';

  static final String _darkThemeJs = '''
  const style = document.createElement('style');
// Add your CSS rule to the style element
style.textContent = `
  :root body {
    filter: invert(100%) !important;
  }
`;
// Append the style element to the head of the document
try {
  document.head.appendChild(style);
} catch (error) {
  console.error(error);
}
  ''';

  final String _themeJs = Settings().isDarkMode ? _darkThemeJs : _lightThemeJs;

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
  String wordB = "";
  String sentenceB = "";
  bool _wordBChanged = false;
  TranslationService _translationService = TranslationService(key: 0, icon: Icons.translate, languageA: 'en', languageB: 'xx', urlAtoB: 'https://translate.google.com/?sl=auto&tl=en&text=%search%', urlBtoA: 'https://translate.google.com/?sl=es&tl=auto&text=%search%', injectJs: ''); // TODO check this

  _search() {
    _isLoading = true;
    if (mounted) {
      setState(() {});
    }
    _translationService = Settings().currentTranslationService ?? _translationService;
    String url = _translationService.getUrl(wordB, TranslationDirection.AtoB); // TODO CHANGE THIS
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
    if (mounted) {
      setState(() {});
    }
  }

  _saveVocabCard(String? selectedText) async {
    if (selectedText != null && selectedText.isNotEmpty && wordB.isNotEmpty) {
      VocabCard card = VocabCard(
        vocabKey: -1,
        languageA: _translationService.languageA,
        wordB: wordB,
        sentenceB: _wordBChanged ? '' : sentenceB,
        languageB: Settings().currentBook?.languageB ?? '',
        wordA: selectedText,
        boxNumber: 0,
        timeModified: DateTime.now().millisecondsSinceEpoch,
      );
      card = Mirror().writeCard(card: card, addNewUndo: false);
      if (_wordBChanged) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foreign language is ${card.languageB}.'),
            action: SnackBarAction(
              label: 'Edit Card',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditCardPage(card: card,)));
              },
            ),
          ));
      }
    }
  }

  @override
  void initState() {
    // Subscribe to the event bus
    eventBus.on<WordBSelectedEvent>().listen((event) {
      _wordBChanged = false;
      wordB = event.wordB;
      sentenceB = event.sentenceB;
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
              String?  selectedText = await webViewController?.getSelectedText();
              if (Settings().currentBook?.languageB == '') {
                if (mounted) {
                  await editLanguageDialog(context);
                }
              }
              if (selectedText != null && selectedText.trim().isNotEmpty && Settings().currentBook?.languageB != '') {
                _saveVocabCard(selectedText);
              } else {
                String message = 'No text selected.';
                if (Settings().currentBook?.languageB == '') {
                  message = 'No book language set.';
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              }
            })
      ],
    );
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _wordBChanged = false;
      _search();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
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
                      if(wordB != value) _wordBChanged = true;
                      wordB = value;
                      _search();
                      return;
                    }
                    webViewController?.loadUrl(
                      urlRequest: URLRequest(url: url),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(
                  url: WebUri(
                    "https://github.com/avenaradio/lerlingua/blob/main/README.md#how-to-use",
                  ),
                ),
                contextMenu: contextMenu,
                initialSettings: settings,
                initialUserScripts: UnmodifiableListView([
                  UserScript(
                      source: _initialJs,
                      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                  ),
                ]),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  if (mounted) {
                    setState(() {
                      _isLoading = true;
                      this.url = url.toString();
                      //urlController.text = this.url;
                    });
                  }
                },
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT,
                  );
                },

                onLoadStop: (controller, url) async {
                  await controller.evaluateJavascript(source: '$_themeJs\n${_translationService.injectJs}');
                  // wait to load JS
                  await Future.delayed(const Duration(milliseconds: 400));
                  if (mounted) {
                    setState(() {
                    this.url = url.toString();
                    urlController.text = wordB;
                    _isLoading = false;
                  });
                  }
                },
                onReceivedError: (controller, request, error) {
                  if (mounted) {
                    setState(() {
                    _isLoading = false;
                  });
                  }
                },
                onProgressChanged: (controller, progress) {
                  //if (progress == 100) {}
                  if (mounted) {
                    setState(() {
                    this.progress = progress / 100;
                    //urlController.text = url;
                  });
                  }
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  if (mounted) {
                    setState(() {
                    this.url = url.toString();
                    //urlController.text = this.url;
                  });
                  }
                },
                onConsoleMessage: (controller, consoleMessage) {
                  if (kDebugMode) {
                    //print(consoleMessage);
                  }
                },
              ),
              progress < 1.0 || _isLoading
                  ? Container(height: double.infinity, width: double.infinity, color: Theme.of(context).colorScheme.surface, child: Column(
                    children: [
                      LinearProgressIndicator(value: progress),
                    ],
                  ))
                  : Container(key: Key('webViewIsLoaded'),),
            ],
          ),
        ),
      ],
    );
  }
}
