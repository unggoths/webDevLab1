import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/task.dart';
import 'i_task_repository.dart';

/// Конкретна реалізація репозиторію — SQLite (локальна БД).
/// Принципи SOLID:
///   S — клас відповідає виключно за зберігання/отримання даних
///   L — реалізує контракт ITaskRepository без порушення його семантики
///   I — імплементує лише потрібні методи інтерфейсу
class LocalDatabaseTaskRepository implements ITaskRepository {
  static const _dbName = 'tasks_v2.db';
  static const _dbVersion = 1;
  static const _tableName = 'tasks';

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    if (kIsWeb) {
      return databaseFactoryFfiWeb.openDatabase(
        _dbName,
        options: OpenDatabaseOptions(
          version: _dbVersion,
          onCreate: _createSchema,
        ),
      );
    }
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _createSchema);
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,
        description TEXT    NOT NULL DEFAULT '',
        isCompleted INTEGER NOT NULL DEFAULT 0,
        priority    INTEGER NOT NULL DEFAULT 1,
        createdAt   INTEGER NOT NULL,
        dueDate     INTEGER
      )
    ''');
  }

  @override
  Future<List<Task>> getTasks() async {
    final db = await _database;
    final rows = await db.query(_tableName, orderBy: 'createdAt DESC');
    return rows.map(Task.fromMap).toList();
  }

  @override
  Future<Task> addTask(Task task) async {
    final db = await _database;
    final map = task.toMap()..remove('id');
    final id = await db.insert(_tableName, map);
    return task.copyWith(id: id);
  }

  @override
  Future<void> updateTask(Task task) async {
    assert(task.id != null, 'Cannot update a task without an id');
    final db = await _database;
    await db.update(
      _tableName,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> deleteTask(int id) async {
    final db = await _database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> dispose() async {
    await _db?.close();
    _db = null;
  }
}
