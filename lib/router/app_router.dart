import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/tasks/domain/task.dart';
import '../features/tasks/presentation/pages/create_task_page.dart';
import '../features/tasks/presentation/pages/task_board_page.dart';
import '../shell/main_shell.dart';
import '../features/calendar/calendar_page.dart';
import '../features/charts/presentation/pages/charts_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      redirect: (_, __) => '/tasks',
    ),

    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TaskBoardPage(),
          routes: [
            GoRoute(
              path: 'create',
              pageBuilder: (context, state) {
                final task = state.extra as Task?;
                return MaterialPage(
                  fullscreenDialog: true,
                  child: CreateTaskPage(task: task),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarPage(),
        ),
        GoRoute(
          path: '/charts',
          builder: (context, state) => const ChartsPage(),
        ),
      ],
    ),
  ],
);

