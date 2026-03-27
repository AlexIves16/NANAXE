import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/task_form_screen.dart';
import '../screens/mind_map_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/alarms_screen.dart';
import '../screens/ai_test_screen.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/admin/team_management_screen.dart';
import '../screens/admin/projects_management_screen.dart';
import '../screens/admin/notifications_settings_screen.dart';
import '../providers/auth_provider.dart';

// Глобальный ключ для навигации
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/auth',
    refreshListenable: GoRouterRefreshNotifier(),
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
          GoRoute(
            path: 'admin',
            name: 'admin',
            builder: (context, state) => const AdminScreen(),
            routes: [
              GoRoute(
                path: 'team',
                name: 'admin-team',
                builder: (context, state) => const TeamManagementScreen(),
              ),
              GoRoute(
                path: 'projects',
                name: 'admin-projects',
                builder: (context, state) => const ProjectsManagementScreen(),
              ),
              GoRoute(
                path: 'notifications',
                name: 'admin-notifications',
                builder: (context, state) =>
                    const NotificationsSettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = GoRouterRefreshNotifier.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/auth';

      if (!isLoggedIn && !isLoggingIn) {
        return '/auth';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      return null;
    },
  );
}

// Класс для уведомления об изменении состояния аутентификации
class GoRouterRefreshNotifier extends ChangeNotifier {
  static bool isAuthenticated = false;

  GoRouterRefreshNotifier() {
    // Подписка на изменения аутентификации будет добавлена через provider
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Provider для обновления роутера при изменении аутентификации
final routerRefreshProvider = ChangeNotifierProvider((ref) {
  final auth = ref.watch(authProvider);

  auth.whenData((user) {
    GoRouterRefreshNotifier.isAuthenticated = user != null;
  });

  return GoRouterRefreshNotifier();
});
