extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }

  String trimNonAlphanumeric() {
    if (isEmpty) {
      return this;
    }
    final pattern = RegExp(r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$', unicode: true);
    final trimmed = replaceAll(pattern, '');
    if (trimmed.isEmpty) {
      return this;
    }
    return trimmed;
  }
}
