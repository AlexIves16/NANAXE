import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthNotifier(this._auth, this._googleSignIn, this._firestore)
      : super(const AsyncValue.data(null)) {
    // Слушаем изменения состояния аутентификации
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        // Загружаем или создаём пользователя в Firestore
        try {
          final userDoc =
              await _firestore.collection('users').doc(user.uid).get();

          if (userDoc.exists) {
            // Пользователь уже есть
            state = AsyncValue.data(UserModel.fromFirestore(userDoc));
          } else {
            // Создаём нового пользователя
            final newUser = UserModel(
              id: user.uid,
              email: user.email ?? '',
              displayName: user.displayName,
              photoUrl: user.photoURL,
              role: UserRole.member,
              teamIds: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              settings: {
                'theme': 'system',
                'notifications': true,
                'language': 'ru',
              },
            );

            await _firestore
                .collection('users')
                .doc(user.uid)
                .set(newUser.toFirestore());
            state = AsyncValue.data(newUser);
          }
        } catch (e) {
          print('Error loading user from Firestore: $e');
          // Создаём временного пользователя
          state = AsyncValue.data(UserModel(
            id: user.uid,
            email: user.email ?? '',
            displayName: user.displayName,
            photoUrl: user.photoURL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        }
      } else {
        state = const AsyncValue.data(null);
      }
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Пользователь будет загружен через authStateChanges listener
      print('Signed in: ${userCredential.user?.email}');
    } catch (e, st) {
      print('Google Sign-In Error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String? get userId => _auth.currentUser?.uid;
}

// Provider для аутентификации
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(
    FirebaseAuth.instance,
    GoogleSignIn(),
    FirebaseFirestore.instance,
  );
});

// Provider для текущего пользователя
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).value;
});

// Provider для текущего userId
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).value?.id;
});

// Provider для проверки авторизации
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).value != null;
});

// Provider для роли пользователя
final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authProvider).value?.role;
});

// Provider для проверки является ли пользователь админом
final isAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == UserRole.admin;
});
