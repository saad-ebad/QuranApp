

///Working
/*
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SettingsDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'settings.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY,
            mobileDataAllowed INTEGER,
            dailyNotification INTEGER,
            customNotificationTime TEXT,
            selectedTheme TEXT
          )
        ''');
      },
      version: 1,
    );
    return _db!;
  }

  static Future<void> saveSettings({
    required bool mobileData,
    required bool dailyNotification,
    required String? customTime,
    required String selectedTheme,
  }) async {
    final db = await database;
    await db.insert(
      'settings',
      {
        'id': 1,
        'mobileDataAllowed': mobileData ? 1 : 0,
        'dailyNotification': dailyNotification ? 1 : 0,
        'customNotificationTime': customTime,
        'selectedTheme': selectedTheme,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>> getSettings() async {
    final db = await database;
    final result = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return {
      'mobileDataAllowed': 0,
      'dailyNotification': 1, // default ON
      'customNotificationTime': null,
      'selectedTheme': 'Light Mode',
    };
  }
}
*/
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
class SettingsDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'settings.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY,
            mobileDataAllowed INTEGER,
            dailyNotification INTEGER,
            customNotificationTime TEXT,
            customReminderEnabled INTEGER,   -- ✅ new column
            selectedTheme TEXT
          )
        ''');
      },
      version: 2, // ✅ bump version
    );
    return _db!;
  }

  static Future<void> saveSettings({
    required bool mobileData,
    required bool dailyNotification,
    required String? customTime,
    required bool customReminderEnabled,   // ✅ new
    required String selectedTheme,
  }) async {
    final db = await database;
    await db.insert(
      'settings',
      {
        'id': 1,
        'mobileDataAllowed': mobileData ? 1 : 0,
        'dailyNotification': dailyNotification ? 1 : 0,
        'customNotificationTime': customTime,
        'customReminderEnabled': customReminderEnabled ? 1 : 0, // ✅ save state
        'selectedTheme': selectedTheme,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>> getSettings() async {
    final db = await database;
    final result = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return {
      'mobileDataAllowed': 0,
      'dailyNotification': 1,
      'customNotificationTime': null,
      'customReminderEnabled': 0,   // ✅ default false
      'selectedTheme': 'Light Mode',
    };
  }
}

