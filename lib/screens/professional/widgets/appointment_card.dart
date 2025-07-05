import 'package:flutter/material.dart';
import 'package:mihnati2/common/models/appointment_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    if (appointment.status == 'مؤكدة') statusColor = Colors.green;
    if (appointment.status == 'ملغاة') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات العميل
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1F3440).withOpacity(0.1),
                    child: const Icon(Icons.person, color: Color(0xFF1F3440)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.clientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.clientPhone,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  // حالة الموعد
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              const Divider(height: 24, thickness: 1),
              
              // تفاصيل الموعد
              _buildDetailRow(Icons.work, appointment.serviceName),
              _buildDetailRow(Icons.category, appointment.serviceCategory),
              _buildDetailRow(Icons.calendar_today, '${appointment.date} | ${appointment.time}'),
              _buildDetailRow(Icons.location_on, appointment.address),
              _buildDetailRow(Icons.attach_money, '${appointment.price.toStringAsFixed(2)} ر.س'),
              
              // الملاحظات
              if (appointment.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'ملاحظات:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(appointment.notes),
              ],
              
              // أزرار الإجراءات
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.phone),
                      label: const Text('اتصال'),
                      onPressed: () => _callClient(appointment.clientPhone),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: const Text('توجيه'),
                      onPressed: () => _openMap(appointment.address),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _callClient(String phone) async {
    final Uri telUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      print('Could not launch $telUri');
    }
  }

  void _openMap(String address) async {
    final Uri mapUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      queryParameters: {'query': address},
    );
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri);
    } else {
      print('Could not launch $mapUri');
    }
  }
}