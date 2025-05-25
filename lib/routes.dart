import 'package:flutter/material.dart';
import 'package:mihnati2/Onboarding/onboarding_view.dart';
import 'package:mihnati2/auth/login/login_screen.dart';
import 'package:mihnati2/auth/register/register_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/onboarding': (context) => const OnboardingView(),
  'login': (context) => const LoginScreen(),
  'signup': (context) => const RegisterScreen(),
};
