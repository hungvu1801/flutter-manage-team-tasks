import 'package:cloud_firestore/cloud_firestore.dart';

class TaskService {
  final CollectionReference _tasks =
  FirebaseFirestore.instance.collection('tasks');

  /// 🔹 READ – realtime stream
  Stream<List<Map<String, dynamic>>> getTasks() {
    return _tasks.snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList(),
    );
  }

  /// 🔹 CREATE
  Future<void> addTask({
    required String title,
    required DateTime dueDate,
    String status = 'todo',
    String description = '',
  }) async {
    await _tasks.add({
      'title': title,
      'description': description,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🔹 UPDATE
  Future<void> updateTask(
      String taskId,
      Map<String, dynamic> data,
      ) async {
    await _tasks.doc(taskId).update(data);
  }

  /// 🔹 DELETE
  Future<void> deleteTask(String taskId) async {
    await _tasks.doc(taskId).delete();
  }
}
