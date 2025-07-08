import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/auth/providers/auth_provider.dart';
import 'package:mihnati2/screens/auth/CompleteProfileScreen.dart';
// import 'package:mihnati2/screens/home/home_screen.dart';
import 'package:mihnati2/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import '../../Components/theme/theme_provider.dart';
import '../../Components/theme/app_colors.dart';

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
  final int _maxCheckAttempts = 12;

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final primaryColor = AppColors.primaryColor;

    if (user == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
            child: Text('لم يتم العثور على مستخدم',
                style: TextStyle(color: textColor))),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: primaryColor),
        title: Text('تأكيد البريد الإلكتروني',
            style: TextStyle(color: primaryColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: primaryColor,
            onPressed: () {
              authProvider.signOut();
              Get.offAll(const LoginScreen());
            },
          ),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_unread_outlined,
              size: 100,
              color: primaryColor,
            ),
            const SizedBox(height: 30),
            Text(
              'تم إرسال رسالة تأكيد إلى بريدك الإلكتروني:\n${user.email ?? ''}\nيرجى التحقق من بريدك وتأكيد الحساب.',
              style: TextStyle(fontSize: 18, color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_isChecking)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text('جاري التحقق من التفعيل...',
                      style: TextStyle(color: textColor)),
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
              label: Text(_isResending
                  ? 'جاري إعادة الإرسال...'
                  : 'إعادة إرسال رسالة التأكيد'),
              onPressed: _isResending ? null : _resendVerification,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
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
                  Text('التحقق يدوياً', style: TextStyle(color: primaryColor)),
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
              style: OutlinedButton.styleFrom(foregroundColor: primaryColor),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}
