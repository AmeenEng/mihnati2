import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String professionalId;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final String serviceName;
  final String date;
  final String time;
  final String address;
  final String status;
  final String notes;
  final double price;
  final String serviceCategory;

  AppointmentModel({
    required this.id,
    required this.professionalId,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.address,
    required this.status,
    required this.notes,
    required this.price,
    required this.serviceCategory,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      professionalId: data['professionalId'] ?? '',
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? 'غير معروف',
      clientPhone: data['clientPhone'] ?? '',
      serviceName: data['serviceName'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      address: data['address'] ?? '',
      status: data['status'] ?? 'معلقة',
      notes: data['notes'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      serviceCategory: data['serviceCategory'] ?? 'عام',
    );
  }
}