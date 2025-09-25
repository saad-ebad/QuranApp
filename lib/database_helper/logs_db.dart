import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/app_log.dart';

class LogsDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_logs.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            message TEXT,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  /// Add a log and cleanup logs older than 14 days
  static Future<void> addLog(String message) async {
    final db = await database;
    final now = DateTime.now();

    await db.insert('logs', {
      'message': message,
      'timestamp': now.toIso8601String(),
    });

    // Auto-delete logs older than 2 weeks
    final cutoff = now.subtract(const Duration(days: 14));
    await db.delete(
      'logs',
      where: 'timestamp < ?',
      whereArgs: [cutoff.toIso8601String()],
    );
  }

  static Future<List<AppLog>> getAllLogs() async {
    final db = await database;
    final result = await db.query(
      'logs',
      orderBy: 'timestamp DESC',
    );
    return result.map((e) => AppLog.fromMap(e)).toList();
  }

  static Future<void> clearLogs() async {
    final db = await database;
    await db.delete('logs');
  }
}
