import '../models/task.dart';

/// Абстрактний інтерфейс репозиторію.
/// Принципи SOLID:
///   D — ViewModel залежить від абстракції, а не від конкретної реалізації
///   O — нові реалізації (API, Firebase) не змінюють цей контракт
abstract class ITaskRepository {
  /// Повертає всі завдання
  Future<List<Task>> getTasks();

  /// Додає нове завдання, повертає його з присвоєним id
  Future<Task> addTask(Task task);

  /// Оновлює існуюче завдання
  Future<void> updateTask(Task task);

  /// Видаляє завдання за id
  Future<void> deleteTask(int id);

  /// Звільняє ресурси (закриває БД тощо)
  Future<void> dispose();

  Future<void> clearAll();
}
