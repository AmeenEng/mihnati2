import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessionalModel {
  final String id;
  final String name;
  final String bio;
  final double rating;
  final int reviewsCount;
  final int completedJobs;
  final String specialty;
  final String location;
  final String profileImageUrl;
  final bool isFeatured;

  ProfessionalModel({
    required this.id,
    required this.name,
    required this.bio,
    required this.rating,
    required this.reviewsCount,
    required this.completedJobs,
    required this.specialty,
    required this.location,
    required this.profileImageUrl,
    this.isFeatured = false,
  });

  factory ProfessionalModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProfessionalModel(
      id: doc.id,
      name: data['name'] ?? 'مهني بدون اسم',
      bio: data['bio'] ?? 'لا يوجد وصف',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
      completedJobs: data['completedJobs'] ?? 0,
      specialty: data['specialty'] ?? 'عام',
      location: data['location'] ?? 'غير محدد',
      profileImageUrl: data['profileImageUrl'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
    );
  }
}