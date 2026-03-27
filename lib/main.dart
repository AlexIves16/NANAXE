import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/firebase_config.dart';
import 'core/local_storage_service.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase
  await FirebaseConfig.initialize();

  // Инициализация локального хранилища
  await localStorageService.initialize();

  runApp(
    const ProviderScope(
      child: NanahuiCrmApp(),
    ),
  );
}

class NanahuiCrmApp extends StatelessWidget {
  const NanahuiCrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NANAHUI CRM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
