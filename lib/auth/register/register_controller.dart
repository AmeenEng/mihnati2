import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mihnati2/auth/firebase_auth_methods.dart';
import 'package:provider/provider.dart';

class RegisterController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool secure = true;
  bool confirmSecure = true;
  String error = '';

  void showPassword() {
    secure = !secure;
  }

  void showConfirmPassword() {
    confirmSecure = !confirmSecure;
  }

  bool validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool validatePassword(String password) {
    return password.length >= 6;
  }

  Future<bool> handleRegister(BuildContext context) async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      error = tr("fillAllFields");
      return false;
    }

    if (!validateEmail(email)) {
      error = tr("invalidEmail");
      return false;
    }

    if (!validatePassword(password)) {
      error = tr("lengthPassword");
      return false;
    }

    if (password != confirmPassword) {
      error = tr("passwordsDoNotMatch");
      return false;
    }

    try {
      final authMethods = context.read<FirebaseAuthMethods>();
      await authMethods.signUpWithEmail(
        email: email,
        password: password,
        context: context, username: '',
      );

      // تحديث اسم المستخدم
      await authMethods.currentUser?.updateDisplayName(username);

      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          error = tr("weakPassword");
          break;
        case 'email-already-in-use':
          error = tr("emailAlreadyInUse");
          break;
        case 'invalid-email':
          error = tr("invalidEmail");
          break;
        default:
          error = tr("registrationError");
      }
      return false;
    } catch (e) {
      error = tr("registrationError");
      return false;
    }
  }

  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}
