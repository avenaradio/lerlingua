import 'dart:io';
import 'package:epub_pro/epub_pro.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/file_utils/epub_parser.dart';

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
  EpubParser parser = EpubParser(epubBook: book, chapterIndex: 1, positionIndex: 0);

  group('EpubParser Tests', () {
    test('should parse epub', () {
      //writeFile('test/output/chapterOuterHtml.txt', parser.chapterHtml());
      //writeFile('test/output/chapterText.txt', parser.chapterText());
      parser.elements();
      print(parser.log);
    });
  });
}