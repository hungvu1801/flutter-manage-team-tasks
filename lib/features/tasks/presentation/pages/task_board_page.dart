import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../services/task_firestore_service.dart';
import '../../domain/task.dart';
import '../../domain/task_status.dart';
import '../widgets/kanban_column.dart';
import '../widgets/task_tile.dart';

class TaskBoardPage extends StatelessWidget {
  const TaskBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TaskFirestoreService();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/create'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Task>>(
        stream: service.watchTasks(),
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
              ),
            );
          }

          final tasks = snapshot.data!;

          final todo =
          tasks.where((t) => t.status == TaskStatus.todo).toList();
          final doing =
          tasks.where((t) => t.status == TaskStatus.inProgress).toList();
          final done =
          tasks.where((t) => t.status == TaskStatus.done).toList();

          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            children: [
              KanbanColumn(
                title: 'To Do',
                status: TaskStatus.todo,
                tasks: todo,
                onTaskDropped: (task, newStatus, {insertIndex}) {
                  service.updateTaskStatus(task, newStatus);
                },
                onDelete: (task) => service.deleteTask(task.id),
              ),
              KanbanColumn(
                title: 'In Progress',
                status: TaskStatus.inProgress,
                tasks: doing,
                onTaskDropped: (task, newStatus, {insertIndex}) {
                  service.updateTaskStatus(task, newStatus);
                },
                onDelete: (task) => service.deleteTask(task.id),
              ),
              KanbanColumn(
                title: 'Done',
                status: TaskStatus.done,
                tasks: done,
                onTaskDropped: (task, newStatus, {insertIndex}) {
                  service.updateTaskStatus(task, newStatus);
                },
                onDelete: (task) => service.deleteTask(task.id),
              ),
            ],
          );
        },
      ),
    );
  }
}
