import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mihnati2/auth/services/firebase_auth_methods.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthMethods _authMethods = FirebaseAuthMethods();
  User? _user;
  bool _isLoading = false;
  late final StreamSubscription<User?> _authSubscription;

  AuthProvider() {
    _user = _authMethods.currentUser;
    _init();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  void _init() {
    _authSubscription = _authMethods.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authMethods.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        context: context,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required String username,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authMethods.loginWithEmail(
        email: email,
        password: password,
        username: username,
        context: context,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authMethods.signInWithGoogle();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authMethods.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authMethods.resetPassword(
        email: email,
        context: context,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authMethods.deleteAccount();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendEmailVerification(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authMethods.sendEmailVerification(context);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }
}
