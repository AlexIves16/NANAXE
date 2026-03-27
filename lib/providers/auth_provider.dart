import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthNotifier(this._auth, this._googleSignIn) : super(const AsyncValue.data(null)) {
    // Слушаем изменения состояния аутентификации
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        state = AsyncValue.data(UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
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
      
      // Здесь можно создать/обновить пользователя в Firestore
      state = AsyncValue.data(UserModel(
        id: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        displayName: userCredential.user!.displayName,
        photoUrl: userCredential.user!.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } catch (e, st) {
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
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(FirebaseAuth.instance, GoogleSignIn());
});

final authStateProvider = Provider<AuthNotifier>((ref) {
  return ref.read(authProvider.notifier);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).value != null;
});
