// login_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/auth/firebase_auth_methods.dart';
import 'package:mihnati2/auth/register/register_screen.dart';
import 'package:mihnati2/auth/verify_email_screen.dart';
import 'package:mihnati2/home.dart';
import 'package:provider/provider.dart';
import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _controller = LoginController();
  bool _secure = true;
  bool _rememberMe = false;
  String _errorMessage = ''; // إضافة متغير لحفظ رسالة الخطأ

  @override
  void dispose() {
    _controller.emailController.dispose();
    _controller.passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = '');

    final success = await _controller.handleLogin(context);

    if (success) {
      final user = context.read<FirebaseAuthMethods>().currentUser;
      if (user != null && !user.emailVerified) {
        Get.to(const VerifyEmailScreen());
      } else {
        Get.off(Home());
      }
    } else {
      setState(() {
        _errorMessage = _getErrorMessage(_controller.errorCode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                "assets/image/auth-Image/Secure login-rafiki.png",
                width: 300,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tr("login"),
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3440),
              ),
            ),
            Text(
              tr("loginSubtitle"),
              style: const TextStyle(color: Color(0xFF1F3440)),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _controller.emailController,
              icon: Icons.email,
              hint: tr("email"),
              obscure: false,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _controller.passwordController,
              icon: Icons.lock,
              hint: tr("enterPassword"),
              obscure: _secure,
              suffix: IconButton(
                icon: Icon(
                  _secure ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _secure = !_secure);
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                child: Text(
                  tr("forgotPassword"),
                  style: const TextStyle(
                    color: Color(0xFF1F3440),
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  // تنفيذ استعادة كلمة المرور مستقبلاً
                },
              ),
            ),
            // استخدام _errorMessage بدلاً من _controller.errorCode
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr("rememberMe")),
                Switch(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() => _rememberMe = value);
                  },
                  activeColor: const Color(0xFF70797E),
                  activeTrackColor: const Color(0xFF1F3440),
                  inactiveThumbColor: const Color(0xFFBABDBE),
                  inactiveTrackColor: const Color(0xFFD9E2E6),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildButton(tr("Login"), _handleLogin),
            const SizedBox(height: 15),
            _buildButton(
              tr("Login with Google"),
              () {
                // تنفيذ تسجيل الدخول بـ Google لاحقًا
              },
              icon: Image.asset("assets/icon/google.png", width: 20),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(tr("noAccount")),
                GestureDetector(
                  child: Text(
                    tr("signUp"),
                    style: const TextStyle(
                      color: Color(0xFF1F3440),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => Get.off(RegisterScreen()),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
    Widget? suffix,
  }) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFD4DADD),
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, {Widget? icon}) {
    return MaterialButton(
      color: const Color(0xFF1F3440),
      minWidth: double.infinity,
      height: 50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: const TextStyle(color: Colors.white)),
          if (icon != null) ...[
            const SizedBox(width: 10),
            icon,
          ]
        ],
      ),
    );
  }

  // تحسين دالة ترجمة رموز الأخطاء
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return tr('userNotFound');
      case 'wrong-password':
        return tr('wrongPassword');
      case 'invalid-email':
        return tr('invalidEmail');
      case 'fillAllFields':
        return tr('fillAllFields');
      case 'unknown-error':
      default:
        return tr('loginError');
    }
  }
}
