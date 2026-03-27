import 'package:go_router/go_router.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/task_form_screen.dart';
import '../screens/mind_map_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/alarms_screen.dart';
import '../screens/ai_test_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth',
    routes: [
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'tasks',
            name: 'tasks',
            builder: (context, state) => const TasksScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'new-task',
                builder: (context, state) {
                  final args = state.extra as Map<String, dynamic>?;
                  return TaskFormScreen(
                    projectId: args?['projectId'] ?? 'default',
                  );
                },
              ),
              GoRoute(
                path: ':taskId',
                name: 'edit-task',
                builder: (context, state) {
                  final args = state.extra as Map<String, dynamic>?;
                  final task = args?['task'];
                  return TaskFormScreen(
                    task: task,
                    projectId: args?['projectId'] ?? 'default',
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'mindmap',
            name: 'mindmap',
            builder: (context, state) => const MindMapScreen(),
          ),
          GoRoute(
            path: 'calendar',
            name: 'calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: 'alarms',
            name: 'alarms',
            builder: (context, state) => const AlarmsScreen(),
          ),
          GoRoute(
            path: 'ai-test',
            name: 'ai-test',
            builder: (context, state) => const AiTestScreen(),
          ),
        ],
      ),
    ],
  );
}
