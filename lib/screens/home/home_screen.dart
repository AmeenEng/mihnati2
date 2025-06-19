import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/providers/auth_provider.dart';
import '../../utils/auth_error_handler.dart';
import '../../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Get.find<AuthProvider2>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await authProvider.signOut();
              } catch (e) {
                AuthErrorHandler.showErrorSnackBar(
                    AuthErrorHandler.getErrorMessage(e));
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Image.asset(
              //   "assets/image/auth-Image/Home-amico.png",
              //   height: 200,
              // ),
              const SizedBox(height: 32),
              const Text(
                'مرحبًا بك في تطبيق مهنتي',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'يمكنك الآن استخدام التطبيق',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Obx(() => Text(
                    'البريد الإلكتروني: ${authProvider.user?.email ?? "غير متوفر"}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: 16),
              Obx(() => Text(
                    'تم التحقق من البريد الإلكتروني: ${authProvider.user?.emailVerified ?? false ? "نعم" : "لا"}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: () async {
                  try {
                    await authProvider.signOut();
                  } catch (e) {
                    AuthErrorHandler.showErrorSnackBar(
                        AuthErrorHandler.getErrorMessage(e));
                  }
                },
                text: 'تسجيل الخروج',
                backgroundColor: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
