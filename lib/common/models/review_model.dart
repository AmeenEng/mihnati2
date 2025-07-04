import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String professionalId;
  final String clientId;
  final String clientName;
  final String appointmentId;
  final double rating;
  final String comment;
  final Timestamp date;

  ReviewModel({
    required this.id,
    required this.professionalId,
    required this.clientId,
    required this.clientName,
    required this.appointmentId,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      professionalId: data['professionalId'] ?? '',
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? 'عميل',
      appointmentId: data['appointmentId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      date: data['date'] ?? Timestamp.now(),
    );
  }
}