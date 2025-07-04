import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String clientName;
  final String serviceName;
  final String date;
  final String time;
  final String status;
  final String address;

  AppointmentModel({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.status,
    required this.address,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      clientName: data['clientName'] ?? 'عميل',
      serviceName: data['serviceName'] ?? 'خدمة',
      date: data['date'] ?? 'غير محدد',
      time: data['time'] ?? 'غير محدد',
      status: data['status'] ?? 'معلقة',
      address: data['address'] ?? 'غير محدد',
    );
  }
}