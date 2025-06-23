import 'package:flutter/material.dart';

class TranslationService {
  int key;
  String languageA;
  String languageB;
  String url;
  String injectJs;
  IconData icon;

  TranslationService({
    int? key,
    required this.icon,
    required this.languageA,
    required this.languageB,
    required this.url,
    String? injectJs,
  }) : injectJs = injectJs ?? '',
       key = key ?? DateTime.now().millisecondsSinceEpoch;

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

  /// Returns the default TranslationServices
  static List<TranslationService> get defaults {
    return [
      TranslationService(
        key: 1,
        icon: Icons.g_translate_rounded,
        languageA: 'EN',
        languageB: 'XX',
        url: 'https://translate.google.com/?sl=auto&tl=en&text=%search%',
        injectJs: '''
  document.body.style.zoom = '75%';
  // First element with class will be removed.
  var classNames = ['pGxpHc', 'VjFXz', 'hgbeOc EjH7wc', 'VlPnLc', 'cJ1Ndf'];
  // For each class name in classNames remove elemen
  classNames.forEach(function(className) {
    var elements = document.getElementsByClassName(className)[0];
    elements.remove();
  })
  window.scrollTo(0, document.body.scrollHeight);
  '''
      ),
      TranslationService(
          key: 2,
          icon: Icons.g_translate_rounded,
          languageA: 'EN',
          languageB: 'DE',
          url: 'https://translate.google.com/?sl=de&tl=en&text=%search%',
          injectJs: '''
  document.body.style.zoom = '75%';
  // First element with class will be removed.
  var classNames = ['pGxpHc', 'VjFXz', 'hgbeOc EjH7wc', 'VlPnLc', 'cJ1Ndf'];
  // For each class name in classNames remove elemen
  classNames.forEach(function(className) {
    var elements = document.getElementsByClassName(className)[0];
    elements.remove();
  })
  window.scrollTo(0, document.body.scrollHeight);
  '''
      ),
      TranslationService(
        key: 3,
        icon: Icons.sync_rounded,
        languageA: 'EN',
        languageB: 'DE',
        url: 'https://context.reverso.net/translation/german-english/%search%',
        injectJs: '''document.body.style.zoom = '75%';''',
      ),
    ];
  }

  /// Checks if properties of two TranslationServices are the same
  /// - Tested
  bool equals(TranslationService other) =>
      (languageA == other.languageA) &&
      (languageB == other.languageB) &&
      (url == other.url) &&
      (injectJs == other.injectJs);

  @override
  String toString() =>
      'TranslationService(key: $key, icon: $icon, languageA: $languageA, languageB: $languageB, url: $url, injectJs: $injectJs)';
}
