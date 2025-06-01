import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mihnati2/auth/auth_provider.dart';
import 'package:mihnati2/screens/auth/login_screen.dart';
import 'package:mihnati2/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;
  Timer? _verificationTimer;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkEmailVerification();
    });
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerification() async {
    if (!mounted) return;

    setState(() {
      _isChecking = true;
    });

    try {
      await firebase_auth.FirebaseAuth.instance.currentUser?.reload();
      final user = firebase_auth.FirebaseAuth.instance.currentUser;

      if (user?.emailVerified == true) {
        _verificationTimer?.cancel();
        context.read<AuthProvider>().setUser(user!);
        Get.off(() => const HomeScreen());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    Get.changeThemeMode(_isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  void _changeLanguage() {
    final currentLocale = context.locale;
    if (currentLocale.languageCode == 'ar') {
      context.setLocale(const Locale('en'));
    } else {
      context.setLocale(const Locale('ar'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(tr('noUserFound'),
              style: const TextStyle(fontSize: 18, color: Color(0xFF1F3440))),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1F3440),
          title: Text(tr('verifyEmail')),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _verificationTimer?.cancel();
                authProvider.signOut();
                Get.offAll(const LoginScreen());
              },
              tooltip: tr('signOut'),
            ),
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: _changeLanguage,
              tooltip: tr('changeLanguage'),
            ),
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
              tooltip: tr('toggleTheme'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  "assets/image/auth-Image/Mail sent-amico.png",
                  width: 300,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                tr('verifyEmailMessage', args: [user.email ?? '']),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F3440),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkEmailVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3440),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          tr('checkVerification'),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await authProvider.sendEmailVerification(context);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr('verificationEmailSent'))),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3440),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    tr('resendVerification'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  _verificationTimer?.cancel();
                  authProvider.signOut();
                  Get.offAll(const LoginScreen());
                },
                child: Text(
                  tr('signOut'),
                  style: const TextStyle(
                    color: Color(0xFF1F3440),
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
