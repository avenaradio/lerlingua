import 'dart:async';
import 'dart:io';
import 'package:epub_pro/epub_pro.dart' as epub_pro;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import '../event_bus.dart';
import '../file_utils/book.dart';
import '../settings.dart';

class EpubViewerController {
  final double _fontSize = 16;
  final double _charactersPerArea = 0.0039; // To calculate number of characters for the page TODO use font size
  final double _charactersPerDistance = 0.0625; // To calculate number of characters for the page TODO use font size
  late Size _parentWidgetSize;
  int _charactersPerPage = 0;
  int _charactersPerLine = 0;

  late VoidCallback _onRendered;
  String log = 'PARSER LOG:\n';
  Book? _book;
  late epub_pro.EpubBook _epubBook;
  // Read location
  late int _chapterIndex;
  late int _subChapterIndex;
  late int _currentPositionIndex;
  List<WidgetWithSize> _chapterWidgetsWithSize = [];
  /// from 0 to _chapterWidgets.length
  final List<int> _pagePositionIndices = [];
  List<Widget> pageWidgets = [];

  onRendered(VoidCallback onRendered) {
    _onRendered = onRendered;
  }

  Future<void> loadBook({required BuildContext context, required Size parentWidgetSize, Book? book, required VoidCallback onRendered}) async {
    _parentWidgetSize = parentWidgetSize;
    _charactersPerPage = (_charactersPerArea * _parentWidgetSize.width * _parentWidgetSize.height).toInt();
    _charactersPerLine = (_charactersPerDistance * _parentWidgetSize.width).toInt();
    if (book == null) {
      _book = null;
      // Load book from asset
      Uint8List bytes = await rootBundle.load('assets/books/the_little_prince_public_domain.epub').then((value) => value.buffer.asUint8List());
      _epubBook = await epub_pro.EpubReader.readBook(bytes);
      _chapterIndex = 1;
      _subChapterIndex = 0;
      _currentPositionIndex = 0;
    } else {
      _book = book;
      // Load book from file
      final file = File(book.path);
      Uint8List bytes = await file.readAsBytes();
      _epubBook = await epub_pro.EpubReader.readBook(bytes);
      if (book.readingLocation == '') {
        _chapterIndex = 0;
        _subChapterIndex = 0;
        _currentPositionIndex = 0;
      } else {
        _chapterIndex = int.tryParse(book.readingLocation.split('/')[0]) ?? 0;
        _subChapterIndex = int.tryParse(book.readingLocation.split('/')[1]) ?? 0;
        _currentPositionIndex = int.tryParse(book.readingLocation.split('/')[2]) ?? 0;
      }
    }
    _loadChapter();
    _renderCurrentPage();
  }

  void _updateBookPosition() {
    if (_book != null) {
      _book?.readingLocation = '$_chapterIndex/$_subChapterIndex/$_currentPositionIndex';
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
    _chapterWidgetsWithSize = [];
    for (int i = 0; i < bodyElements.length; i++) {
      if (bodyElements[i].text.trim() == '') {
        if (i > 0 && bodyElements[i - 1].text.trim() == '') {
          continue; // Don't add two empty widgets in a row
        }
      }
      _chapterWidgetsWithSize.addAll(_domElementToWidgets(bodyElements[i]));
    }
  }

  /// Converts html into dom elements
  dom.Element? _chapterBody() {
    String? html;
    for (int i = 0; i < _epubBook.chapters.length; i++) {
      if (i == _chapterIndex) {
        bool hasSubChapters = _epubBook.chapters[i].subChapters.isNotEmpty;
        if (hasSubChapters) {
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
  List<String> selectedWords = [];
  /// Is multi selection enabled
  bool isMultiSelection = false;
  /// Adds word to selection
  _addToSelection(String word, List<String> sentence) {
    if(!isMultiSelection || (selectedWords.isNotEmpty && !sentence.contains(selectedWords.first))) { // If not multi selection || word is from different sentence -> clear
      selectedWords.clear();
      selectedWords.add(word);
      isMultiSelection = false;
    }
    if (isMultiSelection && selectedWords.contains(word)) {
      selectedWords.remove(word); // Remove word
      if (selectedWords.isEmpty) {
        isMultiSelection = false; // End selection
      }
    } else if (isMultiSelection && !selectedWords.contains(word)) {
      selectedWords.add(word); // Add word
    }
  }
  /// Toggles multi selection
  _toggleMultiSelection(String word, List<String> sentence) {
      if (!isMultiSelection) { // Start selection
        selectedWords.clear();
        isMultiSelection = true;
      }
      if (selectedWords.isNotEmpty && !sentence.contains(selectedWords.first)) { // If word is from different sentence -> clear this wont trigger in _addToSelection again
        selectedWords.clear();
      }
      _addToSelection(word, sentence);
  }

  /// Returns Widgets from dom element
  List<WidgetWithSize> _domElementToWidgets(dom.Element? element) {
    if (element == null) {
      log += 'domElementToWidget: element is null\n';
      return [];
    }
    if (element.localName == 'img') {
      List<int>? image = _epubBook.content!.images[element.attributes['src'] ?? '']?.content;
      if (image == null) return [];
      return [WidgetWithSize(widget: Image.memory(Uint8List.fromList(image)), charactersCount: _charactersPerPage)];
    }
    List<String> sentences = splitParagraphIntoSentences(_cleanText(element.text));
    List<WidgetWithSize> wordWidgetsWithSize = [];
    for (String sentence in sentences) {
      List<String> splitSentence = sentence.split(' ');
      for (String word in splitSentence) {
        int charactersCount = word.characters.length + 1;
        Widget wordWidget = Padding(
          padding: const EdgeInsets.fromLTRB(0, 2, 4, 2),
          child: GestureDetector(
            onTap: () {
              _addToSelection(word, splitSentence);
              // Create and fire the event
              final event = WordBSelectedEvent(wordsB: selectedWords, sentenceListB: splitSentence);
              eventBus.fire(event);
            },
            onLongPress: () {
              _toggleMultiSelection(word, splitSentence);
              // Create and fire the event
              final event = WordBSelectedEvent(wordsB: selectedWords, sentenceListB: splitSentence);
              eventBus.fire(event);
            },
            child: Text(word, style: selectedWords.contains(word) ? TextStyle(backgroundColor: Colors.yellow[200]) : null),
          ),
        );
        wordWidgetsWithSize.add(WidgetWithSize(widget: wordWidget, charactersCount: charactersCount));
      }
    }
    wordWidgetsWithSize.add(WidgetWithSize(widget: SizedBox(height: 0, width: double.infinity), charactersCount: _charactersPerLine));
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
      // Add the processed sentence to the final list
      finalSentences.add(currentSentence);
    }
    return finalSentences;
  }

  Size _getTextSize(String text, TextStyle style, double maxWidth) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.size;
  }

  void _paginate() {
    int count = 0;
    for (int i = 0; true; i++) {
      if (i >= _chapterWidgetsWithSize.length) {
        _pagePositionIndices.add(i); // Add end of chapter index
        break;
      }
      count += _chapterWidgetsWithSize[i].charactersCount;
      if (count > _charactersPerPage) {
        _pagePositionIndices.add(i); // Add next page index
        i--;
        count = 0;
      }
    }
  }

  int _nextPositionIndex(int currentPositionIndex) {
    int nextPositionIndex = _currentPositionIndex;
    for (int i = 0; i < _pagePositionIndices.length; i++) {
      if (_pagePositionIndices[i] > currentPositionIndex) {
        nextPositionIndex = _pagePositionIndices[i];
        break;
      }
    }
    return nextPositionIndex;
  }

  /// Returns widgets for next page
  Future<void> nextPage() async {
    _currentPositionIndex = _nextPositionIndex(_currentPositionIndex);
    // If this next _currentPositionIndex is out of rage load next chapter
    if (_currentPositionIndex >= _chapterWidgetsWithSize.length) {
      _nextChapter();
    }
    _updateBookPosition();
    _renderCurrentPage();
  }

  /// Returns widgets for previous page
  Future<void> previousPage() async {
    int previousPositionIndex = _currentPositionIndex;
    // If _currentPositionIndex <= 0 load previous chapter
    if (_currentPositionIndex <= 0) {
      _previousChapter();
    } else {
      for (int i = 0; i < _pagePositionIndices.length; i++) {
        if (_pagePositionIndices[i] >= _currentPositionIndex) {
          previousPositionIndex = _pagePositionIndices[i - 1];
          break;
        }
      }
      _currentPositionIndex = previousPositionIndex;
    }
    _updateBookPosition();
    _renderCurrentPage();
  }

  /// Renders the current page
  void _renderCurrentPage() {
    int startIndex = _currentPositionIndex;
    int nextPageIndex = _nextPositionIndex(startIndex);
    List<Widget> currentPageItems = []; // Generate current page
    for (int i = startIndex; i < nextPageIndex; i++) {
      if (i < _chapterWidgetsWithSize.length) {
        currentPageItems.add(_chapterWidgetsWithSize[i].widget);
      }
    }
    pageWidgets = currentPageItems; // Write new current page
    _onRendered(); // Notify listeners that the page has been rendered
    _updateBookPosition();
  }

  void _nextChapter() {
    bool hasSubChaptersLeft = (_epubBook.chapters[_chapterIndex].subChapters.isNotEmpty && _subChapterIndex < _epubBook.chapters[_chapterIndex].subChapters.length - 1);
    if (hasSubChaptersLeft) {
      _subChapterIndex++;
    } else if (_chapterIndex < _epubBook.chapters.length - 1) {
      _chapterIndex++;
    }
    _currentPositionIndex = 0;
    _loadChapter();
  }

  void _previousChapter() {
    int oldChapterIndex = _chapterIndex;
    int oldSubChapterIndex = _subChapterIndex;
    bool hasPreviousSubChapters = (_epubBook.chapters[_chapterIndex].subChapters.isNotEmpty && _subChapterIndex > 0);
    bool hasPreviousChapters = (_chapterIndex > 0);
    if (hasPreviousSubChapters) {
      _subChapterIndex--; // Go to previous subchapter
    } else if (hasPreviousChapters) {
      _chapterIndex--; // Go to previous chapter
      bool hasSubChapters = (_epubBook.chapters[_chapterIndex].subChapters.isNotEmpty);
      if (hasSubChapters) {
        _subChapterIndex = _epubBook.chapters[_chapterIndex].subChapters.length - 1; // Go to last subchapter
      }
    } else {
      _chapterIndex = 0;
      _subChapterIndex = 0;
    }
    _loadChapter();
    if (oldChapterIndex != _chapterIndex || oldSubChapterIndex != _subChapterIndex) {
      _currentPositionIndex = _pagePositionIndices[_pagePositionIndices.length - 2];
    }
  }

  void _loadChapter() {
    _createWidgets();
    _paginate();
  }

}

class WidgetWithSize {
  final Widget widget;
  final int charactersCount;
  WidgetWithSize({required this.widget, required this.charactersCount});
}