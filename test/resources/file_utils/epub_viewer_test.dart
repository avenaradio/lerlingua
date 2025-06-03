import 'dart:io';
import 'package:epub_pro/epub_pro.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/file_utils/epub_viewer.dart';

Future<void> writeFile(String filePath, String data) async {
  final file = File(filePath);
  // create if not exists
  if (!await file.exists()) {
    await file.create(recursive: true);
  }
  await file.writeAsString(data);
}

void main() async {
  final byteData = File('test/assets/test.epub').readAsBytesSync();
  EpubBook book = await EpubReader.readBook(byteData.buffer.asUint8List()); // from assets
  EpubViewer epubViewer = EpubViewer(epubBook: book, readingPosition: '0/0/0');

  group('EpubParser Tests', () {
    test('should parse epub', () {
      //writeFile('test/output/chapterOuterHtml.txt', epubViewer.chapterHtml());
      //writeFile('test/output/chapterText.txt', epubViewer.chapterText());
      //epubViewer.elements();
      //print('\n${epubViewer.log}');
      //print('test done');
    });
  });
  test('split paragraph into sentences', () {
    String paragraph = 'Hello. How are you? I am coding... too much! Thanks... Bananas: 🍌. 100%';
    List<String> sentences = epubViewer.splitParagraphIntoSentences(paragraph);
    expect(sentences, ['Hello.', 'How are you?', 'I am coding... too much!', 'Thanks...', 'Bananas: 🍌.', '100%']);
  });
}