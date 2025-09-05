import 'package:flutter/material.dart';

enum TranslationDirection {
  aToB,
  bToA,
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
    String url = direction == TranslationDirection.aToB ? urlAtoB : urlBtoA;
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
          function waitForText(className, callback) {
            var interval = setInterval(function() {
              var element = document.getElementsByClassName(className)[0];
              if (element && element.textContent.trim() !== '') {
                clearInterval(interval);
                callback(element.textContent);
              }
            }, 100); // Check every 100 milliseconds
          }
          try {
            document.body.style.zoom = '75%';
          } catch (e) {
            console.log(e);
          }
          // First element with class will be removed.
          var classNames = ['pGxpHc', 'VjFXz', 'hgbeOc EjH7wc', 'VlPnLc', 'cJ1Ndf'];
          // For each class name in classNames remove elemen
          try {
            classNames.forEach(function(className) {
            var elements = document.getElementsByClassName(className)[0];
            elements.remove();
          })
          } catch (e) {
            console.log(e);
          }
          try {
            window.scrollTo(0, document.body.scrollHeight);
          } catch (e) {
            console.log(e);
          }
          try {
            console.log('Waiting for text...');
            waitForText('ryNqvb', function(text) {
              console.log('Element has text:', text);
              var textElement = document.getElementsByClassName('ryNqvb')[0];
              var range = document.createRange();
              range.selectNodeContents(textElement);
              window.getSelection().removeAllRanges();
              window.getSelection().addRange(range);
              window.flutter_inappwebview.callHandler('showContextMenu', 'selection info');

            });
          } catch (e) {
            console.log('Wait for text error:', e);
          }
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
