  import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'analytics_screen.dart';
import '../models/task.dart';
import '../viewmodels/task_view_model.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_dialog.dart';

/// Головний екран — View шар MVVM.
/// Принципи SOLID:
///   S — відповідає лише за відображення стану та передачу команд до ViewModel
///
/// View НІЧОГО не знає про репозиторій чи базу даних.
/// Вся логіка — у TaskViewModel.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    // Завантажуємо дані після першого побудови дерева
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const TaskFormDialog(),
    );
    if (result == null || !mounted) return;
    await context.read<TaskViewModel>().addTask(
          title: result['title'],
          description: result['description'],
          priority: result['priority'],
          dueDate: result['dueDate'],
        );
  }

  Future<void> _openEditDialog(Task task) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => TaskFormDialog(task: task),
    );
    if (result == null || !mounted) return;
    await context.read<TaskViewModel>().updateTask(
          task.copyWith(
            title: result['title'],
            description: result['description'],
            priority: result['priority'],
            dueDate: result['dueDate'],
            clearDueDate: result['dueDate'] == null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(vm, cs),
      body: Column(
        children: [
          // Пошуковий рядок
          if (_showSearch) _SearchBar(controller: _searchController, vm: vm),

          // Фільтри
          _FilterBar(vm: vm),

          // Статистика
          _StatsBar(vm: vm),

          // Список
          Expanded(child: _buildBody(vm)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Нове завдання'),
      ),
    );
  }

  AppBar _buildAppBar(TaskViewModel vm, ColorScheme cs) {
    return AppBar(
      backgroundColor: cs.surfaceContainerHighest,
      elevation: 0,
      title: const Text(
        'Task Manager',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          icon: Icon(_showSearch ? Icons.search_off : Icons.search),
          tooltip: 'Пошук',
          onPressed: () {
            setState(() => _showSearch = !_showSearch);
            if (!_showSearch) {
              _searchController.clear();
              vm.setSearchQuery('');
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.analytics_outlined),
          tooltip: 'Аналітика',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Оновити',
          onPressed: vm.loadTasks,
        ),
      ],
    );
  }

  Widget _buildBody(TaskViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(vm.errorMessage!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: vm.loadTasks,
              child: const Text('Спробувати знову'),
            ),
          ],
        ),
      );
    }

    if (vm.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64,
                color:
                    Theme.of(context).colorScheme.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              vm.searchQuery.isNotEmpty
                  ? 'Нічого не знайдено'
                  : 'Завдань поки немає',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: vm.tasks.length,
        itemBuilder: (context, index) {
          final task = vm.tasks[index];
          return TaskCard(
            key: ValueKey(task.id),
            task: task,
            onToggle: () => vm.toggleCompleted(task),
            onEdit: () => _openEditDialog(task),
            onDelete: () => vm.deleteTask(task.id!),
          );
        },
      ),
    );
  }
}

// ── Допоміжні віджети (окремі відповідальності) ───────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final TaskViewModel vm;

  const _SearchBar({required this.controller, required this.vm});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SearchBar(
        controller: controller,
        hintText: 'Пошук завдань…',
        leading: const Icon(Icons.search),
        trailing: [
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.clear();
                vm.setSearchQuery('');
              },
            ),
        ],
        onChanged: vm.setSearchQuery,
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final TaskViewModel vm;

  const _FilterBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SegmentedButton<TaskFilter>(
        segments: const [
          ButtonSegment(value: TaskFilter.all, label: Text('Всі')),
          ButtonSegment(value: TaskFilter.active, label: Text('Активні')),
          ButtonSegment(
              value: TaskFilter.completed, label: Text('Виконані')),
        ],
        selected: {vm.filter},
        onSelectionChanged: (s) => vm.setFilter(s.first),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  final TaskViewModel vm;

  const _StatsBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final done = vm.completedCount;
    final total = vm.totalCount;
    final progress = total == 0 ? 0.0 : done / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: cs.primaryContainer,
              color: cs.primary,
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$done / $total',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }
}
