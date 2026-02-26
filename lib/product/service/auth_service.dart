import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static AuthService get instance => _instance;
  static final AuthService _instance = AuthService._internal();

  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    // If currentUser is already available, return immediately
    if (_auth.currentUser != null) return _auth.currentUser;

    // Wait for auth state to be determined (handles cold start)
    return await _auth.authStateChanges().firstWhere(
          (user) => true,
          orElse: () => null,
        );
  }
}
