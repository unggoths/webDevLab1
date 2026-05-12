import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../repositories/i_task_repository.dart';

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
}
