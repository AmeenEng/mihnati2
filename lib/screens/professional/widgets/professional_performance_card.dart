import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1F3440), Color(0xFF3A7D8A)],
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
                _buildStatItem(Icons.work, 'المهام المكتملة', '$completedJobs'),
                // Updated stat item for daily appointments
                _buildStatItem(Icons.calendar_today, 'المواعيد اليومية', '$dailyAppointments'),
                _buildStatItem(Icons.star, 'التقييم', rating > 0 ? rating.toStringAsFixed(1) : '0.0'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed('/schedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'إدارة الجدول',
                      style: TextStyle(color: Color(0xFF1F3440)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed('/earnings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'عرض الأرباح',
                      style: TextStyle(color: Colors.white),
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

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}