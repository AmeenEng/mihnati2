import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/auth/providers/auth_provider.dart';
import 'package:mihnati2/screens/auth/CompleteProfileScreen.dart';
import 'package:mihnati2/screens/home/home_screen.dart';
import 'package:mihnati2/screens/auth/login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthProvider2 authProvider = Get.find<AuthProvider2>();
  Timer? _verificationTimer;
  bool _isResending = false;
  bool _isChecking = false;
  int _checkAttempts = 0;
  final int _maxCheckAttempts = 12; // دقيقة واحدة كحد أقصى (12 × 5 ثواني)

  @override
  void initState() {
    super.initState();
    _sendInitialVerification();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  void _setStateSafe(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }

  void _startVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _checkAttempts >= _maxCheckAttempts) {
        timer.cancel();
        return;
      }
      _checkAttempts++;
      _checkVerificationStatus();
    });
  }

  Future<void> _sendInitialVerification() async {
    final user = authProvider.user;
    if (user != null && !user.emailVerified) {
      _setStateSafe(() => _isResending = true);
      try {
        await authProvider.sendEmailVerification();
      } finally {
        _setStateSafe(() => _isResending = false);
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    if (_isChecking || !mounted) return;

    _setStateSafe(() => _isChecking = true);

    try {
      await authProvider.user?.reload(); // تحديث بيانات المستخدم
      await authProvider.checkEmailVerification();

      if (authProvider.user?.emailVerified ?? false) {
        _verificationTimer?.cancel();
        // الانتقال إلى شاشة إكمال الملف الشخصي
        Get.offAll(() => const CompleteProfileScreen());
      }
    } catch (e) {
      debugPrint('Verification check failed: $e');
    } finally {
      _setStateSafe(() => _isChecking = false);
    }
  }

  Future<void> _resendVerification() async {
    _setStateSafe(() => _isResending = true);

    try {
      await authProvider.sendEmailVerification();
      Get.snackbar(
        tr('success'),
        tr('verificationEmailSent'),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        tr('error'),
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setStateSafe(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Icon(
              Icons.mark_email_unread_outlined,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 30),
            Text(
              tr('verifyEmailMessage', args: [user.email ?? '']),
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_isChecking)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(tr('checkingVerification')),
                ],
              ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: _isResending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.email_outlined),
              label: Text(
                  _isResending ? tr('resending') : tr('resendVerification')),
              onPressed: _isResending ? null : _resendVerification,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _checkVerificationStatus();
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tr('checkManually')),
                  if (_isChecking)
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
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
