import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

class ProfessionalPerformanceCard extends StatelessWidget {
  final int completedJobs;
  final int dailyAppointments; // Changed from earnings to dailyAppointments
  final double rating;

  const ProfessionalPerformanceCard({
    super.key,
    required this.completedJobs,
    required this.dailyAppointments, // Updated parameter
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.lightIcon;
    final primaryColor = AppColors.primaryColor;
    final gradientColors = [primaryColor, primaryColor.withOpacity(0.8)];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                    Icons.work, 'المهام المكتملة', '$completedJobs', textColor),
                _buildStatItem(Icons.calendar_today, 'المواعيد اليومية',
                    '$dailyAppointments', textColor),
                _buildStatItem(Icons.star, 'التقييم',
                    rating > 0 ? rating.toStringAsFixed(1) : '0.0', textColor),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed('/schedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'إدارة الجدول',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed('/earnings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: cardColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'عرض الأرباح',
                      style: TextStyle(color: cardColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String title, String value, Color textColor) {
    return Column(
      children: [
        Icon(icon, color: textColor, size: 30),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
