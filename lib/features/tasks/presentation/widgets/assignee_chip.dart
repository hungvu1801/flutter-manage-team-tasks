import 'package:flutter/material.dart';

class AssigneeChip extends StatelessWidget {
  final String name;

  const AssigneeChip({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    if (name.isEmpty) {
      return const SizedBox.shrink();
    }
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: Colors.blueGrey[100],
        child: Text(
          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      label: Text(name),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
