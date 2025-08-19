// test for translationService

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/translation_service.dart';

void main() {
  test('translationService', () async {
    TranslationService translationService = TranslationService(icon: Icons.translate, languageA: 'en', languageB: 'es', urlAtoB: 'https://translate.google.de/?sl=auto&tl=en&text=%search%', urlBtoA: 'https://translate.google.de/?sl=auto&tl=es&text=%search%', injectJs: '''function myFunction() {}''');
    expect(translationService.key, greaterThan(1748022170025));
    expect(translationService.icon, Icons.translate);
    expect(translationService.languageA, 'en');
    expect(translationService.languageB, 'es');
    expect(translationService.urlAtoB, 'https://translate.google.de/?sl=auto&tl=en&text=%search%');
    expect(translationService.urlBtoA, 'https://translate.google.de/?sl=auto&tl=es&text=%search%');
    expect(translationService.injectJs, '''function myFunction() {}''');
    expect(translationService.getUrl('test word', TranslationDirection.AtoB), 'https://translate.google.de/?sl=auto&tl=en&text=test%20word');
    expect(translationService.getUrl('test word', TranslationDirection.BtoA), 'https://translate.google.de/?sl=auto&tl=es&text=test%20word');
    expect(translationService.getUrl('%search test word', TranslationDirection.AtoB), 'https://translate.google.de/?sl=auto&tl=en&text=%search%20test%20word');
    expect(translationService.getUrl('%search test word', TranslationDirection.BtoA), 'https://translate.google.de/?sl=auto&tl=es&text=%search%20test%20word');
  });
  test('getUrl should return empty string if no %search% contained', () async {
    TranslationService translationService = TranslationService(icon: Icons.translate, languageA: 'en', languageB: 'es', urlAtoB: 'https://translate.google.de/?sl=auto&tl=en&text=', urlBtoA: 'https://translate.google.de/?sl=auto&tl=es&text=', injectJs: '''function myFunction() {}''');
    expect(translationService.getUrl('test word', TranslationDirection.AtoB), '');
    expect(translationService.getUrl('test word', TranslationDirection.BtoA), '');
  });
  test('toMap', () async {
    TranslationService translationService = TranslationService(key: 1, icon: Icons.translate, languageA: 'en', languageB: 'es', urlAtoB: 'https://translate.google.de/?sl=auto&tl=en&text=%search%', urlBtoA: 'https://translate.google.de/?sl=auto&tl=es&text=%search%', injectJs: '''function myFunction() {}''');
    expect(translationService.toMap(), {'key': 1, 'icon': 59003, 'languageA': 'en', 'languageB': 'es', 'urlAtoB': 'https://translate.google.de/?sl=auto&tl=en&text=%search%', 'urlBtoA': 'https://translate.google.de/?sl=auto&tl=es&text=%search%', 'injectJs': '''function myFunction() {}'''});
  });
  test('fromMap', () async {
    TranslationService translationService = TranslationService.fromMap({'key': 1, 'icon': 59003, 'languageA': 'en', 'languageB': 'es', 'urlAtoB': 'https://translate.google.de/?sl=auto&tl=en&text=%search%', 'urlBtoA': 'https://translate.google.de/?sl=auto&tl=es&text=%search%', 'injectJs': '''function myFunction() {}'''});
    expect(translationService.key, 1);
    expect(translationService.icon, Icons.translate);
    expect(translationService.languageA, 'en');
    expect(translationService.languageB, 'es');
    expect(translationService.urlAtoB, 'https://translate.google.de/?sl=auto&tl=en&text=%search%');
    expect(translationService.urlBtoA, 'https://translate.google.de/?sl=auto&tl=es&text=%search%');
    expect(translationService.injectJs, '''function myFunction() {}''');
  });
  test('check if same propertys', () async {
    TranslationService translationService1 = TranslationService(icon: Icons.translate, languageA: 'a', languageB: 'b', urlAtoB: 'c', urlBtoA: 'e', injectJs: 'd');
    TranslationService translationService2 = TranslationService(icon: Icons.translate, languageA: 'a', languageB: 'b', urlAtoB: 'c', urlBtoA: 'e', injectJs: 'd');
    expect(translationService1.equals(translationService2), true);

    translationService2 = TranslationService(icon: Icons.translate, languageA: 'a', languageB: 'b', urlAtoB: 'c', urlBtoA: 'e', injectJs: 'e');
    expect(translationService1.equals(translationService2), false);
  });
}