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

  AnalyticsResult({
    required this.total,
    required this.completed,
    required this.active,
    required this.highPriority,
    required this.exportedBytes,
    required this.elapsed,
  });
}

/// Точка входу фонового ізоляту — має бути top-level функцією
Future<void> analyticsIsolateEntry(IsolateStartMessage msg) async {
  // Крок 1 — ініціалізуємо платформені канали (потрібно для sqflite у фоні)
  BackgroundIsolateBinaryMessenger.ensureInitialized(msg.token);

  final sendPort = msg.sendPort;
  final stopwatch = Stopwatch()..start();

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

  while (offset < total) {
    final rows = await db.query(
      'tasks',
      limit: pageSize,
      offset: offset,
    );

    for (final row in rows) {
      // Серіалізація — імітуємо CPU-bound роботу
      final json =
          '{"id":${row['id']},"title":"${(row['title'] as String).replaceAll('"', '\\"')}","isCompleted":${row['isCompleted']},"priority":${row['priority']},"createdAt":${row['createdAt']}}';
      exportedBytes += json.length;

      if (row['isCompleted'] == 1 || row['isCompleted'] == true) completed++;
      if ((row['priority'] as int? ?? 1) == 2) highPriority++;

      processed++;

      // Кожні 200 записів — надсилаємо прогрес у головний потік
      if (processed % 200 == 0) {
        sendPort.send(ProgressMessage(processed, total));
      }
    }

    offset += pageSize;
  }

  //final directory = await getApplicationDocumentsDirectory();
  //final file = File('${directory.path}/tasks_export.json');
  //await file.writeAsString('[$allJsonRows]');
  //sendPort.send('export_path:${file.path}');

  await db.close();
  stopwatch.stop();

  // Надсилаємо фінальний результат
  sendPort.send(AnalyticsResult(
    total: total,
    completed: completed,
    active: total - completed,
    highPriority: highPriority,
    exportedBytes: exportedBytes,
    elapsed: stopwatch.elapsed,
  ));
}