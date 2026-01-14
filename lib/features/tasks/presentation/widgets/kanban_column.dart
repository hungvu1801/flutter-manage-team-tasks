import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../domain/task.dart';
import '../../domain/task_status.dart';
import 'task_card.dart';

typedef OnTaskDropped = void Function(
    Task task,
    TaskStatus newStatus, {
    int? insertIndex,
    });

class KanbanColumn extends StatefulWidget {
  final String title;
  final TaskStatus status;
  final List<Task> tasks;
  final OnTaskDropped onTaskDropped;
  final ValueChanged<Task> onDelete;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.status,
    required this.tasks,
    required this.onTaskDropped,
    required this.onDelete,
  });

  @override
  State<KanbanColumn> createState() => _KanbanColumnState();
}


class KanbanColors {
  static const Map<TaskStatus, Color> background = {
    TaskStatus.todo: Color(0xFFECEFF1),
    TaskStatus.inProgress: Color(0xFFE3F2FD),
    TaskStatus.done: Color(0xFFE8F5E9),
  };

  static const Map<TaskStatus, Color> header = {
    TaskStatus.todo: Color(0xFFB0BEC5),
    TaskStatus.inProgress: Color(0xFF42A5F5),
    TaskStatus.done: Color(0xFF66BB6A),
  };
}

class _KanbanColumnState extends State<KanbanColumn> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return DragTarget<Task>(
      onWillAccept: (task) {
        final accept = task != null && task.status != widget.status;
        if (accept) setState(() => _isDragOver = true);
        return accept;
      },
      onLeave: (_) => setState(() => _isDragOver = false),
      onAccept: (task) {
        setState(() => _isDragOver = false);
        widget.onTaskDropped(task, widget.status);
      },
      builder: (_, __, ___) {
        return Container(
          width: 280,
          margin: const EdgeInsets.only(right: 16, top: 64),
          child: DottedBorder(
            color: _isDragOver ? Colors.blue : Colors.transparent,
            strokeWidth: 2,
            dashPattern: const [6, 6],
            radius: const Radius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: KanbanColors.background[widget.status],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ColumnHeader(
                    title: widget.title,
                    taskCount: widget.tasks.length,
                    status: widget.status,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: screenHeight * 0.65,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: widget.tasks.length,
                      itemBuilder: (_, index) {
                        final task = widget.tasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Draggable<Task>(
                            data: task,
                            feedback: Material(
                              elevation: 4,
                              child: SizedBox(
                                width: 260,
                                child: TaskCard(task: task, onDelete: () => widget.onDelete(task)),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: TaskCard(task: task, onDelete: () => widget.onDelete(task)),
                            ),
                            child: TaskCard(task: task, onDelete: () => widget.onDelete(task)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  final String title;
  final int taskCount;
  final TaskStatus status;

  const _ColumnHeader({
    required this.title,
    required this.taskCount,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF42526E),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: KanbanColors.header[status],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            taskCount.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
