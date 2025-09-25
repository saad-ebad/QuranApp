import 'package:share_plus/share_plus.dart';

class UtilityFunctions {
  /// Share one or multiple verses
  /// Each verse map should contain:
  /// { "surahName": String, "verseNumber": int, "arabic": String, "urdu": String }
  static void shareVerses({
    required String surahName,
    required List<Map<String, dynamic>> verses,
  }) {
    if (verses.isEmpty) return;

    final buffer = StringBuffer();

    buffer.writeln("📖 Surah: $surahName\n");

    for (final verse in verses) {
      final num = verse["verseNumber"];
      final arabic = verse["arabic"] ?? "";
      final urdu = verse["urdu"] ?? "";

      buffer.writeln("🔹 Ayah $num");
      buffer.writeln(arabic);
      buffer.writeln(urdu);
      buffer.writeln(""); // spacing
    }

    Share.share(buffer.toString().trim());
  }
}