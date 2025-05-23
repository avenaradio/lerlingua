// test for TranslationHandler

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/translation_service.dart';

void main() {
  test('TranslationHandler', () async {
    TranslationService translationHandler = TranslationService(icon: Icons.translate, languageA: 'en', languageB: 'es', url: 'https://translate.google.de/?sl=auto&tl=en&text=%search%', injectJs: '''function myFunction() {}''');
    expect(translationHandler.key, greaterThan(1748022170025));
    expect(translationHandler.icon, Icons.translate);
    expect(translationHandler.languageA, 'en');
    expect(translationHandler.languageB, 'es');
    expect(translationHandler.url, 'https://translate.google.de/?sl=auto&tl=en&text=%search%');
    expect(translationHandler.injectJs, '''function myFunction() {}''');
    expect(translationHandler.getUrl('test word'), 'https://translate.google.de/?sl=auto&tl=en&text=test%20word');
    expect(translationHandler.getUrl('%search test word'), 'https://translate.google.de/?sl=auto&tl=en&text=%search%20test%20word');
  });
  test('toMap', () async {
    TranslationService translationHandler = TranslationService(key: 1, icon: Icons.translate, languageA: 'en', languageB: 'es', url: 'https://translate.google.de/?sl=auto&tl=en&text=%search%', injectJs: '''function myFunction() {}''');
    expect(translationHandler.toMap(), {'key': 1, 'icon': 59003, 'languageA': 'en', 'languageB': 'es', 'url': 'https://translate.google.de/?sl=auto&tl=en&text=%search%', 'injectJs': '''function myFunction() {}'''});
  });
  test('fromMap', () async {
    TranslationService translationHandler = TranslationService.fromMap({'key': 1, 'icon': 59003, 'languageA': 'en', 'languageB': 'es', 'url': 'https://translate.google.de/?sl=auto&tl=en&text=%search%', 'injectJs': '''function myFunction() {}'''});
    expect(translationHandler.key, 1);
    expect(translationHandler.icon, Icons.translate);
    expect(translationHandler.languageA, 'en');
    expect(translationHandler.languageB, 'es');
    expect(translationHandler.url, 'https://translate.google.de/?sl=auto&tl=en&text=%search%');
    expect(translationHandler.injectJs, '''function myFunction() {}''');
  });
}