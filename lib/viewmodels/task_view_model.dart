import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../repositories/analytics_isolate.dart';
import '../repositories/i_task_repository.dart';
import 'dart:math';import 'dart:math';
import '../repositories/local_database_task_repository.dart';
/// Фільтри для відображення завдань
enum TaskFilter { all, active, completed }

/// ViewModel — посередник між View та Repository.
/// Принципи SOLID:
///   S — відповідає лише за логіку представлення (фільтрація, стан завантаження)
///   D — отримує ITaskRepository через конструктор (Dependency Injection)
///
/// View підписується на зміни через ChangeNotifier (data binding).
/// ViewModel НІЧОГО не знає про Widget-и.
class TaskViewModel extends ChangeNotifier {
  final ITaskRepository _repository;

  TaskViewModel(this._repository);

  // ── Стан ──────────────────────────────────────────────────────────────────

  List<Task> _allTasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  TaskFilter _filter = TaskFilter.all;
  String _searchQuery = '';
  AnalyticsResult? analyticsResult;

  // ── Геттери (read-only для View) ──────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TaskFilter get filter => _filter;
  String get searchQuery => _searchQuery;

  /// Відфільтрований + відшуканий список для відображення
  List<Task> get tasks {
    Iterable<Task> result = _allTasks;

    // Фільтрація за статусом
    switch (_filter) {
      case TaskFilter.active:
        result = result.where((t) => !t.isCompleted);
        break;
      case TaskFilter.completed:
        result = result.where((t) => t.isCompleted);
        break;
      case TaskFilter.all:
        break;
    }

    // Пошук за назвою та описом
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where(
        (t) =>
            t.title.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q),
      );
    }

    return result.toList();
  }

  int get completedCount => _allTasks.where((t) => t.isCompleted).length;
  int get totalCount => _allTasks.length;

  // ── Команди від View ───────────────────────────────────────────────────────

  Future<void> loadTasks() async {
    _setLoading(true);
    try {
      _allTasks = await _repository.getTasks();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Не вдалося завантажити завдання: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTask({
    required String title,
    String description = '',
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    if (title.trim().isEmpty) return;
    try {
      final task = Task(
        title: title.trim(),
        description: description.trim(),
        priority: priority,
        createdAt: DateTime.now(),
        dueDate: dueDate,
      );
      final saved = await _repository.addTask(task);
      _allTasks.insert(0, saved);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Помилка при додаванні: $e';
      notifyListeners();
    }
  }

  Future<void> toggleCompleted(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _updateTask(updated);
  }

  Future<void> updateTask(Task task) async {
    await _updateTask(task);
  }

  Future<void> deleteTask(int id) async {
    try {
      await _repository.deleteTask(id);
      _allTasks.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Помилка при видаленні: $e';
      notifyListeners();
    }
  }

  void setFilter(TaskFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ── Внутрішні методи ───────────────────────────────────────────────────────

  Future<void> _updateTask(Task task) async {
    try {
      await _repository.updateTask(task);
      final index = _allTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _allTasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Помилка при оновленні: $e';
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _repository.dispose();
    super.dispose();
  }

  Future<void> clearAllTasks() async {
    try {
      await _repository.clearAll();
      _allTasks = [];
      analyticsResult = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Помилка при очищенні: $e';
      notifyListeners();
    }
  }

  Future<void> generateTestData() async {
    final random = Random();
    final db = await (_repository as LocalDatabaseTaskRepository).getDatabase();

    final titles = [
      'Написати звіт', 'Підготувати презентацію', 'Зустріч з командою',
      'Здати лабораторну', 'Прочитати документацію', 'Виправити баг',
      'Code review', 'Оновити залежності', 'Написати тести', 'Задеплоїти на prod',
    ];
    
    final descriptions = [
      'Зробити 1','Зробити 2','Зробити 3','Зробити 4','Зробити 1',
      'Зробити 1','Зробити 1','Зробити 1','Зробити 1','Зробити 1',
    ];

    const batchSize = 500;
    const total = 10000;

    for (int i = 0; i < total; i += batchSize) {
      final batch = db.batch();
      final count = min(batchSize, total - i);

      for (int j = 0; j < count; j++) {
        batch.insert('tasks', {
          'title': '${titles[random.nextInt(titles.length)]} #${i + j + 1}',
          'description': '${descriptions[random.nextInt(descriptions.length)]} #${i + j + 1}',
          'isCompleted': random.nextBool() ? 1 : 0,
          'priority': random.nextInt(3),
          'createdAt': DateTime.now()
              .subtract(Duration(days: random.nextInt(365)))
              .millisecondsSinceEpoch,
          'dueDate': null,
        });
      }

      await batch.commit(noResult: true);
    }

    await loadTasks();
  }
}
