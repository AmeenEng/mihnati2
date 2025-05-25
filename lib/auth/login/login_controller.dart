import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'login_model.dart';

class LoginController {
  final TextEditingController usernameController = TextEditingController();
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
    final username = usernameController.text;
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      error = tr("fillAllFields");
      return false;
    }

    final isValid = await LoginModel.validateCredentials(username, password);
    if (!isValid) {
      error = tr("invalidCredentials");
      return false;
    }

    error = '';
    return true;
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}
