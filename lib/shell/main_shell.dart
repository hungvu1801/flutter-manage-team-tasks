import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/charts')) return 2;
    return 0; // /tasks
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/tasks');
        break;
      case 1:
        context.go('/calendar');
        break;
      case 2:
        context.go('/charts');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_kanban),
            label: 'Board',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Charts',
          ),
        ],
      ),
    );
  }
}
