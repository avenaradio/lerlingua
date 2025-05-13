class VocabEntry {
  int vocabKey;
  String languageA;
  String wordA;
  String languageB;
  String wordB;
  String? sentenceB;
  String? articleB;
  String? comment;
  int? boxNumber;
  int timeLearned;
  int timeModified;

  VocabEntry({
    required this.vocabKey,
    required this.languageA,
    required this.wordA,
    required this.languageB,
    required this.wordB,
    this.sentenceB,
    this.articleB,
    this.comment,
    this.boxNumber,
    required this.timeLearned,
    required this.timeModified});

  // Clone method
  VocabEntry clone() {
    return VocabEntry(
      vocabKey: vocabKey,
      languageA: languageA,
      wordA: wordA,
      languageB: languageB,
      wordB: wordB,
      sentenceB: sentenceB,
      articleB: articleB,
      comment: comment,
      boxNumber: boxNumber,
      timeLearned: timeLearned,
      timeModified: timeModified,
    );
  }

  // Convert VocabEntry to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'vocab_key': vocabKey == 0 ? null : vocabKey,
      'language_a': languageA,
      'word_a': wordA,
      'language_b': languageB,
      'word_b': wordB,
      'sentence_b': sentenceB,
      'article_b': articleB,
      'comment': comment,
      'box_number': boxNumber,
      'time_learned': timeLearned,
      'time_modified': timeModified,
    };
  }

  // Converts a Map to a VocabEntry instance
  static VocabEntry fromMap(Map<String, dynamic> map) {
    return VocabEntry(
      vocabKey: map['vocab_key'] as int,
      languageA: map['language_a'] as String,
      wordA: map['word_a'] as String,
      languageB: map['language_b'] as String,
      wordB: map['word_b'] as String,
      sentenceB: map['sentence_b'] as String?,
      articleB: map['article_b'] as String?,
      comment: map['comment'] as String?,
      boxNumber: map['box_number'] as int?,
      timeLearned: map['time_learned'] as int,
      timeModified: map['time_modified'] as int,
    );
  }
}