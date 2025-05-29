import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/auth/firebase_auth_methods.dart';
import 'package:mihnati2/auth/login/login_screen.dart';
import 'package:provider/provider.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authMethods = context.read<FirebaseAuthMethods>();
    final user = authMethods.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('verifyEmail')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authMethods.signOut();
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
              tr('verifyEmailMessage', args: [user?.email ?? '']),
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => authMethods.sendEmailVerification(context),
              child: Text(tr('resendVerification')),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                authMethods.signOut();
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