import 'task_status.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String assignee;
  final DateTime dueDate;
  final TaskStatus status;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignee,
    required this.dueDate,
    required this.status,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? assignee,
    DateTime? dueDate,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignee: assignee ?? this.assignee,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }

  /// Firestore → Task
  factory Task.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    return Task(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignee: data['assignee'] ?? '',
      dueDate: DateTime.parse(data['dueDate']),
      status: TaskStatusX.fromString(data['status']),
    );
  }

  /// Task → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'assignee': assignee,
      'dueDate': dueDate.toIso8601String(),
      'status': status.value,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
