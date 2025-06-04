import 'dart:async';
import 'dart:io';
import 'package:epub_pro/epub_pro.dart' as epub_pro;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:lerlingua/resources/epub_viewer/epub_viewer_utils_extension.dart';

import '../event_bus.dart';
import '../file_utils/book.dart';
import '../settings.dart';

class EpubViewerController {
  late VoidCallback _onRendered;
  String log = 'PARSER LOG:\n';
  Book? _book;
  late epub_pro.EpubBook _epubBook;
  late double _parentWidgetHeight;
  final double _parentWidgetHeightCorrection = 50;
  // Read location
  late int _chapterIndex;
  late int _subChapterIndex;
  late int _currentPositionIndex;
  /// from 0 to _chapterWidgets.length
  final List<int> _pagePositionIndices = [];
  late BuildContext _context;
  List<Widget> _chapterWidgets = [];
  List<Widget> pageWidgets = [];
  static EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16.0);
  bool isPaginationInProgress = false;
  bool _paginationCancleRequested = false;
  Completer<void>? _paginationCancelRequestdCompleter;

  onRendered(VoidCallback onRendered) {
    _onRendered = onRendered;
  }

  dispose() {
    cancelPagination();
  }

  Future<void> loadBook({required BuildContext context, required double parentWidgetHeight, Book? book, required VoidCallback onRendered}) async {
    _parentWidgetHeight = parentWidgetHeight;
    _context = context;
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
    List<Widget> widgets = [];
    for (int i = 0; i < bodyElements.length; i++) {
      if (bodyElements[i].text.trim() == '') {
        if (i > 0 && bodyElements[i - 1].text.trim() == '') {
          continue; // Don't add two empty widgets in a row
        }
      }
      widgets.addAll(_domElementToWidget(bodyElements[i]));
    }
    _chapterWidgets = widgets;
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
  List<Widget> _domElementToWidget(dom.Element? element) {
    if (element == null) {
      log += 'domElementToWidget: element is null\n';
      return [];
    }
    if (element.localName == 'img') {
      List<int>? image = _epubBook.content!.images[element.attributes['src'] ?? '']?.content;
      if (image == null) return [];
      return [Image.memory(Uint8List.fromList(image))];
    }
    List<String> sentences = splitParagraphIntoSentences(_cleanText(element.text));
    List<Widget> wordWidgets = [];
    for (String sentence in sentences) {
      List<String> splitSentence = sentence.split(' ');
      for (String word in splitSentence) {
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
        wordWidgets.add(wordWidget);
      }
    }
    Widget elementWidget = Container(
      color: Colors.grey[200],
      width: double.infinity,
      child: Wrap(
        //spacing: 0, // Horizontal space between children
        //runSpacing: 4.0, // Vertical space between lines
        alignment: WrapAlignment.start,
        children: wordWidgets,
      ),
    );
    wordWidgets.add(SizedBox(height: 0, width: double.infinity));
    return wordWidgets;
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

  /// Returns widgets for next page
  Future<void> nextPage() async {
    int nextPositionIndex = _currentPositionIndex;
    if (isPaginationInProgress) {
      _currentPositionIndex = await _nextFromCurrentIndex(startIndex: _currentPositionIndex);
    } else {
      for (int i = 0; i < _pagePositionIndices.length; i++) {
        if (_pagePositionIndices[i] > _currentPositionIndex) {
          nextPositionIndex = _pagePositionIndices[i];
          break;
        }
      }
      _currentPositionIndex = nextPositionIndex;
    }
    // If _currentPositionIndex out of rage load next chapter
    if (_currentPositionIndex >= _chapterWidgets.length) {
      await _nextChapter();
    } else {
      await _renderCurrentPage();
    }
    _updateBookPosition();
  }

  /// Returns widgets for previous page
  Future<void> previousPage() async {
    int previousPositionIndex = _currentPositionIndex;
    // If _currentPositionIndex <= 0 load previous chapter
    if (_currentPositionIndex <= 0) {
      await _previousChapter();
    } else {
      if (isPaginationInProgress) {
        _currentPositionIndex = await _previousFromCurrentIndex(startIndex: _currentPositionIndex);
      } else {
        for (int i = 0; i < _pagePositionIndices.length; i++) {
          if (_pagePositionIndices[i] >= _currentPositionIndex) {
            previousPositionIndex = _pagePositionIndices[i - 1];
            break;
          }
        }
        _currentPositionIndex = previousPositionIndex;
      }
      await _renderCurrentPage();
    }
    _updateBookPosition();
  }

  /// Renders the current page
  Future<void> _renderCurrentPage() async {
    int startIndex = _currentPositionIndex;
    int nextPageStartIndex = await _nextFromCurrentIndex(startIndex: startIndex);
    List<Widget> currentPageItems = []; // Generate current page
    for (int i = startIndex; i < nextPageStartIndex; i++) {
      if (i < _chapterWidgets.length) {
        currentPageItems.add(_chapterWidgets[i]);
      }
    }
    pageWidgets = currentPageItems; // Write new current page
    _onRendered(); // Notify listeners that the page has been rendered
    _updateBookPosition();
  }

  /// Writes _pagePositionIndices from 0 to _chapterWidgets.length
  Future<void> _paginateChapter() async {
    isPaginationInProgress = true;
    // Paginate the whole chapter
    int i = 0;
    while (i < _chapterWidgets.length) {
      if (_paginationCancleRequested) { // Check if pagination process should be canceled
        _paginationCancleRequested = false;
        isPaginationInProgress = false;
        _paginationCancelRequestdCompleter?.complete();
        return;
      }
      print('_paginateChapter _chapterWidgets.length:-------------------------------------------------------------------------------------------- ${_chapterWidgets.length}');
      print('_paginateChapter i:-------------------------------------------------------------------------------------------- $i');
      _pagePositionIndices.add(i);
      i = await _nextFromCurrentIndex(startIndex: i);
      if (i >= _chapterWidgets.length) {
        _pagePositionIndices.add(i);
        break;
      }
    }
    print('pagePositionIndices: $_pagePositionIndices');
    isPaginationInProgress = false;
    _onRendered();
    return;
  }

  /// Returns height of part of chapter widgets
  Future<double> _measurePartOfChapterWidgetsHeight({required int startIndex, required int widgetsCount, required double parentWidgetHeight}) async {
    double widgetsHeightSum = 0;
    List<Widget> partOfChapterWidgets = [];
    for (int i = startIndex; i < startIndex + widgetsCount; i++) {
      partOfChapterWidgets.add(_chapterWidgets[i]);
    }
    widgetsHeightSum = await measureWidgetHeight(_context, Padding(padding: padding, child: Wrap(children: partOfChapterWidgets)));
    return widgetsHeightSum;
  }

  /// Returns next page position index from current page position index
  Future<int> _nextFromCurrentIndex({required int startIndex}) async {
    int index = startIndex;
    List<Widget> currentPageItems = [];
    double parentWidgetHeight = _parentWidgetHeight - _parentWidgetHeightCorrection;
    double widgetsHeightSum = 0;
    // Get a number of next widgets to overflow the page
    int widgetsCount = 528; // 2^x starting number
    while (widgetsHeightSum < parentWidgetHeight) {
      widgetsHeightSum = await _measurePartOfChapterWidgetsHeight(startIndex: startIndex, widgetsCount: widgetsCount, parentWidgetHeight: parentWidgetHeight);
      widgetsCount *= 2;
    }
    // widgetsCount is now bigger than window height
    // Approximate the number of widgets that fit the window
    int portion = widgetsCount;
    while (true) {
      widgetsHeightSum = await _measurePartOfChapterWidgetsHeight(startIndex: startIndex, widgetsCount: widgetsCount, parentWidgetHeight: parentWidgetHeight);
      if (portion > 1) {
        portion = portion ~/ 2;
        if (widgetsHeightSum < parentWidgetHeight) {
          widgetsCount += portion;
        } else {
          widgetsCount -= portion;
        }
      } else { // portion == 1
        if (widgetsHeightSum < parentWidgetHeight) {
          break;
        } else {
          widgetsCount -= 1;
        }
      }
    }
    int output = startIndex + widgetsCount;
    if (output > _chapterWidgets.length) {
      output = _chapterWidgets.length;
    }
    return output;
  }

  /// Returns previous page position index from current page position index
  Future<int> _previousFromCurrentIndex({required int startIndex}) async {
    int index = startIndex - 1;
    while (true) {
      if (index >= 0) {
        int nextFromThisIndex = await _nextFromCurrentIndex(startIndex: index);
        if (nextFromThisIndex <= startIndex) {
          return index;
        } else {
          index--;
        }
      } else {
        return 0;
      }
    }
  }

  Future<void> _nextChapter() async {
    bool hasSubChaptersLeft = (_epubBook.chapters[_chapterIndex].subChapters.isNotEmpty && _subChapterIndex < _epubBook.chapters[_chapterIndex].subChapters.length - 1);
    if (hasSubChaptersLeft) {
      _subChapterIndex++;
    } else if (_chapterIndex < _epubBook.chapters.length - 1) {
      _chapterIndex++;
    }
    await _loadChapter();
    _currentPositionIndex = 0;
  }

  Future<void> _previousChapter() async {
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
    await _loadChapter();
    if (oldChapterIndex != _chapterIndex || oldSubChapterIndex != _subChapterIndex) {
      _currentPositionIndex = await _previousFromCurrentIndex(startIndex: _chapterWidgets.length - 1);
    }
  }

  Future<void> cancelPagination() async {
    if (isPaginationInProgress) { // Cancel pagination if running
      _paginationCancleRequested = true;
      _paginationCancelRequestdCompleter = Completer();
      await _paginationCancelRequestdCompleter?.future;
    }
    _onRendered();
  }

  Future<void> _loadChapter() async {
    await cancelPagination();
    _createWidgets();
    _renderCurrentPage();
    _paginateChapter();
  }

}