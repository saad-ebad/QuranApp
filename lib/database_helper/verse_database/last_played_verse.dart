import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/last_played_verse.dart';
import 'last_played_verse.dart';

class LastPlayedDb {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'last_played.db');

    return await openDatabase(
      path,
      version: 3, // bump version
      onCreate: (db, version) async {
        await db.execute('''
    CREATE TABLE last_played (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      surahId INTEGER,
      surahName TEXT,
      verseNumber INTEGER,
      verseCount INTEGER,
      arabicText TEXT,
      urduText TEXT,
      surahNameArabic TEXT
    )
  ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE last_played ADD COLUMN arabicText TEXT");
          await db.execute("ALTER TABLE last_played ADD COLUMN urduText TEXT");
        }
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE last_played ADD COLUMN surahNameArabic TEXT");
        }
      },
    );

  }


  static Future<void> saveLastPlayed(LastPlayedVerse verse) async {
    final db = await database;
    // Only one record at a time, so clear table first
    await db.delete('last_played');
    await db.insert('last_played', verse.toMap());
  }

  static Future<LastPlayedVerse?> getLastPlayed() async {
    final db = await database;
    final result = await db.query('last_played', limit: 1);
    if (result.isNotEmpty) {
      return LastPlayedVerse.fromMap(result.first);
    }
    return null;
  }
}
