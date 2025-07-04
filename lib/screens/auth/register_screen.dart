import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // إضافة هذه السطر
import '../../auth/providers/auth_provider.dart';
import '../../routes.dart';
import '../../utils/auth_error_handler.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/social_auth_button.dart';
import '../auth/verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  bool _obscurePassword = true;

  // دالة جديدة للتعامل مع تسجيل الدخول بواسطة جوجل
  Future<void> _handleGoogleSignUp() async {
    final authProvider = Get.find<AuthProvider2>();
    try {
      await authProvider.signInWithGoogle();

      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        String accountType = await authProvider.getAccountType(uid);
        if (accountType == 'professional') {
          Get.offAllNamed(AppRoutes.professionalHome);
        } else {
          Get.offAllNamed(AppRoutes.clientHome);
        }
      } else {
        Get.offAllNamed(AppRoutes.clientHome);
      }
    } catch (e) {
      AuthErrorHandler.showErrorSnackBar(
        AuthErrorHandler.getErrorMessage(e),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Get.find<AuthProvider2>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width > 600 ? size.width * 0.2 : 16.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),
              Center(
                child: Image.asset(
                  "assets/image/auth-Image/Sign up-amico.png",
                  height: size.height * 0.25,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Text(
                'إنشاء حساب جديد',
                style: TextStyle(
                  fontSize: size.width > 400 ? 24 : 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.03),
              CustomTextField(
                controller: usernameController,
                hintText: 'اسم المستخدم',
                keyboardType: TextInputType.text,
                prefixIcon: Icons.person,
              ),
              SizedBox(height: size.height * 0.02),
              CustomTextField(
                controller: emailController,
                hintText: 'البريد الإلكتروني',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
              ),
              SizedBox(height: size.height * 0.02),
              CustomTextField(
                controller: passwordController,
                hintText: 'كلمة المرور',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              Obx(() => CustomButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            try {
                              await authProvider.signUp(
                                email: emailController.text,
                                password: passwordController.text,
                                username: usernameController.text,
                              );
                              Get.to(() => const VerifyEmailScreen());
                            } catch (e) {
                              AuthErrorHandler.showErrorSnackBar(
                                  AuthErrorHandler.getErrorMessage(e));
                            }
                          },
                    text: authProvider.isLoading
                        ? 'جاري إنشاء الحساب...'
                        : 'إنشاء حساب',
                  )),
              SizedBox(height: size.height * 0.02),
              SocialAuthButton(
                text: 'إنشاء حساب باستخدام Google',
                image: 'assets/icon/google.png',
                onPressed: _handleGoogleSignUp, // استخدام الدالة الجديدة
              ),
              SizedBox(height: size.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لديك حساب بالفعل؟',
                    style: TextStyle(fontSize: size.width > 400 ? 16 : 14),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.login),
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
