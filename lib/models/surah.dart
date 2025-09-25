class VerseModel {
  final int number;
  final String arabic;
  final String urdu;
  String? localAudioPath; // 🔥 add this

  VerseModel({
    required this.number,
    required this.arabic,
    required this.urdu,
    this.localAudioPath, // 🔥 make it optional in constructor
  });
}

class SurahModel {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final int totalVerses;
  final String revelationType;
  final List<VerseModel> verses;

  SurahModel({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.totalVerses,
    required this.revelationType,
    required this.verses,
  });
}
