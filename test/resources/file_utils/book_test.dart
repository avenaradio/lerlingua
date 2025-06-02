import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/file_utils/book.dart';

void main() {
  test('book creation', () {
    Book book1 = Book(
        key: null,
        path: 'path',
        languageB: 'languageB',
        readingLocation: 'readingLocation',
        title: 'title',
        author: 'author',
        lastReadTime: null);

    Book book2 = Book(
        key: 1,
        path: 'path',
        languageB: 'languageB',
        readingLocation: 'readingLocation',
        title: 'title',
        author: 'author',
        lastReadTime: 1);

    expect(book1.key, greaterThan(1748360697477));
    expect(book1.path, 'path');
    expect(book1.languageB, 'languageB');
    expect(book1.readingLocation, 'readingLocation');
    expect(book1.title, 'title');
    expect(book1.author, 'author');
    expect(book1.lastReadTime, greaterThan(1748360697477));

    expect(book2.key, 1);
    expect(book2.lastReadTime, 1);
  });
  test('toMap', () async {
    Book book1 = Book(
        key: 1,
        path: 'path',
        languageB: 'languageB',
        readingLocation: 'readingLocation',
        title: 'title',
        author: 'author',
        lastReadTime: 1,
        cover: Uint8List(1));
    Map<String, dynamic> map = book1.toMap();
    expect(map['key'], 1);
    expect(map['path'], 'path');
    expect(map['languageB'], 'languageB');
    expect(map['readingLocation'], 'readingLocation');
    expect(map['title'], 'title');
    expect(map['author'], 'author');
    expect(map['lastReadTime'], 1);
    expect(map['cover'], Uint8List(1));
  });
  test('fromMap', () async {
    Book book1 = Book.fromMap({
      'key': 1,
      'path': 'path',
      'languageB': 'languageB',
      'readingLocation': 'readingLocation',
      'title': 'title',
      'author': 'author',
      'lastReadTime': 1,
      'cover': Uint8List(1)
    });
    expect(book1.key, 1);
    expect(book1.path, 'path');
    expect(book1.languageB, 'languageB');
    expect(book1.readingLocation, 'readingLocation');
    expect(book1.title, 'title');
    expect(book1.author, 'author');
    expect(book1.lastReadTime, 1);
    expect(book1.cover, Uint8List(1));
  });
  test('equals', () async {
    Book book1 = Book(
        key: 1,
        path: 'path',
        languageB: 'languageB',
        readingLocation: 'readingLocation',
        title: 'title',
        author: 'author',
        lastReadTime: 1);
    Book book2 = Book(
        key: 1,
        path: 'path',
        languageB: 'languageB',
        readingLocation: 'readingLocation',
        title: 'title',
        author: 'author',
        lastReadTime: 1);
    Book book3 = Book(
        key: 2,
        path: 'path',
        languageB: 'languageB',
        readingLocation: 'readingLocation',
        title: 'title',
        author: 'author',
        lastReadTime: 1,
        cover: Uint8List(1));
    expect(book1.equals(book2), true);
    expect(book1.equals(book3), true);
  });
}