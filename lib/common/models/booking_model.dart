import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String clientId;
  final String professionalId;
  final String serviceId;
  final String clientName;
  final String professionalName;
  final String serviceName;
  final String date;
  final String time;
  final String address;
  final String notes;
  final String status;

  BookingModel({
    required this.id,
    required this.clientId,
    required this.professionalId,
    required this.serviceId,
    required this.clientName,
    required this.professionalName,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.address,
    required this.notes,
    required this.status,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      professionalId: data['professionalId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      clientName: data['clientName'] ?? 'عميل',
      professionalName: data['professionalName'] ?? 'مهني',
      serviceName: data['serviceName'] ?? 'خدمة',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      address: data['address'] ?? '',
      notes: data['notes'] ?? '',
      status: data['status'] ?? 'pending',
    );
  }
}
