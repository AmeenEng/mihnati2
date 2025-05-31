import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mihnati2/auth/services/firebase_auth_methods.dart';
import 'package:provider/provider.dart';

class LoginController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorCode = '';

  Future<bool> handleLogin(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      errorCode = 'fillAllFields';
      return false;
    }

    try {
      final authMethods = context.read<FirebaseAuthMethods>();
      await authMethods.loginWithEmail(
        email: email,
        password: password,
        context: context,
        username: '',
      );
      return true;
    } on FirebaseAuthException catch (e) {
      errorCode = e.code;
      return false;
    } catch (e) {
      errorCode = 'loginError';
      return false;
    }
  }
}
