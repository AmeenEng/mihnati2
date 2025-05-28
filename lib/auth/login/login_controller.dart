import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool secure = true;
  bool rememberMe = false;
  String error = '';

  void showpassword() {
    secure = !secure;
  }

  void rememberMethod(bool value) {
    rememberMe = value;
  }

  Future<bool> handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      error = tr("fillAllFields");
      return false;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      error = '';
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          error = tr("noUserFound");
          break;
        case 'wrong-password':
          error = tr("wrongPassword");
          break;
        case 'invalid-email':
          error = tr("invalidEmail");
          break;
        case 'user-disabled':
          error = tr("userDisabled");
          break;
        default:
          error = tr("loginError");
      }
      return false;
    } catch (e) {
      error = tr("loginError");
      return false;
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
