import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String professionalId;
  final int duration; 
  final double rating;
  final int reviewsCount;
  final String imageUrl;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.professionalId,
    required this.duration,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.imageUrl = '',
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      title: data['title'] ?? 'خدمة بدون عنوان',
      description: data['description'] ?? 'لا يوجد وصف',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? 'عام',
      professionalId: data['professionalId'] ?? '',
      duration: data['duration'] ?? 60,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'professionalId': professionalId,
      'duration': duration,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'imageUrl': imageUrl,
    };
  }
}