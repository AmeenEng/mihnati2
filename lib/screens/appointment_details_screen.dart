import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/common/models/appointment_model.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentDetailsScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    if (appointment.status == 'مؤكدة') statusColor = Colors.green;
    if (appointment.status == 'ملغاة') statusColor = Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الموعد'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'حالة الموعد',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'معلومات الموعد',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildDetailItem('الخدمة', appointment.serviceName),
            _buildDetailItem('التاريخ', appointment.date),
            _buildDetailItem('الوقت', appointment.time),
            _buildDetailItem('العنوان', appointment.address),
            const SizedBox(height: 20),
            const Text(
              'معلومات العميل',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildDetailItem('الاسم', appointment.clientName),
            _buildDetailItem('رقم الهاتف', '+966 50 123 4567'),
            const SizedBox(height: 30),
            Row(
              children: [
                if (appointment.status != 'ملغاة')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Cancel appointment logic
                        Get.back();
                        Get.snackbar('تم الإلغاء', 'تم إلغاء الموعد بنجاح');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'إلغاء الموعد',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                if (appointment.status != 'ملغاة') const SizedBox(width: 10),
                if (appointment.status != 'مؤكدة')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Confirm appointment logic
                        Get.back();
                        Get.snackbar('تم التأكيد', 'تم تأكيد الموعد بنجاح');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F3440),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('تأكيد الموعد'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}