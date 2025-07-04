import 'package:get/get.dart';
import '../auth/providers/auth_provider.dart';
import '../routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      await Future.delayed(const Duration(seconds: 2));
      _isInitialized.value = true;

      if (_authProvider.isAuthenticated) {
        final uid = FirebaseAuth.instance.currentUser?.uid;

        if (uid != null) {
          final accountType = await _authProvider.getAccountType(uid);

          if (accountType == 'professional') {
            Get.offAllNamed(AppRoutes.professionalHome);
          } else {
            Get.offAllNamed(AppRoutes.clientHome);
          }
        } else {
          Get.offAllNamed(AppRoutes.clientHome);
        }
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
