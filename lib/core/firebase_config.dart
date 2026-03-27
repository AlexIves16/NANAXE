import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  }

  static Future<void> setupFirestore() async {
    // Настройки Firestore для лучшей производительности
    // Будут применены после инициализации
  }
}
