import 'package:epub_pro/epub_pro.dart' as epub_pro;
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'dart:typed_data';

import '../event_bus.dart';

class EpubViewer {
  String log = 'PARSER LOG:\n';
  epub_pro.EpubBook epubBook;
  int _chapterIndex;
  int _subChapterIndex;
  int _positionIndex;

  /// Reading position: chapter/subChapter/position
  EpubViewer({required this.epubBook, required String readingPosition}) : _chapterIndex = int.parse(readingPosition.split('/')[0]), _subChapterIndex = int.parse(readingPosition.split('/')[1]), _positionIndex = int.parse(readingPosition.split('/')[2]);

  List<Widget> elements() {
    if (epubBook.content != null) {
      //for (var image in epubBook.content!.images) {}
    }
    log += 'chapters count: ${epubBook.chapters.length}\n';
    log += 'chapterIndex: $_chapterIndex\n';
    log += 'subchapters count: ${epubBook.chapters[_chapterIndex].subChapters.length}\n';
    dom.Element? body = chapterBody();
    List<dom.Element> bodyElements = elementList(body, 'div');
    for (dom.Element element in bodyElements) {
      log += '${element.outerHtml}\n';
    }
    List<Widget> widgets = [];
    for (dom.Element element in bodyElements) {
      widgets.add(domElementToWidget(element));
    }
    return widgets;
  }

  /// Converts html into dom elements
  dom.Element? chapterBody() {
    String? html;
    for (int i = 0; i < epubBook.chapters.length; i++) {
      if (i == _chapterIndex) {
        bool hasSubChapters = epubBook.chapters[i].subChapters.isNotEmpty;
        if (hasSubChapters) {
          for (int j = 0; j < epubBook.chapters[i].subChapters.length; j++) {
            if (j == _subChapterIndex) {
              html = epubBook.chapters[i].subChapters[j].htmlContent;
            }
          }
        }else {
          html = epubBook.chapters[i].htmlContent;
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
  List<dom.Element> elementList(dom.Element? element, String? parentTag) {
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
          List<dom.Element> childElements = elementList(node, nodeTag);
          elements.addAll(childElements);
        } else if (nodeTag == 'img') { // If img, add
          elements.add(node);
        } else { // If other, add and add img if present
          dom.Element noRecursiveElement = dom.Document().createElement(nodeTag);
          noRecursiveElement.innerHtml = node.text.trim();
          elements.add(noRecursiveElement);
          List<dom.Element> imgElements = imgFromElement(node);
          elements.addAll(imgElements);
        }
      }
    }
    return elements;
  }

  /// Returns all img elements from an element
  List<dom.Element> imgFromElement(dom.Element? element) {
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

  /// Returns Widget from dom element
  Widget domElementToWidget(dom.Element? element) {
    if (element == null) {
      log += 'domElementToWidget: element is null\n';
      return Container();
    }
    if (element.localName == 'img') {
      List<int>? image = epubBook.content!.images[element.attributes['src'] ?? '']?.content;
      if (image == null) return Container();
      return Image.memory(Uint8List.fromList(image));
    }
    List<String> sentences = splitParagraphIntoSentences(cleanText(element.text));
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
    Widget elementWidget = SizedBox(
      width: double.infinity,
      child: Wrap(
        //spacing: 0, // Horizontal space between children
        //runSpacing: 4.0, // Vertical space between lines
        alignment: WrapAlignment.start,
        children: wordWidgets,
      ),
    );
    return elementWidget;
  }

  /// Cleans text
  String cleanText(String text) {
    text.replaceAll(RegExp(r'\s+'), ' ');
    text.replaceAll(RegExp(r'\s+'), ' ');
    text = text.trim();
    return text;
  }

  /// Splits a paragraph into sentences
  /// - Tested
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


}