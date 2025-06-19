import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;

class FirebaseAuthMethods extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  void onInit() {
    super.onInit();
    // Only set persistence on web platform
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _auth.setPersistence(Persistence.LOCAL);
    }
  }

  // Email & Password Sign Up
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required BuildContext context,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(username);
      await userCredential.user?.sendEmailVerification();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم إرسال رسالة التحقق على البريد الإلكتروني!')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ ما، حاول مرة أخرى.';
      if (e.code == 'email-already-in-use') {
        message = 'هذا البريد الإلكتروني مستخدم بالفعل.';
      } else if (e.code == 'weak-password') {
        message = 'كلمة المرور ضعيفة جدًا.';
      } else if (e.code == 'invalid-email') {
        message = 'البريد الإلكتروني غير صالح.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      rethrow;
    }
  }

  // Email & Password Login
  Future<void> loginWithEmail({
    required String email,
    required String password,
    required String username,
    required BuildContext context,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user?.displayName == null ||
          userCredential.user?.displayName?.isEmpty == true) {
        await userCredential.user?.updateDisplayName(username);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ في تسجيل الدخول.';
      if (e.code == 'user-not-found') {
        message = 'المستخدم غير موجود، يرجى التأكد من البريد الإلكتروني.';
      } else if (e.code == 'wrong-password') {
        message = 'كلمة المرور غير صحيحة.';
      } else if (e.code == 'invalid-email') {
        message = 'البريد الإلكتروني غير صالح.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      rethrow;
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle({BuildContext? context}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إلغاء تسجيل الدخول بحساب جوجل')),
          );
        }
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ في تسجيل الدخول بحساب جوجل: ${e.message}')),
        );
      }
      rethrow;
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ غير متوقع: $e')),
        );
      }
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Reset Password
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم إرسال رابط إعادة تعيين كلمة المرور!')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ أثناء محاولة إعادة تعيين كلمة المرور.';
      if (e.code == 'user-not-found') {
        message = 'الإيميل غير مسجل لدينا.';
      } else if (e.code == 'invalid-email') {
        message = 'البريد الإلكتروني غير صالح.';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      rethrow;
    }
  }

  // Delete Account
  Future<void> deleteAccount({BuildContext? context}) async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ عند حذف الحساب: ${e.message}')),
        );
      }
      rethrow;
    }
  }

  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        // أضف هذه الطباعة لتتبع الإرسال
        debugPrint('تم إرسال رسالة التحقق إلى: ${user.email}');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('تم إرسال رسالة التحقق على البريد الإلكتروني!')),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('خطأ في إرسال التحقق: ${e.message}'); // أضف هذه الطباعة

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء إرسال رسالة التحقق: ${e.message}')),
        );
      }
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reauthenticate(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth.currentUser?.reauthenticateWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      await _auth.currentUser?.reload();
      if (_auth.currentUser?.emailVerified == true) {
        return;
      }
      throw 'لم يتم التحقق من البريد الإلكتروني بعد';
    } catch (e) {
      rethrow;
    }
  }
}
