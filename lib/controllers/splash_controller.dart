import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../auth/auth_provider.dart';

class SplashController extends GetxController {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final RxBool isLoading = true.obs;
  late final AuthProvider _authProvider;

  @override
  void onInit() {
    super.onInit();
    // Get the AuthProvider instance that was initialized in main.dart
    _authProvider = Get.find<AuthProvider>();
    // Add a longer initial delay to ensure the splash screen is visible
    Future.delayed(const Duration(seconds: 4), _checkUserStatus);
  }

  Future<void> _checkUserStatus() async {
    try {
      // Wait for Firebase Auth to initialize
      await Future.delayed(const Duration(milliseconds: 500));

      final user = _auth.currentUser;

      if (user == null) {
        _goToLogin();
        return;
      }

      try {
        // Try to reload the user
        await user.reload();
        final refreshedUser = _auth.currentUser;

        if (refreshedUser == null) {
          await _auth.signOut();
          _authProvider.setUser(null);
          _goToLogin();
        } else {
          // Update the AuthProvider with the refreshed user
          _authProvider.setUser(refreshedUser);

          if (!refreshedUser.emailVerified) {
            _goToVerify();
          } else {
            _goToHome();
          }
        }
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' ||
            e.code == 'user-disabled' ||
            e.code == 'invalid-credential') {
          await _auth.signOut();
          _authProvider.setUser(null);
          _goToLogin();
        } else {
          rethrow;
        }
      }
    } catch (e) {
      print('Error in _checkUserStatus: $e'); // For debugging
      await _auth.signOut();
      _authProvider.setUser(null);
      _goToLogin();
    } finally {
      // Add a longer delay before hiding the splash screen
      await Future.delayed(const Duration(seconds: 1));
      isLoading.value = false;
    }
  }

  void _goToLogin() {
    isLoading.value = false;
    Get.offAll(() => const LoginScreen(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 800));
  }

  void _goToHome() {
    isLoading.value = false;
    Get.offAll(() => const HomeScreen(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 800));
  }

  void _goToVerify() {
    isLoading.value = false;
    Get.offAll(() => const VerifyEmailScreen(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 800));
  }
}
