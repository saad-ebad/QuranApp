import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FolderDatabase {
  static final FolderDatabase instance = FolderDatabase._init();
  static Database? _database;

  FolderDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("folders.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE folder_ayahs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folderId INTEGER,
        surahName TEXT,
        verseNumber INTEGER,
        arabic TEXT,
        urdu TEXT,
        FOREIGN KEY (folderId) REFERENCES folders(id)
      )
    ''');
  }

  Future<int> createFolder(String name) async {
    final db = await instance.database;
    return await db.insert("folders", {"name": name});
  }

  /// ✅ Delete a specific ayah by its ID
  Future<int> deleteAyah(int id) async {
    final db = await instance.database;
    return await db.delete(
      "folder_ayahs",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  /// ✅ Delete folder and all its ayahs
  Future<int> deleteFolder(int folderId) async {
    final db = await instance.database;
    // delete ayahs first (cascade)
    await db.delete(
      "folder_ayahs",
      where: "folderId = ?",
      whereArgs: [folderId],
    );
    // then delete folder
    return await db.delete(
      "folders",
      where: "id = ?",
      whereArgs: [folderId],
    );
  }


  Future<List<Map<String, dynamic>>> getAllFolders() async {
    final db = await instance.database;
    return await db.query("folders");
  }

  Future<int> insertAyah({
    required int folderId,
    required String surahName,
    required int verseNumber,
    required String arabic,
    required String urdu,
  }) async {
    final db = await instance.database;
    return await db.insert("folder_ayahs", {
      "folderId": folderId,
      "surahName": surahName,
      "verseNumber": verseNumber,
      "arabic": arabic,
      "urdu": urdu,
    });
  }

  /// ✅ NEW: Fetch all ayahs for a specific folder
  Future<List<Map<String, dynamic>>> getAyahsByFolder(int folderId) async {
    final db = await instance.database;
    return await db.query(
      "folder_ayahs",
      where: "folderId = ?",
      whereArgs: [folderId],
      orderBy: "verseNumber ASC", // optional: order by verse
    );
  }
}
