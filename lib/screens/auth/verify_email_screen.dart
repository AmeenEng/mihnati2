import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/auth/auth_provider.dart';
import 'package:mihnati2/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(tr('noUserFound'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('verifyEmail')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.signOut();
              Get.offAll(const LoginScreen());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tr('verifyEmailMessage', args: [user.email ?? '']),
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await authProvider.sendEmailVerification(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tr('verificationEmailSent'))),
                );
              },
              child: Text(tr('resendVerification')),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                authProvider.signOut();
                Get.offAll(const LoginScreen());
              },
              child: Text(tr('signOut')),
            ),
          ],
        ),
      ),
    );
  }
}
