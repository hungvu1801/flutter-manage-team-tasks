import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/task.dart';
import 'assignee_chip.dart';
import 'due_date.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFDFE1E6),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER (TITLE + ACTIONS)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF172B4D),
                  ),
                ),
              ),

              _RowActionIcon(
                icon: Icons.edit,
                color: const Color(0xFF5E6C84),
                tooltip: 'Edit',
                onTap: () {
                  context.push('/tasks/edit', extra: task);
                },
              ),
              const SizedBox(width: 6),
              _RowActionIcon(
                icon: Icons.delete_outline,
                color: Colors.redAccent,
                tooltip: 'Delete',
                onTap: () => _confirmDelete(context),
              ),
            ],
          ),

          /// DESCRIPTION
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF5E6C84),
              ),
            ),
          ],

          const SizedBox(height: 10),

          /// FOOTER
          Row(
            children: [
              /// ASSIGNEE
              AssigneeChip(name: task.assignee),

              const Spacer(),

              /// DUE DATE
              DueDate(date: task.dueDate),
            ],
          ),
        ],
      ),
    );
  }

  /// DELETE CONFIRM
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.of(context, rootNavigator: true).pop();
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

class _RowActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  const _RowActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 24,
          height: 24,
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }
}

