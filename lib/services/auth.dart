import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_application/models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Convert Firebase User to custom User model
  User? _userFromFirebaseUser(firebase_auth.User? user) {
    return user != null ? User(uid: user.uid, email: user.email ?? '', displayName: user.displayName ?? '') : null;
  }

  // Auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      firebase_auth.UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      firebase_auth.User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      firebase_auth.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      firebase_auth.User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}