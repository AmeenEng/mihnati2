import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/screens/auth/forgot_password_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../routes.dart';
import '../../utils/auth_error_handler.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/social_auth_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../Components/theme/theme_provider.dart';
import '../../Components/theme/app_colors.dart';

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authProvider = Get.find<AuthProvider2>();
    if (authProvider.isLoading) return;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await authProvider.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (Get.isDialogOpen!) Get.back();

        final accountType = await authProvider.getAccountType(user.uid);
        Get.offAllNamed(accountType == 'professional'
            ? AppRoutes.professionalHome
            : AppRoutes.clientHome);
      }
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      AuthErrorHandler.showErrorSnackBar(
        AuthErrorHandler.getErrorMessage(e),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    final authProvider = Get.find<AuthProvider2>();
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await authProvider.signInWithGoogle();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (Get.isDialogOpen!) Get.back();

        final accountType = await authProvider.getAccountType(user.uid);
        Get.offAllNamed(accountType == 'professional'
            ? AppRoutes.professionalHome
            : AppRoutes.clientHome);
      } else {
        if (Get.isDialogOpen!) Get.back();
        Get.offAllNamed(AppRoutes.clientHome);
      }
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      AuthErrorHandler.showErrorSnackBar(
        AuthErrorHandler.getErrorMessage(e),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Get.find<AuthProvider2>();
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final primaryColor = AppColors.primaryColor;
    return Scaffold(
      backgroundColor: backgroundColor,
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
                  color: primaryColor,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                "يرجى تسجيل الدخول للمتابعة",
                style: TextStyle(
                    fontSize: size.width > 400 ? 16 : 14, color: textColor),
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
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: isDark ? AppColors.darkIcon : AppColors.lightIcon,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Get.to(() => const ForgotPasswordScreen()),
                  child: Text('نسيت كلمة المرور؟',
                      style: TextStyle(color: primaryColor)),
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "تذكرني في المرة القادمة",
                    style: TextStyle(
                        fontSize: size.width > 400 ? 16 : 14, color: textColor),
                  ),
                  Switch(
                    activeColor: primaryColor,
                    activeTrackColor: primaryColor.withOpacity(0.5),
                    inactiveThumbColor: cardColor,
                    inactiveTrackColor: cardColor.withOpacity(0.5),
                    value: rememberMe,
                    onChanged: (value) => setState(() => rememberMe = value),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.03),
              Obx(() => CustomButton(
                    onPressed: authProvider.isLoading ? null : _handleLogin,
                    text: authProvider.isLoading
                        ? 'جاري تسجيل الدخول...'
                        : 'تسجيل الدخول',
                  )),
              SizedBox(height: size.height * 0.02),
              SocialAuthButton(
                onPressed: _handleGoogleLogin,
                text: 'تسجيل الدخول باستخدام Google',
                image: "assets/icon/google.png",
              ),
              SizedBox(height: size.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ليس لديك حساب؟',
                    style: TextStyle(
                        fontSize: size.width > 400 ? 16 : 14, color: textColor),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.register),
                    child: Text(
                      'إنشاء حساب',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: primaryColor),
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
