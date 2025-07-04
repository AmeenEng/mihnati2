import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final double rating;
  final int reviews;
  final String imagePath;
  final String? professionalId;

  ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.imagePath,
    this.professionalId,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      name: data['name'] ?? 'غير معروف',
      category: data['category'] ?? 'عام',
      description: data['description'] ?? 'لا يوجد وصف',
      price: (data['price'] ?? 0.0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: data['reviews'] ?? 0,
      imagePath: data['imagePath'] ?? '',
      professionalId: data['professionalId'],
    );
  }
}