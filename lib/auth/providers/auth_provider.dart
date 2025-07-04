import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/screens/home/home_screen.dart';
import '../services/firebase_auth_methods.dart';
import '../../routes.dart';
import '../../utils/auth_error_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AuthProvider2 extends GetxController {
  final FirebaseAuthMethods _authMethods = Get.find<FirebaseAuthMethods>();
  final Rx<User?> _user = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isInitialized = false.obs;
  final RxBool _isTokenExpired = false.obs;

  static AuthProvider2 get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    _init();

    ever(_isLoading, (value) {
      if (value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _isLoading.value = value;
        });
      } else {
        _isLoading.value = value;
      }
    });
  }

  @override
  void onClose() {
    _user.close();
    _isLoading.close();
    _isInitialized.close();
    _isTokenExpired.close();
    super.onClose();
  }

  User? get user => _user.value;
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _user.value != null;
  bool get isInitialized => _isInitialized.value;
  bool get isTokenExpired => _isTokenExpired.value;

  Future<void> _init() async {
    try {
      _authMethods.authStateChanges.listen((User? user) {
        _user.value = user;
        _checkTokenExpiration();
      });
      
      final currentUser = _authMethods.currentUser;
      if (currentUser != null) {
        _user.value = currentUser;
        await _checkTokenExpiration();
      }

      _isInitialized.value = true;
    } catch (e) {
      AuthErrorHandler.showErrorSnackBar(AuthErrorHandler.getErrorMessage(e));
      _isInitialized.value = true;
    }
  }

  Future<void> _checkTokenExpiration() async {
    try {
      if (_user.value != null) {
        final idTokenResult = await _user.value!.getIdTokenResult();
        _isTokenExpired.value =
            idTokenResult.expirationTime!.isBefore(DateTime.now());
      }
    } catch (e) {
      _isTokenExpired.value = true;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading.value = true;
      await _authMethods.loginWithEmail(
        email: email,
        password: password,
        username: email.split('@')[0],
        context: Get.context!,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading.value = true;
      await _authMethods.signInWithGoogle(context: Get.context!);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading.value = true;
      await _authMethods.signOut();
      Get.offAllNamed(AppRoutes.login);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading.value = true;
      await _authMethods.resetPassword(
        email: email,
        context: Get.context!,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      _isLoading.value = true;
      await _authMethods.updatePassword(newPassword);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      _isLoading.value = true;
      await _authMethods.updateEmail(newEmail);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      _isLoading.value = true;
      await _authMethods.deleteAccount(context: Get.context!);
      Get.offAllNamed(AppRoutes.login);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> reauthenticate(String email, String password) async {
    try {
      _isLoading.value = true;
      await _authMethods.reauthenticate(email, password);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> sendEmailVerification() async {
    if (_isLoading.value) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _isLoading.value = true;
        await _authMethods.sendEmailVerification(Get.context!);
      } catch (e) {
        AuthErrorHandler.showErrorSnackBar(AuthErrorHandler.getErrorMessage(e));
      } finally {
        _isLoading.value = false;
      }
    });
  }

  Future<void> reloadUser() async {
    try {
      _isLoading.value = true;
      await FirebaseAuth.instance.currentUser?.reload();
      _user.value = FirebaseAuth.instance.currentUser;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      _isLoading.value = true;
      await reloadUser();

      if (user?.emailVerified ?? false) {
        Get.offAll(() => const HomeScreen());
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      _isLoading.value = true;
      await _authMethods.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        context: Get.context!,
      );
      Get.offAllNamed(AppRoutes.verifyEmail);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      AuthErrorHandler.showErrorSnackBar('لا يوجد اتصال بالإنترنت');
      return false;
    }
    return true;
  }

  Future<void> _recoverFromError() async {
    try {
      await _checkTokenExpiration();
      if (_isTokenExpired.value) {
        await _handleTokenExpiration();
      }
    } catch (e) {
      AuthErrorHandler.showErrorSnackBar(AuthErrorHandler.getErrorMessage(e));
    }
  }

  Future<void> _handleTokenExpiration() async {
    await signOut();
    AuthErrorHandler.showErrorSnackBar(
        'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.');
  }

  Future<String> getAccountType(String uid) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') 
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final type = data['type'] ?? 'client'; 
        return type;
      }

      return 'client';
    } catch (e) {
      print('Error getting account type: $e');
      return 'client';
    }
  }
}
