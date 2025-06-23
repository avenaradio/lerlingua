import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/epub_viewer/epub_viewer_controller.dart';

Future<void> writeFile(String filePath, String data) async {
  final file = File(filePath);
  // create if not exists
  if (!await file.exists()) {
    await file.create(recursive: true);
  }
  await file.writeAsString(data);
}

void main() async {
  //final byteData = File('test/assets/the_little_prince_public_domain.epub').readAsBytesSync();
  //EpubBook book = await EpubReader.readBook(byteData.buffer.asUint8List()); // from assets
  EpubViewerController epubViewer = EpubViewerController();

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