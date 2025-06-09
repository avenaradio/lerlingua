import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/general/string_extension.dart';

void main() {
  test('string extension capitalizeFirst', () {
    String test = "test";
    test = test.capitalizeFirst();
    expect(test, "Test");
  });
  test('trimNonAlphanumeric', () {
    String test1 = "test123";
    String test2 = "123test";
    String test3 = "-#test123. ";
    String test4 = "//123test";
    String test5 = "123test-#";
    String test6 = "test-#\n";
    String test7 = " test-#";
    String test8 = "test-#!";
    String test9 = "";
    String test10 = "+-'";
    expect(test1.trimNonAlphanumeric(), "test123");
    expect(test2.trimNonAlphanumeric(), "123test");
    expect(test3.trimNonAlphanumeric(), "test123");
    expect(test4.trimNonAlphanumeric(), "123test");
    expect(test5.trimNonAlphanumeric(), "123test");
    expect(test6.trimNonAlphanumeric(), "test");
    expect(test7.trimNonAlphanumeric(), "test");
    expect(test8.trimNonAlphanumeric(), "test");
    expect(test9.trimNonAlphanumeric(), "");
    expect(test10.trimNonAlphanumeric(), "+-'");
    expect('testé'.trimNonAlphanumeric(), 'testé');
    expect('!ひらがな '.trimNonAlphanumeric(), 'ひらがな');
  });
}