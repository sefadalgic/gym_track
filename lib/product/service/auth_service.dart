import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static AuthService get instance => _instance;
  static final AuthService _instance = AuthService._internal();

  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
}
