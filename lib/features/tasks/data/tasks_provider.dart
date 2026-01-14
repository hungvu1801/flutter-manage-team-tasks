import 'package:flutter/foundation.dart';
import '../domain/task.dart';
import '../domain/task_status.dart';
import 'mock_tasks.dart';

final tasksProvider = ValueNotifier<List<Task>>(List.from(mockTasks));

void addTask(Task task) {
  final currentTasks = List<Task>.from(tasksProvider.value);
  currentTasks.insert(0, task);
  tasksProvider.value = currentTasks;
}

void moveTask(Task task, TaskStatus newStatus, {int? insertIndex}) {
    final currentTasks = List<Task>.from(tasksProvider.value);

    final originalTaskIndex = currentTasks.indexWhere((t) => t.id == task.id);
    if (originalTaskIndex == -1) return;
    currentTasks.removeAt(originalTaskIndex);

    final updatedTask = task.copyWith(status: newStatus);

    final targetColumnTasks = currentTasks.where((t) => t.status == newStatus).toList();

    if (insertIndex == null || insertIndex >= targetColumnTasks.length) {
      final lastTaskInColumnIndex = currentTasks.lastIndexWhere((t) => t.status == newStatus);
      if (lastTaskInColumnIndex == -1) {
        final allStatuses = TaskStatus.values;
        final newStatusOrder = allStatuses.indexOf(newStatus);
        int insertPosition = 0;
        for (int i = 0; i < currentTasks.length; i++) {
          final taskStatusOrder = allStatuses.indexOf(currentTasks[i].status);
          if (taskStatusOrder > newStatusOrder) {
            insertPosition = i;
            break;
          }
          insertPosition = i + 1;
        }
        currentTasks.insert(insertPosition, updatedTask);
      } else {
        currentTasks.insert(lastTaskInColumnIndex + 1, updatedTask);
      }
    } else {
      final taskToInsertBefore = targetColumnTasks[insertIndex];
      final globalIndex = currentTasks.indexWhere((t) => t.id == taskToInsertBefore.id);
      currentTasks.insert(globalIndex, updatedTask);
    }
    tasksProvider.value = currentTasks;
}
