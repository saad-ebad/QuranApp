import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BookmarkDatabase {
  static final BookmarkDatabase instance = BookmarkDatabase._init();
  static Database? _database;

  BookmarkDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bookmark.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE bookmarks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      surahId INTEGER NOT NULL,
      title TEXT NOT NULL,
      titleAr TEXT NOT NULL,
      type TEXT,
      count INTEGER
    )
    ''');
  }

  // Insert
  Future<int> addBookmark(Map<String, dynamic> surah) async {
    final db = await instance.database;
    return await db.insert("bookmarks", surah,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all
  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await instance.database;
    return await db.query("bookmarks", orderBy: "surahId ASC");
  }

  // Delete
  Future<int> removeBookmark(int surahId) async {
    final db = await instance.database;
    return await db.delete("bookmarks", where: "surahId = ?", whereArgs: [surahId]);
  }
}
