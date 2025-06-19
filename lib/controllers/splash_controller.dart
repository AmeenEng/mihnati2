import 'package:get/get.dart';
import '../auth/providers/auth_provider.dart';
import '../routes.dart';

class SplashController extends GetxController {
  final AuthProvider2 _authProvider = Get.find<AuthProvider2>();
  final RxBool _isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Wait for auth provider to initialize
      await Future.delayed(const Duration(seconds: 2));
      _isInitialized.value = true;

      // Navigate based on auth state
      if (_authProvider.isAuthenticated) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      _isInitialized.value = true;
      Get.offAllNamed(AppRoutes.login);
    }
  }

  bool get isInitialized => _isInitialized.value;
}
