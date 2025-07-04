import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mihnati2/common/models/professional_model.dart';
import 'package:mihnati2/common/models/service_model.dart';
import 'package:mihnati2/screens/booking_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الخدمة'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            service.imagePath.isNotEmpty
                ? Image.network(
                    service.imagePath,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image, size: 80, color: Colors.grey),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        service.category,
                        style: const TextStyle(color: Colors.grey),
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
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'الوصف',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${service.price.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F3440),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _bookService, // تم التعديل هنا
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3440),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: const Text('حجز الآن'),
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
