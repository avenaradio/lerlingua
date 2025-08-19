import 'package:flutter/material.dart';

enum TranslationDirection {
  AtoB,
  BtoA,
}

class TranslationService {
  int key;
  String languageA;
  String languageB;
  String urlAtoB;
  String urlBtoA;
  String injectJs;
  IconData icon;

  TranslationService({
    int? key,
    required this.icon,
    required this.languageA,
    required this.languageB,
    required this.urlAtoB,
    required this.urlBtoA,
    String? injectJs,
  }) : injectJs = injectJs ?? '',
       key = key ?? DateTime.now().millisecondsSinceEpoch;

  /// Returns the URL for the given word
  /// - Tested
  String getUrl(String wordB, TranslationDirection direction) {
    String url = direction == TranslationDirection.AtoB ? urlAtoB : urlBtoA;
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
      'urlAtoB': urlAtoB,
      'urlBtoA': urlBtoA,
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
      urlAtoB: map['urlAtoB'] as String,
      urlBtoA: map['urlBtoA'] as String,
      injectJs: map['injectJs'] as String,
    );
  }

  /// Returns the default TranslationServices
  static List<TranslationService> get defaults {
    return [
      TranslationService(
          key: 1,
          icon: Icons.g_translate_rounded,
          languageA: 'DE',
          languageB: 'ES',
          urlAtoB: 'https://translate.google.com/?sl=de&tl=es&text=%search%',
          urlBtoA: 'https://translate.google.com/?sl=es&tl=de&text=%search%',
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
    ];
  }

  /// Checks if properties of two TranslationServices are the same
  /// - Tested
  bool equals(TranslationService other) =>
      (languageA == other.languageA) &&
      (languageB == other.languageB) &&
      (urlAtoB == other.urlAtoB) &&
      (urlBtoA == other.urlBtoA) &&
      (injectJs == other.injectJs);

  @override
  String toString() =>
      'TranslationService(key: $key, icon: $icon, languageA: $languageA, languageB: $languageB, urlAtoB: $urlAtoB, urlBtoA: $urlBtoA, injectJs: $injectJs)';
}
