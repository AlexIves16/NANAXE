import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/firebase_config.dart';
import 'core/local_storage_service.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Загрузка переменных окружения
  await dotenv.load(fileName: ".env");

  // Инициализация Firebase
  await FirebaseConfig.initialize();

  // Инициализация локального хранилища
  await localStorageService.initialize();

  runApp(
    const ProviderScope(
      child: NanaxeCrmApp(),
    ),
  );
}

class NanaxeCrmApp extends StatelessWidget {
  const NanaxeCrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NANAXE CRM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
