import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mihnati2/common/models/booking_model.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

class BookingsListScreen extends StatelessWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الحجوزات')),
        body: const Center(child: Text('يجب تسجيل الدخول أولاً')),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('حجوزاتي'),
          backgroundColor: AppColors.primaryColor,
          iconTheme: IconThemeData(color: AppColors.lightText),
          titleTextStyle: TextStyle(
              color: AppColors.lightText,
              fontWeight: FontWeight.bold,
              fontSize: 20),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'الكل'),
              Tab(text: 'مؤكدة'),
              Tab(text: 'ملغاة'),
              Tab(text: 'مكتملة'),
              Tab(text: 'في الانتظار'),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .where('clientId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('حدث خطأ في تحميل الحجوزات'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('لا توجد حجوزات بعد'));
            }

            final bookings = snapshot.data!.docs
                .map((doc) => BookingModel.fromFirestore(doc))
                .toList();

            // فرز حسب التاريخ تنازلياً
            bookings.sort((a, b) {
              final dateA = DateTime.tryParse(a.date) ?? DateTime(1970);
              final dateB = DateTime.tryParse(b.date) ?? DateTime(1970);
              return dateB.compareTo(dateA);
            });

            // تقسيم حسب الحالة
            final all = bookings;
            final confirmed = bookings
                .where((b) => b.status == 'مؤكدة' || b.status == 'confirmed')
                .toList();
            final cancelled = bookings
                .where((b) => b.status == 'ملغاة' || b.status == 'cancelled')
                .toList();
            final completed = bookings
                .where((b) => b.status == 'مكتمل' || b.status == 'completed')
                .toList();
            final pending = bookings
                .where(
                    (b) => b.status == 'في الانتظار' || b.status == 'pending')
                .toList();

            List<Widget> buildList(List<BookingModel> list) {
              if (list.isEmpty) {
                return [
                  const Center(child: Text('لا توجد حجوزات في هذا القسم'))
                ];
              }
              return list.map((b) => BookingCard(booking: b)).toList();
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
}

class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = AppColors.primaryColor;
    final statusColor = _getStatusColor(booking.status);
    final date = DateTime.tryParse(booking.date);
    final formattedDate =
        date != null ? DateFormat.yMMMMd('ar').format(date) : booking.date;

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
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.12),
          child: Icon(Icons.calendar_today, color: iconColor),
        ),
        title: Row(
          children: [
            Icon(Icons.home_repair_service, color: iconColor, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                booking.serviceName,
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
                  Expanded(
                    child: Text('التاريخ: $formattedDate',
                        style: TextStyle(
                            color: textColor.withOpacity(0.8), fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time,
                      color: iconColor.withOpacity(0.7), size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('الوقت: ${booking.time}',
                        style: TextStyle(
                            color: textColor.withOpacity(0.8), fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person_outline,
                      color: iconColor.withOpacity(0.7), size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('المهني: ${booking.professionalName}',
                        style: TextStyle(
                            color: textColor.withOpacity(0.8), fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on,
                      color: iconColor.withOpacity(0.7), size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(booking.address ?? '',
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
                      _getStatusText(booking.status),
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.attach_money, color: Colors.green, size: 16),
                  Text('${booking.price.toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ],
              ),
              // زر تأكيد الإكمال للعميل
              if ((booking.status == 'مؤكدة' || booking.status == 'confirmed'))
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text('تأكيد إكمال الموعد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('bookings')
                          .doc(booking.id)
                          .update({'status': 'مكتمل'});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('تم تأكيد إكمال الموعد بنجاح')),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.info_outline, color: iconColor),
          onPressed: () {
            // تفاصيل الحجز
          },
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغى';
      case 'مؤكدة':
        return 'مؤكد';
      case 'ملغاة':
        return 'ملغى';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'مؤكدة':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
      case 'ملغاة':
        return Colors.red;
      default:
        return AppColors.primaryColor;
    }
  }
}
