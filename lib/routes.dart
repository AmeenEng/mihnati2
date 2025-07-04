import 'package:get/get.dart';
import 'package:mihnati2/screens/auth/CompleteProfileScreen.dart';
import 'package:mihnati2/screens/client/screens/client_home_screen.dart';
import 'package:mihnati2/screens/professional/screens/professional_home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'Onboarding/onboarding_view.dart';
import 'screens/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String professionalHome = '/professionalHome';
  static const String clientHome = '/clientHome';
  static const String completeProfile = '/completeProfile';
  static const String profile = '/profile';

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
      name: professionalHome,
      page: () => const ProfessionalHomeScreen(),
    ),
    GetPage(
      name: clientHome,
      page: () => const ClientHomeScreen(),
    ),
    GetPage(
      name: completeProfile,
      page: () => const CompleteProfileScreen(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
    ),
  ];
}
