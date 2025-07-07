import 'package:flutter/material.dart';
import 'package:mihnati2/common/models/appointment_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.lightIcon;
    final primaryColor = AppColors.primaryColor;
    Color statusColor = Colors.grey;
    if (appointment.status == 'مؤكدة') statusColor = Colors.green;
    if (appointment.status == 'ملغاة') statusColor = Colors.red;

    return Card(
      color: cardColor,
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
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Icon(Icons.person, color: primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.clientName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.clientPhone,
                          style: TextStyle(color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                  // حالة الموعد
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              Divider(
                  height: 24, thickness: 1, color: iconColor.withOpacity(0.2)),

              // تفاصيل الموعد
              _buildDetailRow(
                  Icons.work, appointment.serviceName, iconColor, textColor),
              _buildDetailRow(Icons.category, appointment.serviceCategory,
                  iconColor, textColor),
              _buildDetailRow(
                  Icons.calendar_today,
                  '${appointment.date} | ${appointment.time}',
                  iconColor,
                  textColor),
              _buildDetailRow(
                  Icons.location_on, appointment.address, iconColor, textColor),
              _buildDetailRow(
                  Icons.attach_money,
                  '${appointment.price.toStringAsFixed(2)} ر.س',
                  iconColor,
                  textColor),

              // الملاحظات
              if (appointment.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'ملاحظات:',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: textColor),
                ),
                Text(appointment.notes, style: TextStyle(color: textColor)),
              ],

              // أزرار الإجراءات
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.phone, color: primaryColor),
                      label:
                          Text('اتصال', style: TextStyle(color: primaryColor)),
                      onPressed: () => _callClient(appointment.clientPhone),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.directions, color: Colors.white),
                      label: const Text('توجيه'),
                      onPressed: () => _openMap(appointment.address),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
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

  Widget _buildDetailRow(
      IconData icon, String text, Color iconColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: textColor))),
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
