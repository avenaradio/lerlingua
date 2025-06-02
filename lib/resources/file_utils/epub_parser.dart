import 'package:epub_pro/epub_pro.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class EpubParser {
  String log = 'PARSER LOG:\n';
  EpubBook epubBook;
  int chapterIndex;
  int positionIndex;

  EpubParser({required this.epubBook, required this.chapterIndex, required this.positionIndex});

  /// Returns the html content of the current chapter
  String? chapterHtml() {
    for (int i = 0; i < epubBook.chapters.length; i++) {
      if (i == chapterIndex) {
        return epubBook.chapters[i].htmlContent ?? '';
      }
    }
    return null;
  }

  /// Converts html into dom elements
  dom.Element? chapterBody() {
    String? html = chapterHtml();
    if (html == null) {
      log += 'chapterHtml is null\n';
      return null;
    }
    dom.Document document = html_parser.parse(html);
    return document.body;
  }

  void elements() {
    dom.Element? body = chapterBody();
    List<dom.Element> bodyElements = elementList(body);
    for (dom.Element element in bodyElements) {
      //print(element.outerHtml);
    }
  }

  List<dom.Element> elementList(dom.Element? element) {
    List<dom.Element> elements = [];
    if (element == null) {
      log += 'element is null\n';
      return elements;
    }
    List<dom.Element> children = element.children;
    String? elementHtml = element.innerHtml;
    bool hasChildren = children.isNotEmpty;
    String? firstText = '';
    if (hasChildren) {
      firstText = elementHtml.split(children.first.outerHtml).first.replaceAll('\n', ' ').trim(); // TOFO \n replacement correct?
    } else {
      firstText = elementHtml.replaceAll('\n', ' ').trim();
    }
    print(element.parentNode?.text ?? 'NULL');
    dom.Element? firstTextElement = dom.Document().createElement('div'); // TODO USE parent element tag
    if (firstText != '') {
      firstTextElement.innerHtml = firstText;
      elements.add(firstTextElement);
    }
    if (hasChildren) {
      ///////////////////////////////////////////// TODO DONT PROCESS ALL TAGS
      // Process first child
      List<dom.Element> childElements = elementList(children.first);
      elements.addAll(childElements);
      // Process rest
      String? afterFirstChildHtml = elementHtml.split(children.first.outerHtml).last;
      if (afterFirstChildHtml != '') {
        dom.Element? afterFirstChildDiv = dom.Document().createElement('div');  // TODO USE parent element tag
        afterFirstChildDiv.innerHtml = afterFirstChildHtml;
        List<dom.Element> afterFirstChildElements = elementList(afterFirstChildDiv);
        elements.addAll(afterFirstChildElements);
      }
    }
    return elements;
  }

}