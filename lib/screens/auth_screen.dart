import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.business_center,
                  size: 120,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),
                const Text(
                  'NANAXE CRM',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'CRM-ассистент для команд',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),
                authState.when(
                  data: (user) {
                    if (user != null) {
                      // Пользователь авторизован - переходим на главную
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.go('/home');
                      });
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: authNotifier.isLoggedIn
                      ? null
                      : () {
                          authNotifier.signInWithGoogle();
                        },
                  icon: const Icon(Icons.login),
                  label: const Text('Войти через Google'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                if (authNotifier.isLoggedIn) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => authNotifier.signOut(),
                    icon: const Icon(Icons.logout),
                    label: const Text('Выйти'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
