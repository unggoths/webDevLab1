import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Повідомлення що передається в ізолят для старту
class IsolateStartMessage {
  final SendPort sendPort;
  final String dbPath;
  final RootIsolateToken token;

  IsolateStartMessage({
    required this.sendPort,
    required this.dbPath,
    required this.token,
  });
}

/// Повідомлення прогресу від ізоляту до UI
class ProgressMessage {
  final int processed;
  final int total;

  ProgressMessage(this.processed, this.total);
}

/// Фінальний результат від ізоляту
class AnalyticsResult {
  final int total;
  final int completed;
  final int active;
  final int highPriority;
  final int exportedBytes;
  final Duration elapsed;
  final String exportPath;
  final List<String> previewRows;

  AnalyticsResult({
    required this.total,
    required this.completed,
    required this.active,
    required this.highPriority,
    required this.exportedBytes,
    required this.elapsed,
    required this.exportPath,
    required this.previewRows

  });
}

/// Точка входу фонового ізоляту — має бути top-level функцією
Future<void> analyticsIsolateEntry(IsolateStartMessage msg) async {
  // Крок 1 — ініціалізуємо платформені канали (потрібно для sqflite у фоні)
  BackgroundIsolateBinaryMessenger.ensureInitialized(msg.token);

  final sendPort = msg.sendPort;
  final stopwatch = Stopwatch()
    ..start();

  // Крок 2 — відкриваємо БД за переданим шляхом
  final db = await openDatabase(
    msg.dbPath,
    readOnly: true,
    singleInstance: false,
  );

  // Крок 3 — отримуємо загальну кількість записів
  final countResult = await db.rawQuery('SELECT COUNT(*) as cnt FROM tasks');
  final total = Sqflite.firstIntValue(countResult) ?? 0;

  int processed = 0;
  int completed = 0;
  int highPriority = 0;
  int exportedBytes = 0;

  // Крок 4 — обробляємо пагінацією щоб не завантажувати все в RAM
  const pageSize = 500;
  int offset = 0;
  final buffer = StringBuffer('[');
  bool first = true;
  final previewRows = <String>[];
  while (offset < total) {
    final rows = await db.query('tasks', limit: pageSize, offset: offset);

    for (final row in rows) {
      final description = (row['description'] as String? ?? '').replaceAll(
          '"', '\\"');
      final title = (row['title'] as String? ?? '').replaceAll('"', '\\"');
      final json =
          '{"id":${row['id']},"title":"$title","description":"$description","isCompleted":${row['isCompleted']},"priority":${row['priority']},"createdAt":${row['createdAt']},"dueDate":${row['dueDate']}}';
      if (previewRows.length < 2) previewRows.add(json);

      if (!first) buffer.write(',');
      buffer.write(json);
      first = false;

      exportedBytes += json.length;
      if (row['isCompleted'] == 1 || row['isCompleted'] == true) completed++;
      if ((row['priority'] as int? ?? 1) == 2) highPriority++;
      processed++;

      if (processed % 200 == 0) {
        sendPort.send(ProgressMessage(processed, total));
      }
    }

    offset += pageSize;
  }

  buffer.write(']');

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/tasks_export.json');
  await file.writeAsString(buffer.toString());

  await db.close();
  stopwatch.stop();

  sendPort.send(AnalyticsResult(
    total: total,
    completed: completed,
    active: total - completed,
    highPriority: highPriority,
    exportedBytes: exportedBytes,
    elapsed: stopwatch.elapsed,
    exportPath: file.path,
    previewRows: previewRows,
  ));
}