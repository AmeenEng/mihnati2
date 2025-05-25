import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'register_model.dart';

class RegisterController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
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

  Future<bool> handleRegister() async {
    final username = usernameController.text;
    final mobile = mobileController.text;
    final password = passwordController.text;

    if (username.isEmpty || mobile.isEmpty || password.isEmpty) {
      error = tr("fillAllFields");
      return false;
    }

    if (!RegisterModel.validateMobile(mobile)) {
      error = tr("invalidMobileNumber");
      return false;
    }

    if (!RegisterModel.validatePassword(password)) {
      error = tr("lengthPassword");
      return false;
    }

    await RegisterModel.registerUser(username, mobile, password);
    error = '';
    return true;
  }

  void dispose() {
    usernameController.dispose();
    mobileController.dispose();
    passwordController.dispose();
  }
}
