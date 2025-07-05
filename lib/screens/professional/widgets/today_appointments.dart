import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mihnati2/common/models/appointment_model.dart';
import 'package:mihnati2/screens/appointment_details_screen.dart';
import 'package:mihnati2/screens/professional/widgets/appointment_card.dart';

class TodayAppointments extends StatelessWidget {
  final String userId;
  final FirebaseFirestore firestore;

  const TodayAppointments({
    super.key,
    required this.userId,
    required this.firestore,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('bookings')
          .where('professionalId', isEqualTo: userId)
          .where('date', isEqualTo: today)
          .orderBy('time')
          .snapshots(),
      builder: (context, snapshot) {
        // حالة التحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // معالجة الأخطاء بشكل متكامل مع تجربة المستخدم
        if (snapshot.hasError) {
          final error = snapshot.error;
          print('Appointments Error: $error');

          // محاولة جلب البيانات بدون ترتيب إذا كان الخطأ بسبب الفهرس
          if (error is FirebaseException &&
              error.code == 'failed-precondition') {
            return _buildFallbackAppointments(today);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('حدث خطأ في تحميل المواعيد'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Get.forceAppUpdate(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        // حالة عدم وجود مواعيد
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('لا توجد مواعيد لهذا اليوم'),
          );
        }

        return _buildAppointmentsList(snapshot.data!.docs);
      },
    );
  }

  Widget _buildFallbackAppointments(String today) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('bookings')
          .where('professionalId', isEqualTo: userId)
          // .where('date', isEqualTo: today)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('لا توجد مواعيد لهذا اليوم'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('لا توجد مواعيد لهذا اليوم'),
          );
        }

        return _buildAppointmentsList(snapshot.data!.docs);
      },
    );
  }

  // دالة لبناء قائمة المواعيد مع الترتيب اليدوي
  Widget _buildAppointmentsList(List<QueryDocumentSnapshot> docs) {
    try {
      final appointments = docs
          .map((doc) {
            try {
              return AppointmentModel.fromFirestore(doc);
            } catch (e) {
              print('Error parsing appointment: ${doc.id} - $e');
              return null;
            }
          })
          .where((appointment) => appointment != null)
          .cast<AppointmentModel>()
          .toList();

      if (appointments.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('لا توجد مواعيد صالحة لهذا اليوم'),
        );
      }

      // ترتيب المواعيد يدوياً حسب الوقت
      appointments.sort((a, b) {
        final timeFormat = DateFormat('HH:mm');
        final aTime = timeFormat.parse(a.time);
        final bTime = timeFormat.parse(b.time);
        return aTime.compareTo(bTime);
      });

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return AppointmentCard(
            appointment: appointments[index],
            onTap: () => Get.to(
                AppointmentDetailsScreen(appointment: appointments[index])),
          );
        },
      );
    } catch (e) {
      print('Data processing error: $e');
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('حدث خطأ في معالجة بيانات المواعيد'),
      );
    }
  }
}
