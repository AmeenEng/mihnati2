import 'package:shared_preferences/shared_preferences.dart';

class LoginModel {
  final String username;
  final String password;
  final bool rememberMe;

  const LoginModel({
    required this.username,
    required this.password,
    this.rememberMe = false,
  });

  static Future<bool> validateCredentials(
      String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedUsername = prefs.getString('username') ?? '';
    String savedPassword = prefs.getString('password') ?? '';

    return username.trim() == savedUsername && password.trim() == savedPassword;
  }

  static Future<void> storeUserData(String username, String mobile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('mobile', mobile);
  }
}
