import '../domain/task.dart';
import '../domain/task_status.dart';

// Make the list mutable by removing 'final'
List<Task> mockTasks = [
  Task(
    id: '1',
    title: 'Design login screen',
    description: 'Create UI/UX for login screen including validation states',
    assignee: 'Alice',
    dueDate: DateTime.now().add(const Duration(days: 2)),
    status: TaskStatus.todo,
  ),
  Task(
    id: '2',
    title: 'Setup Firebase',
    description: 'Configure Firebase project, auth and environment setup',
    assignee: 'Bob',
    dueDate: DateTime.now().add(const Duration(days: 3)),
    status: TaskStatus.todo,
  ),
  Task(
    id: '3',
    title: 'Implement auth flow',
    description: 'Implement login, logout and session persistence',
    assignee: 'Alice',
    dueDate: DateTime.now().add(const Duration(days: 1)),
    status: TaskStatus.inProgress,
  ),
  Task(
    id: '4',
    title: 'Fix UI bugs',
    description: 'Resolve layout, overflow and responsiveness issues',
    assignee: 'Charlie',
    dueDate: DateTime.now().subtract(const Duration(days: 1)), // overdue demo
    status: TaskStatus.inProgress,
  ),
  Task(
    id: '5',
    title: 'Release v1.0',
    description: 'Prepare release build and publish to production',
    assignee: 'Bob',
    dueDate: DateTime.now().add(const Duration(days: 5)),
    status: TaskStatus.done,
  ),
];
