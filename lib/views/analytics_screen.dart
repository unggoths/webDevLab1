import 'dart:isolate';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_view_model.dart';

import '../repositories/analytics_isolate.dart';
import '../repositories/local_database_task_repository.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // ── Стан ізоляту ────────────────────────────────────────────────────────────
  Isolate? _isolate;
  ReceivePort? _receivePort;

  bool _isRunning = false;
  bool _isGenerating = false; // генерація тестових даних
  int _processed = 0;
  int _total = 0;
  AnalyticsResult? _result;
  String? _error;

  @override
  void dispose() {
    // Крок 4 — коректне звільнення ресурсів
    _killIsolate();
    super.dispose();
  }

  void _killIsolate() {
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
    _isolate = null;
    _receivePort = null;
  }

  // ── Генерація 10 000 тестових записів ───────────────────────────────────────
  Future<void> _generateTestData() async {
    setState(() => _isGenerating = true);
    await context.read<TaskViewModel>().generateTestData();
    if (mounted) setState(() => _isGenerating = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Додано 10 000 тестових завдань'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }



  // ── Запуск фонового ізоляту ──────────────────────────────────────────────────
  Future<void> _startAnalysis() async {
    setState(() {
      _isRunning = true;
      _processed = 0;
      _total = 0;
      _result = null;
      _error = null;
    });

    try {
      // Отримуємо шлях до БД у головному потоці
      final dbPath = p.join(await getDatabasesPath(), 'tasks_v2.db');

      // Отримуємо токен для ініціалізації платформених каналів у фоні
      final token = RootIsolateToken.instance!;

      // Створюємо порт для отримання повідомлень від ізоляту
      _receivePort = ReceivePort();

      // Слухаємо повідомлення
      _receivePort!.listen((message) {
        if (!mounted) return;

        if (message is ProgressMessage) {
          setState(() {
            _processed = message.processed;
            _total = message.total;
          });
        } else if (message is AnalyticsResult) {
          setState(() {
            _result = message;
            _isRunning = false;
          });
          _killIsolate();
        }
      });

      // Запускаємо ізолят
      _isolate = await Isolate.spawn(
        analyticsIsolateEntry,
        IsolateStartMessage(
          sendPort: _receivePort!.sendPort,
          dbPath: dbPath,
          token: token,
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isRunning = false;
      });
    }
  }

  // ── UI ───────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналітика та експорт'),
        backgroundColor: cs.surfaceContainerHighest,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Секція генерації даних ─────────────────────────────────────
            _SectionCard(
              icon: Icons.dataset,
              title: 'Тестові дані',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Додає 10 000 завдань з випадковими назвами та статусами для тестування продуктивності.',
                    style: TextStyle(
                      color: cs.onSurface.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed:
                    (_isGenerating || _isRunning) ? null : _generateTestData,
                    icon: _isGenerating
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.add_chart),
                    label: Text(_isGenerating
                        ? 'Генерація...'
                        : 'Згенерувати 10 000 записів'),
                  ),
                  OutlinedButton.icon(
                    onPressed: (_isGenerating || _isRunning)
                        ? null
                        : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Очистити всі завдання?'),
                          content: const Text('Це видалить усі записи з бази даних.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Скасувати'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                              child: const Text('Очистити'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await context.read<TaskViewModel>().clearAllTasks();
                      }
                    },
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Очистити всі завдання'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Секція аналізу ─────────────────────────────────────────────
            _SectionCard(
              icon: Icons.analytics,
              title: 'Фоновий аналіз',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Читає всі записи з БД у фоновому ізоляті — UI залишається плавним.',
                    style: TextStyle(
                      color: cs.onSurface.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Прогрес
                  if (_isRunning) ...[
                    _ProgressSection(
                        processed: _processed, total: _total, cs: cs),
                    const SizedBox(height: 16),
                  ],

                  FilledButton.icon(
                    onPressed:
                    (_isRunning || _isGenerating) ? null : _startAnalysis,
                    icon: _isRunning
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.play_arrow),
                    label: Text(_isRunning
                        ? 'Виконується...'
                        : 'Почати фонову генерацію звіту'),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(color: cs.onErrorContainer),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Результат ─────────────────────────────────────────────────
            if (_result != null) ...[
              const SizedBox(height: 16),
              _ResultSection(result: _result!, cs: cs),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Допоміжні віджети ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final int processed;
  final int total;
  final ColorScheme cs;

  const _ProgressSection({
    required this.processed,
    required this.total,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? processed / total : 0.0;
    final percent = (progress * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Оброблено $processed / $total записів',
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: total > 0 ? progress : null,
          borderRadius: BorderRadius.circular(8),
          minHeight: 8,
          backgroundColor: cs.primaryContainer,
          color: cs.primary,
        ),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  final AnalyticsResult result;
  final ColorScheme cs;

  const _ResultSection({required this.result, required this.cs});

  @override
  Widget build(BuildContext context) {
    final sizeKb = (result.exportedBytes / 1024).toStringAsFixed(1);
    final elapsed =
        '${result.elapsed.inSeconds}.${(result.elapsed.inMilliseconds % 1000).toString().padLeft(3, '0')}с';

    return Card(
      elevation: 0,
      color: cs.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.primary.withOpacity(0.3), width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Звіт готовий',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: cs.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  elapsed,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _statGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _statGrid(BuildContext context) {
    final sizeKb = (result.exportedBytes / 1024).toStringAsFixed(1);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        _StatTile(label: 'Всього', value: '${result.total}', icon: Icons.list_alt),
        _StatTile(
            label: 'Виконано',
            value: '${result.completed}',
            icon: Icons.check_circle_outline,
            color: Colors.green),
        _StatTile(
            label: 'Активних',
            value: '${result.active}',
            icon: Icons.radio_button_unchecked,
            color: Colors.orange),
        _StatTile(
            label: 'Високий пріоритет',
            value: '${result.highPriority}',
            icon: Icons.arrow_upward,
            color: Colors.red),
        _StatTile(
            label: 'Розмір даних',
            value: '$sizeKb КБ',
            icon: Icons.storage),
        _StatTile(
            label: 'Виконано %',
            value: result.total > 0
                ? '${(result.completed / result.total * 100).toStringAsFixed(1)}%'
                : '0%',
            icon: Icons.percent),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? cs.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}