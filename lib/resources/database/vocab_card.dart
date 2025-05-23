class VocabCard {
  int vocabKey;
  String languageA;
  String wordA;
  String languageB;
  String wordB;
  String sentenceB;
  String articleB;
  String comment;
  int boxNumber;
  int timeModified;

  /// The number of parameters in the VocabCard
  static int get parametersCount => 10;

  VocabCard({
    required this.vocabKey,
    required this.languageA,
    required this.wordA,
    required this.languageB,
    required this.wordB,
    String? sentenceB,
    String? articleB,
    String? comment,
    required this.boxNumber,
    required this.timeModified,
  }) : sentenceB = sentenceB ?? '',
       articleB = articleB ?? '',
       comment = comment ?? '';

  /// Create a hard copy of the VocabCard
  VocabCard clone() {
    return VocabCard(
      vocabKey: vocabKey,
      languageA: languageA,
      wordA: wordA,
      languageB: languageB,
      wordB: wordB,
      sentenceB: sentenceB,
      articleB: articleB,
      comment: comment,
      boxNumber: boxNumber,
      timeModified: timeModified,
    );
  }

  @override
  String toString() => 'VocabCard: $vocabKey - $languageA - $wordA - $languageB - $wordB - $sentenceB - $articleB - $comment - $boxNumber - $timeModified';

  /// Converts a VocabCard to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'vocab_key': vocabKey,
      'language_a': languageA,
      'word_a': wordA,
      'language_b': languageB,
      'word_b': wordB,
      'sentence_b': sentenceB,
      'article_b': articleB,
      'comment': comment,
      'box_number': boxNumber,
      'time_modified': timeModified,
    };
  }

  /// Converts a Map to a VocabCard instance
  static VocabCard fromMap(Map<String, dynamic> map) {
    return VocabCard(
      vocabKey: map['vocab_key'] as int,
      languageA: map['language_a'] as String,
      wordA: map['word_a'] as String,
      languageB: map['language_b'] as String,
      wordB: map['word_b'] as String,
      sentenceB: map['sentence_b'] as String?,
      articleB: map['article_b'] as String?,
      comment: map['comment'] as String?,
      boxNumber: map['box_number'] as int,
      timeModified: map['time_modified'] as int,
    );
  }

  /// Converts the VocabCard instance to a CSV-formatted string.
  String toCsv() {
    // Escape fields that may contain commas or quotes
    String escape(String? value) {
      if (value == null) return '';
      String escapedValue =
          '"${value.replaceAll('"', '""')}"'; // Escape quotes by doubling them
      return escapedValue == '""' ? '' : escapedValue;
    }

    return [
      vocabKey,
      escape(languageA),
      escape(wordA),
      escape(languageB),
      escape(wordB),
      escape(sentenceB),
      escape(articleB),
      escape(comment),
      boxNumber,
      timeModified,
    ].join(',');
  }

  /// Converts a CSV-formatted string to a VocabCard instance
  static VocabCard fromCsv(String csv) {
    List<String> fieldsCommaSeparated = csv.split(',');
    List<String> fields = [];
    // Join fields starting with " but not ending with " until ending with "
    for (int i = 0; i < fieldsCommaSeparated.length; i++) {
      String field = fieldsCommaSeparated[i];
      if (field.isNotEmpty) {
        // Count the number of quotes in the field
        int quoteCount = field.split('"').length - 1;
        while (quoteCount % 2 == 1 && i < fieldsCommaSeparated.length - 1) {
          field += ',${fieldsCommaSeparated[++i]}';
          quoteCount = field.split('"').length - 1;
        }
      }
      if (field.startsWith('"') && field.endsWith('"')) {
        field = field.substring(1, field.length - 1);
      }
      field = field.replaceAll('""', '"');
      fields.add(field);
    }
    // Error handling for parsing integers
    int parseInt(String? value) {
      if (value == null) return 0;
      return int.tryParse(value) ?? 0;
    }
    return VocabCard(
      vocabKey: parseInt(fields[0]),
      languageA: fields[1],
      wordA: fields[2],
      languageB: fields[3],
      wordB: fields[4],
      sentenceB: fields[5],
      articleB: fields[6],
      comment: fields[7],
      boxNumber: parseInt(fields[8]),
      timeModified: parseInt(fields[9]),
    );
  }
}
