import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../services/task_firestore_service.dart';
import '../../../tasks/domain/task.dart';
import '../../../tasks/domain/task_status.dart';

class ChartsPage extends StatelessWidget {
  const ChartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskService = TaskFirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts & Statistics'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF4F5F7),
      body: StreamBuilder<List<Task>>(
        stream: taskService.watchTasks(),
        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // EMPTY
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No tasks to display charts.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // DATA
          return _ChartsContent(tasks: snapshot.data!);
        },
      ),
    );
  }
}

/* ========================== CONTENT ========================== */

class _ChartsContent extends StatelessWidget {
  final List<Task> tasks;
  const _ChartsContent({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TasksStatusPieChart(tasks: tasks),
        const SizedBox(height: 16),
        _AssigneeTasksBarChart(tasks: tasks),
      ],
    );
  }
}

/* ========================== PIE CHART ========================== */

class _TasksStatusPieChart extends StatefulWidget {
  final List<Task> tasks;
  const _TasksStatusPieChart({required this.tasks});

  @override
  State<_TasksStatusPieChart> createState() => _TasksStatusPieChartState();
}

class _TasksStatusPieChartState extends State<_TasksStatusPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final counts = <TaskStatus, int>{
      TaskStatus.todo: 0,
      TaskStatus.inProgress: 0,
      TaskStatus.done: 0,
    };

    for (final t in widget.tasks) {
      counts[t.status] = counts[t.status]! + 1;
    }

    final statusMeta = <TaskStatus, _StatusMeta>{
      TaskStatus.todo:
      const _StatusMeta('To Do', Color(0xFFB0BEC5)),
      TaskStatus.inProgress:
      const _StatusMeta('In Progress', Color(0xFF42A5F5)),
      TaskStatus.done:
      const _StatusMeta('Done', Color(0xFF66BB6A)),
    };

    final keys = statusMeta.keys.toList();

    return _Card(
      title: 'Tasks by Status',
      child: SizedBox(
        height: 220,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 36,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        touchedIndex =
                            response?.touchedSection?.touchedSectionIndex ?? -1;
                      });
                    },
                  ),
                  sections: List.generate(keys.length, (i) {
                    final status = keys[i];
                    final count = counts[status]!;
                    final isTouched = i == touchedIndex;

                    return PieChartSectionData(
                      color: statusMeta[status]!.color,
                      value: count.toDouble(),
                      radius: isTouched ? 60 : 50,
                      title: count.toString(),
                      titleStyle: TextStyle(
                        fontSize: isTouched ? 18 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: statusMeta.values
                    .map(
                      (e) => Indicator(
                    color: e.color,
                    text: e.label,
                    isSquare: false,
                    size: 14,
                  ),
                )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ========================== BAR CHART ========================== */

class _AssigneeTasksBarChart extends StatelessWidget {
  final List<Task> tasks;
  const _AssigneeTasksBarChart({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> counts = {};

    for (final t in tasks) {
      if (t.assignee.isNotEmpty) {
        counts[t.assignee] = (counts[t.assignee] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return const SizedBox.shrink();

    final data = counts.entries.toList();
    final maxY =
        data.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 1;

    return _Card(
      title: 'Tasks per Assignee',
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            maxY: maxY.toDouble(),
            alignment: BarChartAlignment.spaceBetween,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= data.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        data[index].key,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: data.asMap().entries.map((entry) {
              final index = entry.key;
              final count = entry.value.value;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: count.toDouble(),
                    width: 28,
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF36B37E),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY.toDouble(),
                      color: const Color(0xFFE6FCF5),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/* ========================== SHARED ========================== */

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;

  const Indicator({
    super.key,
    required this.color,
    required this.text,
    this.isSquare = true,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatusMeta {
  final String label;
  final Color color;
  const _StatusMeta(this.label, this.color);
}
