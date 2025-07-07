import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mihnati2/common/models/appointment_model.dart';
import 'package:mihnati2/screens/appointment_details_screen.dart';
import 'package:mihnati2/screens/professional/widgets/appointment_card.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.lightIcon;
    final primaryColor = AppColors.primaryColor;
    final borderColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final errorColor = Colors.red;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('bookings')
          .where('professionalId', isEqualTo: userId)
          .where('date', isEqualTo: today)
          .orderBy('time')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          print('Appointments Error: $error');
          if (error is FirebaseException &&
              error.code == 'failed-precondition') {
            return _buildFallbackAppointments(
                today, cardColor, textColor, iconColor, errorColor);
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('حدث خطأ في تحميل المواعيد',
                    style: TextStyle(color: errorColor)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Get.forceAppUpdate(),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: Text('إعادة المحاولة',
                      style: TextStyle(color: textColor)),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('لا توجد مواعيد لهذا اليوم',
                style: TextStyle(color: textColor.withOpacity(0.7))),
          );
        }
        return _buildAppointmentsList(
            snapshot.data!.docs, cardColor, textColor, iconColor, primaryColor);
      },
    );
  }

  Widget _buildFallbackAppointments(String today, Color cardColor,
      Color textColor, Color iconColor, Color errorColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('bookings')
          .where('professionalId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('لا توجد مواعيد لهذا اليوم',
                style: TextStyle(color: errorColor)),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('لا توجد مواعيد لهذا اليوم',
                style: TextStyle(color: textColor.withOpacity(0.7))),
          );
        }
        return _buildAppointmentsList(
            snapshot.data!.docs, cardColor, textColor, iconColor, errorColor);
      },
    );
  }

  Widget _buildAppointmentsList(List<QueryDocumentSnapshot> docs,
      Color cardColor, Color textColor, Color iconColor, Color primaryColor) {
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
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('لا توجد مواعيد صالحة لهذا اليوم',
              style: TextStyle(color: textColor.withOpacity(0.7))),
        );
      }
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
          return Card(
            color: cardColor,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(Icons.event, color: primaryColor),
              title: Text(appointments[index].serviceName,
                  style: TextStyle(color: textColor)),
              subtitle: Text(
                  '${appointments[index].date} | ${appointments[index].time}',
                  style: TextStyle(color: textColor.withOpacity(0.7))),
              trailing: Icon(Icons.arrow_forward_ios, color: iconColor),
              onTap: () => Get.to(
                  AppointmentDetailsScreen(appointment: appointments[index])),
            ),
          );
        },
      );
    } catch (e) {
      print('Data processing error: $e');
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('حدث خطأ في معالجة بيانات المواعيد',
            style: TextStyle(color: Colors.red)),
      );
    }
  }
}
