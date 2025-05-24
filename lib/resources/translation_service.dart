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
  String getUrl(String wordB) {
    if (!url.contains('%search%')) return '';
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

  static List<TranslationService> get defaults {
    return [
      TranslationService(
          key: null,
          icon: Icons.g_translate_rounded,
          languageA: 'en',
          languageB: 'xx',
          url: 'https://translate.google.com/?sl=auto&tl=en&text=%search%',
          injectJs: '''function myFunction() {}'''
      ),
      TranslationService(
          key: null,
          icon: Icons.favorite_border_rounded,
          languageA: 'en',
          languageB: 'de',
          url: 'https://www.deepl.com/de/translator#de/en-us/%search%',
          injectJs: '''function myFunction() {}'''
      ),
      TranslationService(
          key: null,
          icon: Icons.sync_rounded,
          languageA: 'en',
          languageB: 'de',
          url: 'https://context.reverso.net/translation/german-english/%search%',
          injectJs: '''function myFunction() {}'''
      ),
    ];
  }

  /// Checks if propertys of two TranslationServices are the same
  /// - Tested
  bool equals(TranslationService other) => (languageA == other.languageA) && (languageB == other.languageB) && (url == other.url) && (injectJs == other.injectJs);

  @override
  String toString() => 'TranslationService(key: $key, icon: $icon, languageA: $languageA, languageB: $languageB, url: $url, injectJs: $injectJs)';
}