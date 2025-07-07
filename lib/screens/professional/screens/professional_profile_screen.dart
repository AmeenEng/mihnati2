import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/screens/professional/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

class ProfessionalProfileScreen extends StatefulWidget {
  const ProfessionalProfileScreen({super.key});

  @override
  State<ProfessionalProfileScreen> createState() =>
      _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends State<ProfessionalProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User _currentUser;

  String _fullName = 'مهني محترف';
  String _bio = 'أهلا، أنا محترف في خدماتي';
  int _completedJobs = 0;
  double _rating = 0.0;
  int _experienceYears = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(_currentUser.uid).get();

      if (userDoc.exists) {
        setState(() {
          _fullName =
              userDoc['name'] ?? _currentUser.displayName ?? 'مهني محترف';
          _bio = userDoc['bio'] ?? 'أهلا، أنا محترف في خدماتي';
        });
      }

      // جلب عدد المهام المكتملة
      final jobsDoc = await _firestore
          .collection('users')
          .doc(_currentUser.uid)
          .collection('stats')
          .doc('jobs')
          .get();

      if (jobsDoc.exists) {
        setState(() {
          _completedJobs = jobsDoc['completed'] ?? 0;
        });
      }

      // جلب التقييمات
      final ratingsDoc = await _firestore
          .collection('users')
          .doc(_currentUser.uid)
          .collection('stats')
          .doc('ratings')
          .get();

      if (ratingsDoc.exists) {
        final total = ratingsDoc['total'] ?? 0.0;
        final count = ratingsDoc['count'] ?? 0;
        setState(() {
          _rating = count > 0 ? total / count : 0.0;
        });
      }

      // جلب سنوات الخبرة
      final expDoc = await _firestore
          .collection('users')
          .doc(_currentUser.uid)
          .collection('professional_info')
          .doc('experience')
          .get();

      if (expDoc.exists) {
        setState(() {
          _experienceYears = expDoc['years'] ?? 0;
        });
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading profile data: $e');
      Get.snackbar('خطأ', 'حدث خطأ في تحميل بيانات الملف الشخصي');
      setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء تسجيل الخروج');
    }
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
    final primaryColor = AppColors.primaryColor;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: Text('ملف المهني', style: TextStyle(color: textColor)),
        centerTitle: true,
        iconTheme: IconThemeData(color: iconColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: cardColor,
                    backgroundImage: _currentUser.photoURL != null
                        ? NetworkImage(_currentUser.photoURL!)
                        : null,
                    child: _currentUser.photoURL == null
                        ? Icon(Icons.person, size: 60, color: iconColor)
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _fullName,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      _bio,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor.withOpacity(0.7)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem(_rating.toStringAsFixed(1), 'التقييم',
                          textColor, primaryColor),
                      _buildStatItem(
                          '$_completedJobs', 'المهام', textColor, primaryColor),
                      _buildStatItem('$_experienceYears سنوات', 'الخبرة',
                          textColor, primaryColor),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildProfileItem(Icons.badge, 'الملف المهني',
                      () => Get.toNamed('/edit-profile'), textColor, iconColor),
                  _buildProfileItem(Icons.work_history, 'سجل الأعمال',
                      () => Get.toNamed('/work-history'), textColor, iconColor),
                  _buildProfileItem(Icons.analytics, 'الإحصائيات',
                      () => Get.toNamed('/stats'), textColor, iconColor),
                  _buildProfileItem(Icons.credit_card, 'المدفوعات',
                      () => Get.toNamed('/payments'), textColor, iconColor),
                  _buildProfileItem(
                      Icons.settings,
                      'إعدادات الحساب',
                      () => Get.to(const SettingsScreen()),
                      textColor,
                      iconColor),
                  _buildProfileItem(Icons.logout, 'تسجيل الخروج', _logout,
                      textColor, iconColor,
                      isLogout: true),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(
      String value, String title, Color textColor, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(color: textColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap,
      Color textColor, Color iconColor,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
      onTap: onTap,
    );
  }
}
