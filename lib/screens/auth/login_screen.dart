import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/screens/auth/forgot_password_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../routes.dart';
import '../../utils/auth_error_handler.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/social_auth_button.dart';
import 'package:firebase_auth/firebase_auth.dart'; // إضافة هذه السطر

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool rememberMe = false;

  Future<void> _handleLogin() async {
    final authProvider = Get.find<AuthProvider2>();
    if (authProvider.isLoading) return;

    try {
      await authProvider.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
      
      // الحصول على uid للمستخدم الحالي
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        // التحقق من نوع الحساب
        String accountType = await authProvider.getAccountType(uid);
        
        // إعادة التوجيه بناءً على النوع
        if (accountType == 'professional') {
          Get.offAllNamed(AppRoutes.professionalHome);
        } else {
          Get.offAllNamed(AppRoutes.clientHome);
        }
      } else {
        // إذا لم يتم الحصول على uid، نعيد التوجيه للصفحة الافتراضية
        Get.offAllNamed(AppRoutes.clientHome);
      }
    } catch (e) {
      AuthErrorHandler.showErrorSnackBar(
        AuthErrorHandler.getErrorMessage(e),
      );
    }
  }

  // دالة جديدة للتعامل مع تسجيل الدخول بواسطة جوجل
  Future<void> _handleGoogleLogin() async {
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
      backgroundColor: Colors.white,
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
                "تسجيل الدخول",
                style: TextStyle(
                  fontSize: size.width > 400 ? 30 : 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F3440),
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                "يرجى تسجيل الدخول للمتابعة",
                style: TextStyle(
                  fontSize: size.width > 400 ? 16 : 14,
                  color: const Color(0xFF1F3440)),
              ),
              SizedBox(height: size.height * 0.03),
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
                    _obscurePassword 
                      ? Icons.visibility_off 
                      : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Get.to(() => const ForgotPasswordScreen()),
                  child: const Text('نسيت كلمة المرور؟'),
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "تذكرني في المرة القادمة",
                    style: TextStyle(fontSize: size.width > 400 ? 16 : 14),
                  ),
                  Switch(
                    activeColor: const Color(0xFF70797E),
                    activeTrackColor: const Color(0xFF1F3440),
                    inactiveThumbColor: const Color(0xFFBABDBE),
                    inactiveTrackColor: const Color(0xFFD9E2E6),
                    value: rememberMe,
                    onChanged: (value) => setState(() => rememberMe = value),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.03),
              Obx(() => CustomButton(
                onPressed: authProvider.isLoading
                    ? null
                    : _handleLogin, // استخدام الدالة الجديدة
                text: authProvider.isLoading
                    ? 'جاري تسجيل الدخول...'
                    : 'تسجيل الدخول',
              )),
              SizedBox(height: size.height * 0.02),
              SocialAuthButton(
                onPressed: _handleGoogleLogin, // استخدام الدالة الجديدة
                text: 'تسجيل الدخول باستخدام Google',
                image: "assets/icon/google.png",
              ),
              SizedBox(height: size.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ليس لديك حساب؟',
                    style: TextStyle(fontSize: size.width > 400 ? 16 : 14),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.register),
                    child: const Text(
                      'إنشاء حساب',
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