import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessionalModel {
  final String id;
  final String name;
  final String profession;
  final double rating;
  final int completedJobs;
  final String imageUrl;
  final bool isFeatured;

  ProfessionalModel({
    required this.id,
    required this.name,
    required this.profession,
    required this.rating,
    required this.completedJobs,
    required this.imageUrl,
    required this.isFeatured,
  });

  factory ProfessionalModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ProfessionalModel(
      id: doc.id,
      name: data['name'] ?? 'غير معروف',
      profession: data['profession'] ?? 'مهني',
      rating: (data['rating'] ?? 0.0).toDouble(),
      completedJobs: data['completedJobs'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
    );
  }
}