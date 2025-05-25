import 'package:shared_preferences/shared_preferences.dart';

class RegisterModel {
  final String username;
  final String mobile;
  final String password;
  final bool rememberMe;

  const RegisterModel({
    required this.username,
    required this.mobile,
    required this.password,
    this.rememberMe = false,
  });

  static Future<void> registerUser(
      String username, String mobile, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username.trim());
    await prefs.setString('mobile', mobile.trim());
    await prefs.setString('password', password.trim());
  }

  static bool validateMobile(String mobile) {
    return mobile.trim().length == 9;
  }

  static bool validatePassword(String password) {
    return password.trim().length >= 6;
  }
}
