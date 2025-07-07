import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/providers/auth_provider.dart';
import '../../utils/auth_error_handler.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import '../../Components/theme/theme_provider.dart';
import '../../Components/theme/app_colors.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Get.find<AuthProvider2>();
    final emailController = TextEditingController();
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final primaryColor = AppColors.primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('نسيت كلمة المرور'),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
            color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Image.asset(
                "assets/image/auth-Image/Forgot password-rafiki.png",
                height: 200,
              ),
              const SizedBox(height: 32),
              Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: emailController,
                hintText: 'البريد الإلكتروني',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            try {
                              await authProvider.resetPassword(
                                emailController.text,
                              );
                              Get.back();
                            } catch (e) {
                              AuthErrorHandler.showErrorSnackBar(
                                  AuthErrorHandler.getErrorMessage(e));
                            }
                          },
                    text: authProvider.isLoading
                        ? 'جاري الإرسال...'
                        : 'إرسال رابط إعادة التعيين',
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
