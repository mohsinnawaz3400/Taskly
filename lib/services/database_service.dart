import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const _databaseName = 'taskflow.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasePath = await getDatabasesPath();
    final fullPath = path.join(databasePath, _databaseName);

    _database = await openDatabase(
      fullPath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            category TEXT NOT NULL DEFAULT 'Personal',
            priority TEXT NOT NULL DEFAULT 'medium',
            is_completed INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            due_date TEXT
          )
        ''');
      },
    );

    return _database!;
  }
}