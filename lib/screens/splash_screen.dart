import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../auth/providers/auth_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());
    final authProvider = Get.find<AuthProvider2>();

    return Scaffold(
      body: Obx(() {
        if (!controller.isInitialized || authProvider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري التحميل...'),
              ],
            ),
          );
        }

        return const Center(
          child: Text('Mihnati'),
        );
      }),
    );
  }
}
