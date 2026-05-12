import 'package:flutter/material.dart';
import '../models/task.dart';

/// Картка завдання.
/// Принципи SOLID:
///   S — відповідає лише за відображення одного завдання
///   O — нові дії (share, archive) можна додати без зміни існуючого коду
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Color _priorityColor(TaskPriority p, ColorScheme cs) {
    return switch (p) {
      TaskPriority.low => Colors.green.shade400,
      TaskPriority.medium => cs.primary,
      TaskPriority.high => cs.error,
    };
  }

  String _priorityLabel(TaskPriority p) {
    return switch (p) {
      TaskPriority.low => 'Низький',
      TaskPriority.medium => 'Середній',
      TaskPriority.high => 'Високий',
    };
  }

  bool get _isOverdue =>
      task.dueDate != null &&
      !task.isCompleted &&
      task.dueDate!.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final pColor = _priorityColor(task.priority, cs);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Видалити завдання?'),
            content: Text('"${task.title}" буде видалено назавжди.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Скасувати'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.error,
                ),
                child: const Text('Видалити'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant, width: 0.8),
        ),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Чекбокс
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isCompleted ? pColor : Colors.transparent,
                        border: Border.all(
                          color: task.isCompleted ? pColor : cs.outline,
                          width: 2,
                        ),
                      ),
                      child: task.isCompleted
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Контент
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Назва
                      Text(
                        task.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? cs.onSurface.withOpacity(0.4)
                              : cs.onSurface,
                        ),
                      ),

                      // Опис
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Мітки
                      Wrap(
                        spacing: 6,
                        children: [
                          // Пріоритет
                          _Chip(
                            label: _priorityLabel(task.priority),
                            color: pColor,
                          ),

                          // Дата виконання
                          if (task.dueDate != null)
                            _Chip(
                              icon: _isOverdue
                                  ? Icons.warning_amber_rounded
                                  : Icons.calendar_today,
                              label:
                                  '${task.dueDate!.day.toString().padLeft(2, '0')}.${task.dueDate!.month.toString().padLeft(2, '0')}',
                              color: _isOverdue ? cs.error : cs.secondary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Меню
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      size: 18, color: cs.onSurface.withOpacity(0.5)),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Редагувати')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Видалити',
                        style: TextStyle(color: cs.error),
                      ),
                    ),
                  ],
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Chip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
