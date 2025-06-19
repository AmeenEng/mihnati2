import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/screens/auth/CompleteProfileScreen.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/home/home_screen.dart';
import 'Onboarding/onboarding_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String home = '/home';
  static const String completeProfile = '/completeProfile';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingView(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: verifyEmail,
      page: () => const VerifyEmailScreen(),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: completeProfile,
      page: () => const CompleteProfileScreen(),
    ),
  ];
}
