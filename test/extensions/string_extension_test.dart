import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/extensions/string_extension.dart';

Future main() async {
  test('string extension capitalizeFirst', () async {
    String test = "test";
    test = test.capitalizeFirst();
    expect(test, "Test");
  });
}