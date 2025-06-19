import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'لم يتم العثور على المستخدم';
        case 'wrong-password':
          return 'كلمة المرور غير صحيحة';
        case 'email-already-in-use':
          return 'البريد الإلكتروني مستخدم بالفعل';
        case 'invalid-email':
          return 'البريد الإلكتروني غير صالح';
        case 'weak-password':
          return 'كلمة المرور ضعيفة جداً';
        case 'operation-not-allowed':
          return 'العملية غير مسموح بها';
        case 'account-exists-with-different-credential':
          return 'يوجد حساب آخر بنفس البريد الإلكتروني';
        case 'network-request-failed':
          return 'فشل الاتصال بالشبكة';
        case 'too-many-requests':
          return 'تم تجاوز عدد المحاولات المسموح بها';
        case 'user-disabled':
          return 'تم تعطيل هذا الحساب';
        case 'requires-recent-login':
          return 'يرجى تسجيل الدخول مرة أخرى';
        default:
          return 'حدث خطأ: ${error.message}';
      }
    } else if (error is FirebaseException) {
      return 'خطأ في Firebase: ${error.message}';
    } else {
      return 'حدث خطأ غير متوقع: $error';
    }
  }

  static void showErrorSnackBar(String message) {
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
    );
  }

  static void showSuccessSnackBar(String message) {
    Get.snackbar(
      'نجاح',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 2),
    );
  }

  static Future<bool> showConfirmationDialog({
    required String title,
    required String message,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}