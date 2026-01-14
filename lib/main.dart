import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'features/charts/presentation/pages/charts_page.dart';
import 'features/tasks/presentation/pages/create_task_page.dart';
import 'firebase_options.dart';
import 'shell/main_shell.dart';
import 'features/tasks/presentation/pages/task_board_page.dart';
import 'features/calendar/calendar_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final router = GoRouter(
  initialLocation: '/tasks',
  routes: [
    ShellRoute(
      builder: (_, __, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/tasks',
          builder: (_, __) => const TaskBoardPage(),
          routes: [
            GoRoute(
              path: 'create', // 👈 ROUTE CON
              builder: (_, __) => const CreateTaskPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/calendar',
          builder: (_, __) => const CalendarPage(),
        ),
        GoRoute(
          path: '/charts',
          builder: (_, __) => const ChartsPage(),
        ),
      ],
    ),
  ],
);


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
