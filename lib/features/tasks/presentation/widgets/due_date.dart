import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DueDate extends StatelessWidget {
  final DateTime date;

  const DueDate({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.MMMd().format(date);
    final isOverdue = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 16,
          color: isOverdue ? Colors.red : const Color(0xFF5E6C84),
        ),
        const SizedBox(width: 4),
        Text(
          formattedDate,
          style: TextStyle(
            fontSize: 13,
            color: isOverdue ? Colors.red : const Color(0xFF5E6C84),
          ),
        ),
      ],
    );
  }
}
