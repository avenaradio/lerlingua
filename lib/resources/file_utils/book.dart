import 'dart:io';
import 'package:epub_pro/epub_pro.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:lerlingua/resources/file_utils/file_handler.dart';
import 'package:lerlingua/resources/settings/settings.dart';

class Book {
  int key;
  String path;
  String languageB;
  String readingLocation;
  String title;
  String author;
  int lastReadTime;
  Uint8List? cover;

  Book({
    int? key,
    required this.path,
    required this.languageB,
    required this.readingLocation,
    required this.title,
    required this.author,
    this.cover,
    int? lastReadTime,
  }) : key = key ?? DateTime.now().millisecondsSinceEpoch,
        lastReadTime = lastReadTime ?? DateTime.now().millisecondsSinceEpoch;

  /// Converts a VocabCard to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'path': path,
      'languageB': languageB,
      'readingLocation': readingLocation,
      'title': title,
      'author': author,
      'lastReadTime': lastReadTime,
      'cover': cover,
    };
  }

  /// Converts a Map to a VocabCard instance
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      key: map['key'] as int,
      path: map['path'] as String,
      languageB: map['languageB'] as String,
      readingLocation: map['readingLocation'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      lastReadTime: map['lastReadTime'] as int,
      cover: Uint8List.fromList(map['cover'].cast<int>()),
    );
  }

  /// Checks if properties of two Books are the same
  /// - Tested
  bool equals(Book other) =>
          (path == other.path) &&
          (languageB == other.languageB) &&
          (readingLocation == other.readingLocation) &&
          (title == other.title) &&
          (author == other.author);

  /// Imports an epub file and returns a Book
  static Future<Book?> importBook() async {
    File? copiedFile = await FileHandler.importEpubFile();
    if (copiedFile == null) return null;
    List<int> bytes = await copiedFile.readAsBytes();
    EpubBook epubBook = await EpubReader.readBook(bytes); // Read the EPUB file
    return Book(path: copiedFile.path, languageB: '', readingLocation: '', title: epubBook.title ?? '', author: epubBook.authors.join(', '), cover: compressImage(epubBook.coverImage));
  }

  /// Compresses cover image and returns it as Uint8List
  static Uint8List? compressImage(Image? image) {
    if (image == null) return null;
    // Encode the resized image to JPG format
    final Uint8List compressedImage = Uint8List.fromList(encodeJpg(image, quality: 10));
    if(kDebugMode) {
      print('Image size: ${compressedImage.length ~/ 1024}kB');
    }
    return compressedImage;
  }

  /// Deletes a book from the app's document directory
  Future<void> deleteBook() async {
    await FileHandler.deleteFile(filePath: path);
    Settings().deleteBook(this);
  }


  @override
  String toString() =>
      'Book(key: $key, path: $path, languageB: $languageB, readingLocation: $readingLocation, title: $title, author: $author, lastReadTime: $lastReadTime)';
}
