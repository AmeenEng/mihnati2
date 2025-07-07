import 'package:flutter/material.dart';
import 'package:mihnati2/common/models/review_model.dart';
import 'customer_review_card.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'لا توجد تعليقات حتى الآن',
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor.withOpacity(0.7)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: reviews
            .map((review) => CustomerReviewCard(review: review))
            .toList(),
      ),
    );
  }
}
