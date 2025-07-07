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

    return Scaffold(
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('bookings')
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

          final bookingIds = snapshot.data!.docs
              .map((doc) => doc['bookingId'] as String)
              .toList();

          return ListView.builder(
            itemCount: bookingIds.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('bookings')
                    .doc(bookingIds[index])
                    .get(),
                builder: (context, bookingSnapshot) {
                  if (bookingSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text('جاري التحميل...'),
                    );
                  }

                  if (!bookingSnapshot.hasData ||
                      !bookingSnapshot.data!.exists) {
                    return const ListTile(
                      title: Text('الحجز غير متوفر'),
                    );
                  }

                  final booking = BookingModel.fromFirestore(bookingSnapshot
                      .data! as DocumentSnapshot<Map<String, dynamic>>);

                  return BookingCard(booking: booking);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(booking.date);
    final formattedDate = DateFormat.yMMMMd('ar').format(date);

    return Card(
      color: Provider.of<ThemeProvider>(context).isDarkMode
          ? AppColors.darkCard
          : AppColors.lightCard,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: AppColors.primaryColor),
        title: Text(booking.serviceName,
            style: TextStyle(
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? AppColors.lightText
                    : AppColors.darkText)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المهني: ${booking.professionalName}',
                style: TextStyle(
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? AppColors.lightText
                        : AppColors.darkText)),
            Text('التاريخ: $formattedDate',
                style: TextStyle(
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? AppColors.lightText
                        : AppColors.darkText)),
            Text('الوقت: ${booking.time}',
                style: TextStyle(
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? AppColors.lightText
                        : AppColors.darkText)),
            Text('الحالة: ${_getStatusText(booking.status)}',
                style: TextStyle(
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? AppColors.lightText
                        : AppColors.darkText)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.info_outline, color: AppColors.primaryColor),
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
      default:
        return status;
    }
  }
}
