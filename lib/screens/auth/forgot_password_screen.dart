import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/providers/auth_provider.dart';
import '../../utils/auth_error_handler.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Get.find<AuthProvider2>();
    final emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('نسيت كلمة المرور'),
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
              const Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور',
                style: TextStyle(
                  color: Colors.grey,
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
