import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';
import 'package:mihnati2/common/models/appointment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentDetailsScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.lightIcon;
    final primaryColor = AppColors.primaryColor;

    // حالة الموعد بلون خاص
    Color statusColor = Colors.grey;
    if (appointment.status == 'مؤكدة') statusColor = Colors.green;
    if (appointment.status == 'ملغاة') statusColor = Colors.red;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: iconColor),
        title: Text('تفاصيل الموعد', style: TextStyle(color: textColor)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              cardColor,
              [
                Text(
                  'حالة الموعد',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appointment.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sectionTitle('معلومات الموعد', textColor),
            _buildDetailItem('الخدمة', appointment.serviceName, textColor),
            _buildDetailItem('التصنيف', appointment.serviceCategory, textColor),
            _buildDetailItem('التاريخ', appointment.date, textColor),
            _buildDetailItem('الوقت', appointment.time, textColor),
            _buildDetailItem('العنوان', appointment.address, textColor),
            _buildDetailItem('السعر',
                '${appointment.price.toStringAsFixed(2)} ر.س', textColor),
            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle('ملاحظات', textColor),
              Text(appointment.notes, style: TextStyle(color: textColor)),
            ],
            const SizedBox(height: 20),
            _sectionTitle('معلومات العميل', textColor),
            _buildDetailItem('الاسم', appointment.clientName, textColor),
            _buildDetailItem('رقم الهاتف', appointment.clientPhone, textColor),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.phone, color: iconColor),
                    label: Text('اتصال', style: TextStyle(color: textColor)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: iconColor),
                    ),
                    onPressed: () => _makePhoneCall(appointment.clientPhone),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.message, color: iconColor),
                    label: Text('رسالة', style: TextStyle(color: textColor)),
                    onPressed: () => _sendSms(appointment.clientPhone),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: iconColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                if (appointment.status != 'ملغاة')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await _updateAppointmentStatus(
                            context, appointment, 'ملغاة');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        'إلغاء الموعد',
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                    ),
                  ),
                if (appointment.status != 'ملغاة') const SizedBox(width: 10),
                if (appointment.status != 'مؤكدة')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _updateAppointmentStatus(
                            context, appointment, 'مؤكدة');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      child: Text('تأكيد الموعد',
                          style: TextStyle(color: textColor)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text('حذف الموعد',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('تأكيد الحذف'),
                      content: const Text(
                          'هل أنت متأكد أنك تريد حذف هذا الموعد نهائيًا؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('إلغاء'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('حذف',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _deleteAppointment(context, appointment);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: TextStyle(color: textColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
    );
  }

  Widget _buildCard(Color color, List<Widget> children) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  Future<void> _sendSms(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  Future<void> _updateAppointmentStatus(BuildContext context,
      AppointmentModel appointment, String newStatus) async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    try {
      // تحديث حالة الموعد
      await firestore
          .collection('bookings')
          .doc(appointment.id)
          .update({'status': newStatus});
      // إرسال إشعار للعميل
      final notification = {
        'title': newStatus == 'ملغاة' ? 'تم إلغاء الموعد' : 'تم تأكيد الموعد',
        'body': newStatus == 'ملغاة'
            ? 'تم إلغاء موعدك مع المهني بواسطة ${user?.displayName ?? 'المهني'}'
            : 'تم تأكيد موعدك مع المهني بواسطة ${user?.displayName ?? 'المهني'}',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'appointment',
        'appointmentId': appointment.id,
        'status': newStatus,
      };
      await firestore
          .collection('users')
          .doc(appointment.clientId)
          .collection('notifications')
          .add(notification);
      // إظهار رسالة
      Get.back();
      Get.snackbar(
        newStatus == 'ملغاة' ? 'تم الإلغاء' : 'تم التأكيد',
        newStatus == 'ملغاة'
            ? 'تم إلغاء الموعد بنجاح'
            : 'تم تأكيد الموعد بنجاح',
        backgroundColor:
            newStatus == 'ملغاة' ? Colors.red.shade100 : Colors.green.shade100,
        colorText: Colors.black,
      );
    } catch (e) {
      print('Error updating appointment status: $e');
      Get.snackbar('خطأ', 'حدث خطأ أثناء تحديث حالة الموعد: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _deleteAppointment(
      BuildContext context, AppointmentModel appointment) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(appointment.id)
          .delete();
      Get.back();
      Get.snackbar('تم الحذف', 'تم حذف الموعد بنجاح',
          backgroundColor: Colors.green.shade100, colorText: Colors.black);
    } catch (e) {
      print('Error deleting appointment: $e');
      Get.snackbar('خطأ', 'حدث خطأ أثناء حذف الموعد: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
