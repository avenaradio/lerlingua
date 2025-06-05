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
    String trimmed = replaceAll(RegExp(r'^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$'), '');
    if (trimmed.isEmpty) {
      return this;
    }
    return trimmed;
  }
}
