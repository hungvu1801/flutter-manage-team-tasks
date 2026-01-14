import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/task_firestore_service.dart';
import '../tasks/domain/task.dart';
import '../tasks/domain/task_status.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final TaskFirestoreService _taskService = TaskFirestoreService();

  /// Group tasks by date (YYYY-MM-DD)
  Map<DateTime, List<Task>> _groupTasksByDay(List<Task> tasks) {
    final map = <DateTime, List<Task>>{};

    for (final task in tasks) {
      final key = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      map.putIfAbsent(key, () => []);
      map[key]!.add(task);
    }

    return map;
  }

  List<Task> _getTasksForDay(
      DateTime day,
      Map<DateTime, List<Task>> tasksByDay,
      ) {
    final key = DateTime(day.year, day.month, day.day);
    return tasksByDay[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: _taskService.watchTasks(),
      builder: (context, snapshot) {
        // LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // EMPTY
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No tasks yet.\nCreate your first task 🚀',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final tasksByDay = _groupTasksByDay(snapshot.data!);

        return SafeArea(
          child: Column(
            children: [
              /// CALENDAR
              SizedBox(
                height: 360,
                child: DragTarget<Task>(
                  onWillAccept: (_) => true,
                  onAccept: (task) {
                    if (_selectedDay != null) {
                      _taskService.updateTaskDueDate(task, _selectedDay!);
                    }
                  },
                  builder: (_, __, ___) {
                    return TableCalendar(
                      firstDay: DateTime.utc(2023, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      eventLoader: (day) =>
                          _getTasksForDay(day, tasksByDay),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blueGrey,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// TASK LIST
              Expanded(
                child: _selectedDay == null
                    ? const Center(
                  child: Text(
                    'Select a day to view tasks',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : _TaskList(
                  tasks: _getTasksForDay(
                    _selectedDay!,
                    tasksByDay,
                  ),
                  onDelete: (task) =>
                      _taskService.deleteTask(task.id),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ======================= TASK LIST ======================= */

class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  final ValueChanged<Task> onDelete;

  const _TaskList({
    required this.tasks,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'No tasks for this day',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Draggable<Task>(
          data: task,
          feedback: Material(
            elevation: 4,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: _TaskTile(task: task, onDelete: onDelete),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: _TaskTile(task: task, onDelete: onDelete),
          ),
          child: _TaskTile(task: task, onDelete: onDelete),
        );
      },
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  final ValueChanged<Task> onDelete;

  const _TaskTile({
    required this.task,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(task.status.value),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _confirmDelete(context);
            } else if (value == 'edit') {
              context.push('/tasks/edit', extra: task);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This action cannot be undone'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete(task);
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
