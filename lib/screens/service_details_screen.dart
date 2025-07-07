import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mihnati2/common/models/professional_model.dart';
import 'package:mihnati2/common/models/service_model.dart';
import 'package:mihnati2/screens/booking_screen.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailsScreen({super.key, required this.service});

  // دالة لجلب بيانات المهني من قاعدة البيانات
  Future<ProfessionalModel?> _getProfessional(String professionalId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(professionalId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return ProfessionalModel(
          id: doc.id,
          name: data['fullName'] ?? 'غير معروف',
          profession: (data['services'] != null && data['services'].isNotEmpty)
              ? data['services'][0]
              : 'مهني',
          rating: (data['rating'] ?? 0.0).toDouble(),
          completedJobs: data['reviewCount'] ?? 0,
          imageUrl: data['photoURL'] ?? '',
          isFeatured: data['isFeatured'] ?? false,
        );
      }
      return null;
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ في جلب بيانات المهني');
      return null;
    }
  }

  void _bookService() async {
    if (service.professionalId == null || service.professionalId!.isEmpty) {
      Get.snackbar('خطأ', 'لا يوجد مهني مسجل لهذه الخدمة');
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final professional = await _getProfessional(service.professionalId!);

    Get.back(); // إغلاق شاشة التحميل

    if (professional != null) {
      Get.to(BookingScreen(
        professional: professional,
        service: service,
      ));
    } else {
      Get.snackbar('خطأ', 'فشل في جلب بيانات المهني');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.lightIcon : AppColors.darkIcon;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title:
            Text('تفاصيل الخدمة', style: TextStyle(color: AppColors.lightText)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: IconThemeData(color: AppColors.lightText),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              color: isDark ? AppColors.darkCard : Colors.grey[200],
              child: Center(
                child: Image(image: AssetImage('assets/image/logo/logo.png')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.category, size: 18, color: iconColor),
                      const SizedBox(width: 5),
                      Text(
                        service.category,
                        style: TextStyle(color: iconColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 5),
                      Text(
                        '${service.rating} (${service.reviews} تقييم)',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'الوصف',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style:
                        TextStyle(fontSize: 16, height: 1.5, color: textColor),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${service.price.toStringAsFixed(2)} ر.س',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _bookService, // تم التعديل هنا
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: const Text('حجز الآن',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
