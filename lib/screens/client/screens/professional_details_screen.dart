import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mihnati2/common/models/professional_model.dart';
import 'package:mihnati2/common/models/service_model.dart';
import 'package:mihnati2/common/models/review_model.dart';
import 'package:mihnati2/screens/booking_screen.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

class ProfessionalDetailsScreen extends StatefulWidget {
  final ProfessionalModel professional;

  const ProfessionalDetailsScreen({super.key, required this.professional});

  @override
  State<ProfessionalDetailsScreen> createState() =>
      _ProfessionalDetailsScreenState();
}

class _ProfessionalDetailsScreenState extends State<ProfessionalDetailsScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<ServiceModel> _services = [];
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadProfessionalData();
  }

  Future<void> _loadProfessionalData() async {
    try {
      // جلب الخدمات
      final servicesSnapshot = await _firestore
          .collection('services')
          .where('professionalId', isEqualTo: widget.professional.id)
          .get();

      _services = servicesSnapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();

      // جلب التقييمات
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('professionalId', isEqualTo: widget.professional.id)
          .orderBy('date', descending: true)
          .limit(5)
          .get();

      _reviews = reviewsSnapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading professional data: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      Get.snackbar("خطأ", "حدث خطأ في تحميل البيانات",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _bookProfessional(ServiceModel service) {
    Get.to(
      BookingScreen(
        professional: widget.professional,
        service: service,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.lightIcon;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title:
            Text(widget.professional.name, style: TextStyle(color: textColor)),
        centerTitle: true,
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: iconColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 50, color: Colors.red),
                      const SizedBox(height: 20),
                      const Text('حدث خطأ في تحميل البيانات'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadProfessionalData,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // رأس الصفحة (صورة ومعلومات أساسية)
                      _buildProfileHeader(),

                      // الخدمات
                      _buildServicesSection(),

                      // التقييمات والتعليقات
                      _buildReviewsSection(),

                      // زر الحجز
                      _buildBookButton(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.lightIcon;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.primaryColor,
            backgroundImage: widget.professional.imageUrl.isNotEmpty
                ? NetworkImage(widget.professional.imageUrl)
                : null,
            child: widget.professional.imageUrl.isEmpty
                ? Icon(Icons.person,
                    size: 40,
                    color:
                        isDark ? AppColors.secondaryColor : AppColors.darkIcon)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.professional.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.professional.profession,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      widget.professional.rating.toStringAsFixed(1),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${widget.professional.completedJobs} تقييم)',
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.work, size: 18, color: iconColor),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.professional.completedJobs} مهمة مكتملة',
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.lightIcon : AppColors.darkIcon;
    final darkBackground =
        isDark ? AppColors.lightBackground : AppColors.darkBackground;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الخدمات المقدمة',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 12),
          ..._services.map((service) => _buildServiceItem(service)).toList(),
        ],
      ),
    );
  }

  Widget _buildServiceItem(ServiceModel service) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final itemColor = isDark ? AppColors.darkBackground : Colors.grey[50];
    final borderColor = isDark ? AppColors.darkCard : Colors.grey[200]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: itemColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryColor),
      ),
      child: Row(
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                service.name,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                service.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                'السعر: ${service.price} ر.س',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ),
            ]),
          ),
          ElevatedButton(
            onPressed: () => _bookProfessional(service),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('حجز', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقييمات والتعليقات',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              TextButton(
                onPressed: () {},
                child: Text('عرض الكل',
                    style: TextStyle(color: AppColors.primaryColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._reviews.map((review) => _buildReviewItem(review)).toList(),
          if (_reviews.isEmpty)
            Center(
              child: Text('لا توجد تعليقات بعد',
                  style: TextStyle(color: textColor)),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? AppColors.lightText : AppColors.darkText;
    final iconColor = isDark ? AppColors.lightIcon : AppColors.darkIcon;
    final itemColor = isDark ? AppColors.darkBackground : Colors.grey[50];
    final borderColor = isDark ? AppColors.darkCard : Colors.grey[200]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: itemColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 24, color: iconColor),
              const SizedBox(width: 8),
              Text(
                review.clientName,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(review.rating.toStringAsFixed(1),
                      style: TextStyle(color: textColor)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment, style: TextStyle(color: textColor)),
          const SizedBox(height: 8),
          Text(
            review.date.toString().substring(0, 10),
            style: TextStyle(
                color: isDark
                    ? AppColors.lightText.withOpacity(0.7)
                    : Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_services.isNotEmpty) {
            _bookProfessional(_services.first);
          } else {
            Get.snackbar(
              'تنبيه',
              'لا توجد خدمات متاحة للحجز حالياً',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'حجز المهني',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
