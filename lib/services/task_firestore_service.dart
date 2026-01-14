import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../features/tasks/domain/task.dart';
import '../features/tasks/domain/task_status.dart';

class TaskFirestoreService {
  final _tasks = FirebaseFirestore.instance.collection('tasks');

  /// REALTIME – dùng cho Calendar + Kanban
  Stream<List<Task>> watchTasks() {
    return _tasks.snapshots().map((snapshot) {
      debugPrint('🔥 Firestore snapshot: ${snapshot.docs.length} docs');

      return snapshot.docs.map((doc) {
        final data = doc.data();

        debugPrint('📄 Raw doc ${doc.id}: $data');

        final task = Task.fromFirestore(doc.id, data);

        debugPrint('✅ Parsed Task → '
            'title="${task.title}", '
            'status=${task.status}, '
            'dueDate=${task.dueDate}');

        return task;
      }).toList();
    });
  }

  Future<void> addTask(Task task) async {
    await _tasks.add(task.toFirestore());
  }

  Future<void> updateTaskStatus(Task task, TaskStatus newStatus) async {
    await _tasks.doc(task.id).update({
      'status': newStatus.value,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateTaskDueDate(Task task, DateTime newDate) async {
    await _tasks.doc(task.id).update({
      'dueDate': newDate.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  ///UPDATE FULL TASK (edit screen)
  Future<void> updateTask(Task task) async {
    await _tasks.doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'assignee': task.assignee,
      'dueDate': task.dueDate.toIso8601String(),
      'status': task.status.value,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _tasks.doc(taskId).delete();
  }
}
