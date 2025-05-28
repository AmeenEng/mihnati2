import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/auth/login/login_screen.dart';
import 'package:mihnati2/home.dart';
import 'register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterController _controller = RegisterController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final success = await _controller.handleRegister();
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
                  "assets/image/auth-Image/Sign up-bro.png",
                  width: 300,
                ),
              ),
              Text(
                tr("signUp"),
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3440),
                ),
              ),
              Text(
                tr("signUpSubtitle"),
                style: TextStyle(
                  color: Color(0xFF1F3440),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextFormField(
                  controller: _controller.usernameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFD4DADD),
                    prefixIcon: const Icon(Icons.person),
                    hintText: tr("userName"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
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
              const SizedBox(height: 10),
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
                          _controller.showPassword();
                        });
                      },
                    ),
                    hintText: tr("password"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextFormField(
                  controller: _controller.confirmPasswordController,
                  obscureText: _controller.confirmSecure,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFD4DADD),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _controller.confirmSecure
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller.showConfirmPassword();
                        });
                      },
                    ),
                    hintText: tr("confirmPassword"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
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
              const SizedBox(height: 8),
              MaterialButton(
                color: const Color(0xFF1F3440),
                minWidth: double.infinity,
                height: 50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                onPressed: _handleRegister,
                child: Text(
                  tr("registerButton"),
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
                      tr("SignUp with Google"),
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
                  Text(tr("haveAccount")),
                  GestureDetector(
                    child: Text(
                      tr("login"),
                      style: TextStyle(
                        color: Color(0xFF1F3440),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Get.off(LoginScreen());
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
