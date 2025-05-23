import 'package:flutter/material.dart';

class TranslationService {
  int key;
  String languageA;
  String languageB;
  String url;
  String injectJs;
  IconData icon;

  TranslationService({int? key, required this.icon, required this.languageA, required this.languageB, required this.url, String? injectJs}) : injectJs = injectJs ?? '', key = key ?? DateTime.now().millisecondsSinceEpoch;

  /// Returns the URL for the given word
  /// - Tested
  getUrl(String wordB) {
    return url.replaceAll('%search%', wordB).replaceAll(' ', '%20');
  }

  /// Converts a VocabCard to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'icon': icon.codePoint,
      'languageA': languageA,
      'languageB': languageB,
      'url': url,
      'injectJs': injectJs,
    };
  }

  /// Converts a Map to a VocabCard instance
  factory TranslationService.fromMap(Map<String, dynamic> map) {
    return TranslationService(
      key: map['key'] as int,
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      languageA: map['languageA'] as String,
      languageB: map['languageB'] as String,
      url: map['url'] as String,
      injectJs: map['injectJs'] as String,
    );
  }
}