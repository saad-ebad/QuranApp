class LastPlayedVerse {
  final int surahId;
  final String surahName;
  final int verseNumber;
  final int verseCount;
  final String? arabicText;
  final String? urduText;
  final String? surahNameArabic;

  LastPlayedVerse({
    required this.surahId,
    required this.surahName,
    required this.verseNumber,
    required this.verseCount,
    this.arabicText,
    this.urduText,
    this.surahNameArabic
  });

  Map<String, dynamic> toMap() {
    return {
      'surahId': surahId,
      'surahName': surahName,
      'verseNumber': verseNumber,
      'verseCount': verseCount,
      'arabicText': arabicText,
      'urduText': urduText,
      'surahNameArabic': surahNameArabic,
    };
  }

  factory LastPlayedVerse.fromMap(Map<String, dynamic> map) {
    return LastPlayedVerse(
      surahId: map['surahId'],
      surahName: map['surahName'],
      verseNumber: (map['verseNumber'] ?? 0) as int,
      verseCount: (map['verseCount'] ?? 0) as int,
      arabicText: map['arabicText'],
      urduText: map['urduText'],
      surahNameArabic: map['surahNameArabic'],
    );
  }
}
