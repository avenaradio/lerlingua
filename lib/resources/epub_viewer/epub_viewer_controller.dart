import 'dart:async';
import 'dart:io';
import 'package:epub_pro/epub_pro.dart' as epub_pro;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:lerlingua/general/string_extension.dart';
import 'package:lerlingua/resources/epub_viewer/sentence_with_selection.dart';
import '../../user_interface/theme/theme_filter.dart';
import '../event_bus.dart';
import '../file_utils/book.dart';
import '../settings/settings.dart';

// TODO NEEDS TESTING!
class EpubViewerController {
  final double _fontSize = Settings().fontSize.toDouble();
  late Size _parentWidgetSize;
  final List<ValueChanged<String>> _onRendered = [];
  late VoidCallback _onTextSelected;
  String log = 'PARSER LOG:\n';
  Book? _book;
  late epub_pro.EpubBook _epubBook;
  // Read location
  late int _chapterIndex;
  late int _subChapterIndex;
  late int _currentPageIndex;
  List<WidgetData> _chapterWidgetsData = [];
  final List<List<WidgetData>> _pages = [];

  /// Build current page
  List<Widget> currentPage(BuildContext context) {
    List<Widget> currentPage = [];
    if (_pages.isEmpty) return [];
    if (_currentPageIndex >= _pages.length) {
      _currentPageIndex = _pages.length - 1;
    }
    if (_currentPageIndex < 0) {
      _currentPageIndex = 0;
    }
    // Build widgets
    for (WidgetData widgetData in _pages[_currentPageIndex]) {
      currentPage.add(widgetData.build(context));
    }
    return currentPage;
  }

  /// Returns page of chapter (1|44)
  onRendered(ValueChanged<String> onRendered) {
    _onRendered.add(onRendered);
  }
  void _fireOnRendered() {
    String chapterName = '';
    if (_epubBook.chapters.isEmpty) {
      return;
    } else if (_epubBook.chapters[_chapterIndex].subChapters.isEmpty) {
      chapterName = '${_chapterIndex + 1}';
    } else {
      chapterName = '${_chapterIndex + 1}.${_subChapterIndex + 1}';
    }
    for (ValueChanged<String> onRendered in _onRendered) {
      onRendered('$chapterName ${_currentPageIndex + 1}|${_pages.length}');
    }
  }

  /// Fires when text is selected
  onTextSelected(VoidCallback onTextSelected) {
    _onTextSelected = onTextSelected;
  }

  Future<void> loadBook({required BuildContext context, required Size parentWidgetSize, Book? book, required ValueChanged<String> onRendered}) async {
    _onRendered.add(onRendered);
    _parentWidgetSize = Size(parentWidgetSize.width, parentWidgetSize.height - 100);
    if (book == null) {
      _book = null;
      // Load book from asset
      Uint8List bytes = await rootBundle.load('assets/books/default.epub').then((value) => value.buffer.asUint8List());
      _epubBook = await epub_pro.EpubReader.readBook(bytes);
      _chapterIndex = 0;
      _subChapterIndex = 0;
      _currentPageIndex = 0;
    } else {
      _book = book;
      // Load book from file
      final file = File(book.path);
      Uint8List bytes = await file.readAsBytes();
      _epubBook = await epub_pro.EpubReader.readBook(bytes);
      if (book.readingLocation == '') {
        _chapterIndex = 0;
        _subChapterIndex = 0;
        _currentPageIndex = 0;
      } else {
        bool isCfi = book.readingLocation.contains('/');
        if (isCfi) {
          book.readingLocation = '0|0|0';
        }
        _chapterIndex = int.tryParse(book.readingLocation.split('|')[0]) ?? 0;
        _subChapterIndex = int.tryParse(book.readingLocation.split('|')[1]) ?? 0;
        _currentPageIndex = int.tryParse(book.readingLocation.split('|')[2]) ?? 0;
      }
    }
    _loadChapter();
  }

  void _updateBookPosition() {
    if (_book != null) {
      _book?.readingLocation = '$_chapterIndex|$_subChapterIndex|$_currentPageIndex';
      _book?.lastReadTime = DateTime.now().millisecondsSinceEpoch;
      Settings().addOrUpdateBook(_book!);
    }
  }

  void _createWidgets() {
    if (_epubBook.content != null) {
      //for (var image in epubBook.content!.images) {}
    }
    log += 'chapters count: ${_epubBook.chapters.length}\n';
    log += 'chapterIndex: $_chapterIndex\n';
    log += 'subchapters count: ${_epubBook.chapters[_chapterIndex].subChapters.length}\n';
    dom.Element? body = _chapterBody();
    List<dom.Element> bodyElements = _elementList(body, 'div');
    for (dom.Element element in bodyElements) {
      log += '${element.outerHtml}\n';
    }
    _chapterWidgetsData = [];
    for (int i = 0; i < bodyElements.length; i++) {
      _chapterWidgetsData.addAll(_domElementToWidgets(bodyElements[i]));
    }
  }

  /// Converts html into dom elements
  dom.Element? _chapterBody() {
    String? html;
    for (int i = 0; i < _epubBook.chapters.length; i++) {
      if (i == _chapterIndex) {
        bool hasSubChapters = _epubBook.chapters[i].subChapters.isNotEmpty;
        if (hasSubChapters && _subChapterIndex >= 0) {
          for (int j = 0; j < _epubBook.chapters[i].subChapters.length; j++) {
            if (j == _subChapterIndex) {
              html = _epubBook.chapters[i].subChapters[j].htmlContent;
            }
          }
        }else {
          html = _epubBook.chapters[i].htmlContent;
        }
      }
    }
    if (html == null) {
      log += 'chapterBody: chapterHtml is null\n';
      return null;
    }
    dom.Document document = html_parser.parse(html);
    return document.body;
  }

  /// Converts a dom element into a list of dom elements
  List<dom.Element> _elementList(dom.Element? element, String? parentTag) {
    List<String> wrapperTags = ['div', 'ul', 'ol', 'table', 'tr', 'section']; // Only these tags will be read recursively
    List<dom.Element> elements = [];
    if (element == null) {
      log += 'elementList: element is null\n';
      return elements;
    }
    dom.NodeList childNodes = element.nodes;
    for (var node in childNodes) {
      if (node is dom.Text) { // If text, add
        dom.Element textElement = dom.Document().createElement(parentTag ?? 'div');
        if (node.text.trim() != '') {
          textElement.innerHtml = node.text.trim();
          elements.add(textElement);
        }
      }else if (node is dom.Element) {
        String nodeTag = node.localName ?? 'p';
        if (wrapperTags.contains(nodeTag)) { // If wrapper go deeper
          List<dom.Element> childElements = _elementList(node, nodeTag);
          elements.addAll(childElements);
        } else if (nodeTag == 'img') { // If img, add
          elements.add(node);
        } else { // If other, add and add img if present
          dom.Element noRecursiveElement = dom.Document().createElement(nodeTag);
          noRecursiveElement.innerHtml = node.text.trim();
          elements.add(noRecursiveElement);
          List<dom.Element> imgElements = _imgFromElement(node);
          elements.addAll(imgElements);
        }
      }
    }
    return elements;
  }

  /// Returns all img elements from an element
  List<dom.Element> _imgFromElement(dom.Element? element) {
    List<dom.Element> elements = [];
    if (element == null) {
      log += 'containsImage: element is null\n';
      return elements;
    }
    dom.NodeList childNodes = element.nodes;
    for (var node in childNodes) {
      if (node is dom.Element) {
        if (node.localName == 'img') {
          elements.add(node);
        }
      }
    }
    return elements;
  }

  /// List of selected words
  static SentenceWithSelection sentenceWithSelection = SentenceWithSelection(words: [], selected: []);
  bool _nextLongPressStartsAreaSelection = false;
  /// Select words
  @visibleForTesting
  multiSelection(int wordIndex, List<String> sentence, bool isLongPress) {
    if (sentenceWithSelection.words != sentence) {
      sentenceWithSelection = SentenceWithSelection(words: sentence, selected: []); // If is different sentence -> clear
      _nextLongPressStartsAreaSelection = false;
    }
    if (_nextLongPressStartsAreaSelection && isLongPress) {
      int i = sentenceWithSelection.selected.last;
      while (i >= 0 && i < sentenceWithSelection.words.length) {
        if (i < wordIndex) {
          sentenceWithSelection.selected.add(i);
          i++;
        } else if (i > wordIndex) {
          sentenceWithSelection.selected.add(i);
          i--;
        } else {
          break;
        }
      }
      _nextLongPressStartsAreaSelection = false;
    } else if (!_nextLongPressStartsAreaSelection && isLongPress) {
      _nextLongPressStartsAreaSelection = true;
      sentenceWithSelection = SentenceWithSelection(words: sentence, selected: []);// Long press -> clear
    } else {
      _nextLongPressStartsAreaSelection = false;
    }
    if (sentenceWithSelection.selected.contains(wordIndex)) {
      sentenceWithSelection.selected.remove(wordIndex); // Remove word
    } else {
      sentenceWithSelection.selected.add(wordIndex); // Add word
    }
    if (sentenceWithSelection.selected.isNotEmpty) {
      // Create and fire the event
      final event = WordBSelectedEvent(wordB: sentenceWithSelection.selectedWordsJoined, sentenceB: sentenceWithSelection.sentenceWrapped);
      eventBus.fire(event);
      _onTextSelected(); // Fire selection event
    }
    _fireOnRendered();
  }

  /// Returns Widgets from dom element
  List<WidgetData> _domElementToWidgets(dom.Element? element) {
    if (element == null) {
      log += 'domElementToWidget: element is null\n';
      return [];
    }
    if (element.localName == 'img') {
      for (int i = 0; i < _epubBook.content!.images.length; i++) {
      }
      String src = (element.attributes['src'] ?? '').trimNonAlphanumeric();
      List<int>? image = _epubBook.content!.images[src]?.content;
      if (image == null) {
        return [];
      }
      Uint8List? imageUint8List = Uint8List.fromList(image);
      return [WidgetData(
          builder: (_, _, _) => Image.memory(imageUint8List),
          widgetType: Image,
          size: Size(_parentWidgetSize.width, _parentWidgetSize.height),
      )];
    }
    List<String> sentences = splitParagraphIntoSentences(_cleanText(element.text));
    List<WidgetData> wordWidgetsWithSize = [];
    for (int i = 0; i < sentences.length; i++) {
      String sentence = sentences[i];
      List<String> splitSentence = sentence.split(' ');
      for (int j = 0; j < splitSentence.length; j++) {
        String word = '${splitSentence[j]} ';
        if (word.trim() != '') {
          wordWidgetsWithSize.add(WidgetData(
              builder: (children, highlight, context) => GestureDetector(
                onTap: () {
                  multiSelection(j, splitSentence, false);
                },
                onLongPress: () {
                  multiSelection(j, splitSentence, true);
                },
                child: Text(word, style: (TextStyle(fontSize: _fontSize, backgroundColor: highlight ? Theme.of(context).colorScheme.inversePrimary : null))),
              ),
              widgetType: GestureDetector,
              sentence: SentenceWithSelection(words: splitSentence, selected: [j]),
              size: _getTextSize(word),
          ));
        }
      }
    }
    if (wordWidgetsWithSize.isNotEmpty) {
      wordWidgetsWithSize.add(WidgetData(
          builder: (_, _, _) => SizedBox(height: 0, width: _parentWidgetSize.width),
          widgetType: SizedBox,
          size: Size(_parentWidgetSize.width, 0),
      ));
    }
    return wordWidgetsWithSize;
  }

  /// Cleans text
  String _cleanText(String text) {
    text.replaceAll(RegExp(r'\s+'), ' ');
    text.replaceAll(RegExp(r'\s+'), ' ');
    text = text.trim();
    return text;
  }

  /// Splits a paragraph into sentences
  /// - Tested
  @visibleForTesting
  List<String> splitParagraphIntoSentences(String paragraph) {
    // Regular expression to match sentence boundaries
    final RegExp sentenceRegExp = RegExp(
      r'(?<=[.!?])\s+', // Matches spaces after a period, exclamation mark, or question mark
    );
    // Split the paragraph into sentences
    List<String> sentences = paragraph.split(sentenceRegExp).map((sentence) => sentence.trim()).toList();
    // List to hold the final sentences
    List<String> finalSentences = [];
    for (int i = 0; i < sentences.length; i++) {
      String currentSentence = sentences[i];
      // Check if the next sentence exists and starts with a number or lowercase letter
      if (i < sentences.length - 1) {
        String nextSentence = sentences[i + 1];
        if (RegExp(r'^[a-z]').hasMatch(nextSentence)) {
          // Merge current sentence with the next one
          currentSentence += ' $nextSentence';
          i++; // Skip the next sentence as it has been merged
        }
      }
      finalSentences.add(currentSentence);
    }
    return finalSentences;
  }

  Size _getTextSize(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: _fontSize * 1.1)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: _parentWidgetSize.width);
    //print('------------------------------------------- "$text" ${textPainter.size.width}');
    return textPainter.size;
  }

  void _paginate() {
    _pages.clear();
    int countWidth = 0;
    int countHeight = 0;
    List<WidgetData> line = [];
    List<WidgetData> page = [];
    bool lastI = false;
    for (int i = 0; i < _chapterWidgetsData.length; i++) {
      if (i == _chapterWidgetsData.length - 1) lastI = true;
      countWidth += (_chapterWidgetsData[i].size?.width ?? 0).toInt();
      line.add(_chapterWidgetsData[i]);
      line.add(WidgetData(
        builder: (_, _, _) => Spacer(),
        widgetType: Spacer,
        size: Size(0, 0),
      ));
      if (lastI || (countWidth + (_chapterWidgetsData[i + 1].size?.width ?? 0) > _parentWidgetSize.width)) { // If line + next would overflow or last
        if (_chapterWidgetsData[lastI ? i : i + 1].widgetType == SizedBox) { // If next is SizedBox remove Spacers (or if last i and it is a SizedBox)
          for (int j = 0; j < line.length; j++) {
            if (line[j].runtimeType == Spacer) {
              line.removeAt(j);
              line.insert(j, WidgetData(
                  builder: (_, _, _) => SizedBox(width: 3),
                  widgetType: SizedBox,
                  size: Size(3, 0),
              ));
            }
          }
        }
        line.removeLast(); // Remove last Spacer
        WidgetData row = WidgetData(
            builder: (children, _, _) => Row(mainAxisAlignment: MainAxisAlignment.start, children: children),
            widgetType: Row,
            size: Size(_parentWidgetSize.width, 0),
            childrenBuilders: [...line]);
        countHeight += (_chapterWidgetsData[i].size?.height ?? 0).toInt(); // Why to int?
        page.add(row);
        line.clear();
        countWidth = 0;
        if (lastI || (countHeight + (_chapterWidgetsData[i + 1].size?.height ?? 0) > _parentWidgetSize.height)) { // If page + next would overflow
          if (_chapterWidgetsData[i].widgetType == Image) { // If this is Image remove add Spacers
            page = [WidgetData(builder: (children, _, _) => Expanded(child: ColorFiltered(
                colorFilter: Settings().isDarkMode ? ThemeFilter.undoDark : ThemeFilter.undoLight,
                child: children.first)),
                widgetType: Expanded,
                size: Size(_parentWidgetSize.width, _parentWidgetSize.height),
                childrenBuilders: [_chapterWidgetsData[i]],
            )];
          }
          if (page.isNotEmpty) {
            _pages.add([...page]);
          }
          page.clear();
          countHeight = 0;
        }
      }
    }
  }

  /// Returns widgets for next page
  void nextPage() {
    _currentPageIndex++;
    // If this next _currentPositionIndex is out of rage load next chapter
    if (_currentPageIndex >= _pages.length) {
      _currentPageIndex = _pages.length - 1;
      nextChapter();
    }
    _updateBookPosition();
    _fireOnRendered();
  }

  /// Returns widgets for previous page
  void previousPage() {
    _currentPageIndex--;
    // If _currentPositionIndex <= 0 load previous chapter
    if (_currentPageIndex < 0) {
      _currentPageIndex = 0;
      previousChapter();
    }
    _updateBookPosition();
    _fireOnRendered();
  }

  void nextChapter() {
    bool hasSubChaptersLeft = (_epubBook.chapters[_chapterIndex].subChapters.isNotEmpty && _subChapterIndex < _epubBook.chapters[_chapterIndex].subChapters.length - 1);
    if (hasSubChaptersLeft) {
      _subChapterIndex++;
      _currentPageIndex = 0;
      _loadChapter();
    } else if (_chapterIndex < _epubBook.chapters.length - 1) {
      _chapterIndex++;
      _subChapterIndex = -1;
      _currentPageIndex = 0;
      _loadChapter();
    }
  }

  void previousChapter({bool? goToFirstPage}) {
    if (_currentPageIndex > 0) {
      _currentPageIndex = 0;
    } else {
      goToFirstPage = goToFirstPage ?? false;
      bool hasPreviousSubChapters = (_epubBook.chapters[_chapterIndex].subChapters.isNotEmpty && _subChapterIndex > -1);
      bool hasPreviousChapters = (_chapterIndex > 0);
      if (hasPreviousSubChapters) {
        _subChapterIndex--; // Go to previous subchapter
        if (goToFirstPage) {
          _currentPageIndex = 0;
        } else {
          _currentPageIndex = 999999;
        }
      } else if (hasPreviousChapters) {
        _chapterIndex--; // Go to previous chapter
        bool hasSubChapters = (_epubBook.chapters[_chapterIndex].subChapters.isNotEmpty);
        if (hasSubChapters) {
          _subChapterIndex = _epubBook.chapters[_chapterIndex].subChapters.length - 1; // Go to last subchapter
        }
        if (goToFirstPage) {
          _currentPageIndex = 0;
        } else {
          _currentPageIndex = 999999;
        }
      } else {
        _chapterIndex = 0;
        _subChapterIndex = -1;
      }
    }
    _loadChapter();
  }

  void _loadChapter() {
    _createWidgets();
    _paginate();
    if (_currentPageIndex >= _pages.length) {
      _currentPageIndex = _pages.length - 1;
    } else if (_currentPageIndex < 0) {
      _currentPageIndex = 0;
    }
    if (_pages.isEmpty) {
      _currentPageIndex = 0;
    }
    _updateBookPosition();
    _fireOnRendered();
  }

}

class WidgetData {
  final Widget Function(List<Widget> children, bool highlight, BuildContext context) builder;
  final Type widgetType;
  final List<WidgetData>? childrenBuilders;
  final Size? size;
  //final String word;
  final SentenceWithSelection? sentence;
  WidgetData({required this.builder, required this.widgetType, this.sentence, this.size, this.childrenBuilders});

  Widget build(BuildContext context) {
    List<Widget> childrenWidgets = [];
    if (childrenBuilders != null && childrenBuilders!.isNotEmpty) {
      for (WidgetData child in childrenBuilders!) {
        childrenWidgets.add(child.build(context));
      }
    }
    bool highlight = false;
    if (EpubViewerController.sentenceWithSelection.words == sentence?.words) {
      if(EpubViewerController.sentenceWithSelection.selected.contains(sentence?.selected.firstOrNull ?? -1)) {
        highlight = true;
      }
    }
    return builder(childrenWidgets, highlight, context);
  }
}
