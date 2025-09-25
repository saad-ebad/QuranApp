// import 'package:isar/isar.dart';
// import 'package:path_provider/path_provider.dart';
//
// import 'database_model/quran_model.dart';
//
// late Isar isar;
//
// Future<void> initDB() async {
//   final dir = await getApplicationDocumentsDirectory(); // required
//   isar = await Isar.open(
//     [SurahSchema, VerseSchema],
//     directory: dir.path,
//     inspector: true,
//   );
//
//   if (await isar.surahs.count() == 0) {
//     await isar.writeTxn(() async {
//       final surah1 = Surah()
//         ..number = 1
//         ..nameEnglish = "Al-Faatiha"
//         ..nameArabic = "الفاتحة"
//         ..totalVerses = 7;
//
//       final verses = [
//         Verse()
//           ..verseNumber = 1
//           ..arabic = "بِسْمِ اللَّهِ..."
//           ..urdu = "اللہ کے نام سے..."
//           ..english = "In the name of Allah..."
//           ..surah.value = surah1,
//       ];
//
//       await isar.surahs.put(surah1);
//       await isar.verses.putAll(verses);
//
//       surah1.verses.addAll(verses); // no await here
//       await surah1.verses.save();
//     });
//   }
// }
//
