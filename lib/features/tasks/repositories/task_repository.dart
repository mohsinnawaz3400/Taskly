import 'package:sqflite/sqflite.dart';

import '../../../services/database_service.dart';
import '../models/task_model.dart';

class TaskRepository {
  TaskRepository(this._databaseService);

  final DatabaseService _databaseService;

  Future<List<TaskModel>> getAll() async {
    final db = await _databaseService.database;

    final rows = await db.query(
      'tasks',
      orderBy: 'created_at DESC',
    );

    return rows.map(TaskModel.fromMap).toList();
  }

  Future<void> insert(TaskModel task) async {
    final db = await _databaseService.database;

    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> update(TaskModel task) async {
    final db = await _databaseService.database;

    final count = await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );

    if (count == 0) {
      throw StateError('Task database mein nahi mili.');
    }
  }

  Future<void> delete(String id) async {
    final db = await _databaseService.database;

    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}