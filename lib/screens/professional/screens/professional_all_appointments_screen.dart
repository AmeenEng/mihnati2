import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:mihnati2/common/models/appointment_model.dart';
import 'package:mihnati2/screens/appointment_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

class ProfessionalAllAppointmentsScreen extends StatelessWidget {
  const ProfessionalAllAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.lightIcon;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final currentUser = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          iconTheme: IconThemeData(color: iconColor),
          elevation: 0,
          title: Row(
            children: [
              Icon(Icons.calendar_month, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text('جميع المواعيد',
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('bookings')
                  .where('professionalId', isEqualTo: currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                int all = 0,
                    confirmed = 0,
                    cancelled = 0,
                    completed = 0,
                    pending = 0;
                if (snapshot.hasData) {
                  final appointments = snapshot.data!.docs
                      .map((doc) => AppointmentModel.fromFirestore(doc))
                      .toList();
                  all = appointments.length;
                  confirmed = appointments
                      .where(
                          (a) => a.status == 'مؤكدة' || a.status == 'confirmed')
                      .length;
                  cancelled = appointments
                      .where(
                          (a) => a.status == 'ملغاة' || a.status == 'cancelled')
                      .length;
                  completed = appointments
                      .where(
                          (a) => a.status == 'مكتمل' || a.status == 'completed')
                      .length;
                  pending = appointments
                      .where((a) =>
                          a.status == 'في الانتظار' || a.status == 'pending')
                      .length;
                }
                return TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'الكل ($all)'),
                    Tab(text: 'مؤكدة ($confirmed)'),
                    Tab(text: 'ملغاة ($cancelled)'),
                    Tab(text: 'مكتملة ($completed)'),
                    Tab(text: 'في الانتظار ($pending)'),
                  ],
                );
              },
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('bookings')
              .where('professionalId', isEqualTo: currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('حدث خطأ في تحميل المواعيد',
                    style: TextStyle(color: Colors.red)),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('لا توجد مواعيد',
                    style: TextStyle(
                        color: textColor.withOpacity(0.7), fontSize: 18)),
              );
            }
            final appointments = snapshot.data!.docs
                .map((doc) => AppointmentModel.fromFirestore(doc))
                .toList();

            // فرز حسب التاريخ والوقت تنازلياً
            appointments.sort((a, b) {
              final dateA = DateTime.tryParse(a.date) ?? DateTime(1970);
              final dateB = DateTime.tryParse(b.date) ?? DateTime(1970);
              if (dateA.compareTo(dateB) != 0) {
                return dateB.compareTo(dateA);
              }
              final timeA = _parseTime(a.time);
              final timeB = _parseTime(b.time);
              return timeB.compareTo(timeA);
            });

            // تقسيم حسب الحالة
            final all = appointments;
            final confirmed = appointments
                .where((a) => a.status == 'مؤكدة' || a.status == 'confirmed')
                .toList();
            final cancelled = appointments
                .where((a) => a.status == 'ملغاة' || a.status == 'cancelled')
                .toList();
            final completed = appointments
                .where((a) => a.status == 'مكتمل' || a.status == 'completed')
                .toList();
            final pending = appointments
                .where(
                    (a) => a.status == 'في الانتظار' || a.status == 'pending')
                .toList();

            List<Widget> buildList(List<AppointmentModel> list) {
              if (list.isEmpty) {
                return [
                  const Center(child: Text('لا توجد مواعيد في هذا القسم'))
                ];
              }
              return list
                  .map((a) => _buildAppointmentCard(
                      context, a, cardColor, textColor, iconColor))
                  .toList();
            }

            return TabBarView(
              children: [
                ListView(children: buildList(all)),
                ListView(children: buildList(confirmed)),
                ListView(children: buildList(cancelled)),
                ListView(children: buildList(completed)),
                ListView(children: buildList(pending)),
              ],
            );
          },
        ),
      ),
    );
  }

  DateTime _parseTime(String time) {
    try {
      final parts = time.split(":");
      if (parts.length == 2) {
        return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      }
      return DateTime(0);
    } catch (_) {
      return DateTime(0);
    }
  }

  Widget _buildAppointmentCard(
      BuildContext context,
      AppointmentModel appointment,
      Color cardColor,
      Color textColor,
      Color iconColor) {
    final statusColor = _getStatusColor(appointment.status);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: statusColor.withOpacity(0.18), width: 1.2),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor.withOpacity(0.12),
          child: Icon(Icons.person, color: AppColors.primaryColor),
        ),
        title: Row(
          children: [
            Icon(Icons.home_repair_service, color: iconColor, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                appointment.serviceName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      color: iconColor.withOpacity(0.7), size: 16),
                  const SizedBox(width: 4),
                  Text('${appointment.date} | ${appointment.time}',
                      style: TextStyle(
                          color: textColor.withOpacity(0.8), fontSize: 13)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person_outline,
                      color: iconColor.withOpacity(0.7), size: 16),
                  const SizedBox(width: 4),
                  Text('العميل: ${appointment.clientName}',
                      style: TextStyle(
                          color: textColor.withOpacity(0.8), fontSize: 13)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on,
                      color: iconColor.withOpacity(0.7), size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(appointment.address,
                        style: TextStyle(
                            color: textColor.withOpacity(0.8), fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appointment.status,
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.attach_money, color: Colors.green, size: 16),
                  Text('${appointment.price.toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            color: iconColor.withOpacity(0.7), size: 18),
        onTap: () => Get.to(AppointmentDetailsScreen(appointment: appointment)),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مؤكدة':
      case 'confirmed':
        return Colors.green;
      case 'ملغاة':
      case 'cancelled':
        return Colors.red;
      case 'مكتمل':
      case 'completed':
        return Colors.blue;
      case 'في الانتظار':
      case 'pending':
        return Colors.orange;
      default:
        return AppColors.primaryColor;
    }
  }
}
