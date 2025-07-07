import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/common/models/service_model.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

class ServiceManagementCard extends StatelessWidget {
  final ServiceModel service;
  final Function() onEdit;

  const ServiceManagementCard({
    super.key,
    required this.service,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.lightIcon;
    final primaryColor = AppColors.primaryColor;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          color: cardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 250,
              maxHeight: 320,
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (service.imagePath.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                        child: Image.file(
                          File(service.imagePath),
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              color: cardColor,
                              child:
                                  Icon(Icons.image, size: 50, color: iconColor),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        color: cardColor,
                        child: Icon(Icons.image, size: 50, color: iconColor),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            service.category,
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                '${service.price} ر.ي',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: cardColor.withOpacity(0.2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, size: 20, color: iconColor),
                          onPressed: onEdit,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              size: 20, color: Colors.red),
                          onPressed: () =>
                              _showDeleteDialog(context, service.id),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String serviceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الخدمة'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذه الخدمة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteService(serviceId);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteService(String serviceId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('services').doc(serviceId).delete();
      Get.snackbar('تم الحذف', 'تم حذف الخدمة بنجاح',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء الحذف: ${e.toString()}',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
