import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/auth/register/register_screen.dart';
import 'package:mihnati2/home.dart';
import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _controller = LoginController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final success = await _controller.handleLogin();
    if (success) {
      if (mounted) {
        Get.off(Home());
      }
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  "assets/image/auth-Image/Secure login-rafiki.png",
                  width: 300,
                ),
              ),
              Text(
                'login',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3440),
                ),
              ),
              Text(
                tr("loginSubtitle"),
                style: TextStyle(
                  color: Color(0xFF1F3440),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextFormField(
                  controller: _controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFD4DADD),
                    prefixIcon: const Icon(Icons.email),
                    hintText: tr("email"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextFormField(
                  controller: _controller.passwordController,
                  obscureText: _controller.secure,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFD4DADD),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _controller.secure
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller.showpassword();
                        });
                      },
                    ),
                    hintText: context.tr("enterPassword"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                child: Text(
                  "forgotPassword",
                  style: TextStyle(
                    color: Color(0xFF1F3440),
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  // TODO: Implement forgot password
                },
              ),
              const SizedBox(height: 10),
              if (_controller.error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _controller.error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr("rememberMe")),
                  Switch(
                    activeColor: const Color(0xFF70797E),
                    activeTrackColor: const Color(0xFF1F3440),
                    inactiveThumbColor: const Color(0xFFBABDBE),
                    inactiveTrackColor: const Color(0xFFD9E2E6),
                    value: _controller.rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _controller.rememberMethod(value);
                      });
                    },
                  )
                ],
              ),
              const SizedBox(height: 15),
              MaterialButton(
                color: const Color(0xFF1F3440),
                minWidth: double.infinity,
                height: 50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                onPressed: _handleLogin,
                child: Text(
                  tr("Login"),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              MaterialButton(
                color: const Color(0xFF1F3440),
                minWidth: double.infinity,
                height: 50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                onPressed: () {
                  // TODO: Implement Google Sign In
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tr("Login with Google"),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 20),
                    Image.asset(
                      "assets/icon/google.png",
                      width: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tr("noAccount")),
                  GestureDetector(
                    child: Text(
                      tr("signUp"),
                      style: TextStyle(
                        color: Color(0xFF1F3440),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Get.off(RegisterScreen());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
