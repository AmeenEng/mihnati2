import 'package:flutter/material.dart';
import 'package:mihnati2/common/models/review_model.dart';
import 'customer_review_card.dart';

class CustomerReviewsSection extends StatelessWidget {
  final List<ReviewModel> reviews;
  final bool isLoading;

  const CustomerReviewsSection({
    super.key,
    required this.reviews,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'لا توجد تعليقات حتى الآن',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: reviews.map((review) => CustomerReviewCard(review: review)).toList(),
      ),
    );
  }
}