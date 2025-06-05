import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/general/string_extension.dart';

void main() {
  test('string extension capitalizeFirst', () {
    String test = "test";
    test = test.capitalizeFirst();
    expect(test, "Test");
  });
  test('trim alphanumeric', () {
    
  });
}