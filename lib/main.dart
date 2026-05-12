import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/local_database_task_repository.dart';
import 'viewmodels/task_view_model.dart';
import 'views/task_list_screen.dart';

/// Точка входу.
/// Dependency Injection виконується тут — у корені дерева.
/// ViewModel отримує ITaskRepository через конструктор,
/// тому вона не знає про SQLite і може бути замінена на будь-яку іншу реалізацію.
void main() {
  runApp(
    ChangeNotifierProvider(
      // Створюємо репозиторій і передаємо у ViewModel
      create: (_) => TaskViewModel(LocalDatabaseTaskRepository()),
      child: const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A6CF7),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(margin: EdgeInsets.zero), // ← всередині ThemeData
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A6CF7),
          brightness: Brightness.dark,
        ),
      ),
      home: const TaskListScreen(),
    );
  }
}
