import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:mihnati2/common/models/service_model.dart';
import 'package:mihnati2/screens/add_service_screen.dart';
import 'package:mihnati2/screens/professional/widgets/service_management_card.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

class ProfessionalMyServicesScreen extends StatelessWidget {
  const ProfessionalMyServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.lightIcon;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final currentUser = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: iconColor),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.home_repair_service, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Text('خدماتي',
                style:
                    TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddServiceScreen()),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('إضافة خدمة'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('services')
            .where('professionalId', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('حدث خطأ في تحميل الخدمات',
                  style: TextStyle(color: Colors.red)),
            );
          }
          final services = snapshot.data?.docs
                  .map((doc) => ServiceModel.fromFirestore(doc))
                  .toList() ??
              [];

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.list_alt, color: AppColors.primaryColor),
                    const SizedBox(width: 8),
                    Text('عدد الخدمات: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: textColor)),
                    Text('${services.length}',
                        style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ],
                ),
              ),
              Expanded(
                child: services.isEmpty
                    ? Align(
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_repair_service,
                                  color: AppColors.primaryColor, size: 60),
                              const SizedBox(height: 16),
                              Text('لم تقم بإضافة أي خدمات بعد',
                                  style: TextStyle(
                                      color: textColor.withOpacity(0.7),
                                      fontSize: 18)),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.10),
                                  width: 1.2),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 16),
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.primaryColor.withOpacity(0.12),
                                child: Icon(Icons.home_repair_service,
                                    color: AppColors.primaryColor),
                              ),
                              title: Text(service.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                      fontSize: 16)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.category,
                                          color: iconColor.withOpacity(0.7),
                                          size: 16),
                                      const SizedBox(width: 4),
                                      Text(service.category,
                                          style: TextStyle(
                                              color: textColor.withOpacity(0.8),
                                              fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.attach_money,
                                          color: Colors.green, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                          '${service.price.toStringAsFixed(2)} ر.س',
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                    ],
                                  ),
                                  if (service.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            color: iconColor.withOpacity(0.7),
                                            size: 16),
                                        const SizedBox(width: 4),
                                        Expanded(
                                            child: Text(service.description,
                                                style: TextStyle(
                                                    color: textColor
                                                        .withOpacity(0.7),
                                                    fontSize: 13),
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, color: iconColor),
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    Get.to(() =>
                                        AddServiceScreen(service: service));
                                  } else if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('تأكيد الحذف'),
                                        content: const Text(
                                            'هل أنت متأكد أنك تريد حذف هذه الخدمة؟'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('إلغاء'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            child: const Text('حذف',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await firestore
                                          .collection('services')
                                          .doc(service.id)
                                          .delete();
                                      Get.snackbar(
                                          'تم الحذف', 'تم حذف الخدمة بنجاح',
                                          backgroundColor:
                                              Colors.green.shade100,
                                          colorText: Colors.black);
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit,
                                            color: AppColors.primaryColor),
                                        const SizedBox(width: 8),
                                        const Text('تعديل'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        const SizedBox(width: 8),
                                        const Text('حذف'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
