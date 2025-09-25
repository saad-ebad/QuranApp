import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



class AudioDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quran_audio.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE audio_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            surahId INTEGER,
            verseNumber INTEGER,
            filePath TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertAudio(
      int surahId, int verseNumber, String filePath) async {
    final db = await database;
    await db.insert(
      'audio_cache',
      {
        'surahId': surahId,
        'verseNumber': verseNumber,
        'filePath': filePath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getAudioPath(int surahId, int verseNumber) async {
    final db = await database;
    final res = await db.query(
      'audio_cache',
      where: 'surahId = ? AND verseNumber = ?',
      whereArgs: [surahId, verseNumber],
      limit: 1,
    );
    if (res.isNotEmpty) {
      return res.first['filePath'] as String;
    }
    return null;
  }

  /// 🔥 New method: batch fetch all audio for a Surah
  static Future<Map<int, String>> getAllAudiosForSurah(int surahId) async {
    final db = await database;
    final res = await db.query(
      'audio_cache',
      where: 'surahId = ?',
      whereArgs: [surahId],
    );

    final Map<int, String> audioMap = {};
    for (var row in res) {
      audioMap[row['verseNumber'] as int] = row['filePath'] as String;
    }
    return audioMap;
  }
}

