import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/screens/professional/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';
import 'package:mihnati2/screens/edit_profile_screen.dart';

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

  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _location = '';
  List<String> _services = [];
  String _bio = 'أهلا، أنا محترف في خدماتي';
  int _completedJobs = 0;
  double _rating = 0.0;
  int _experienceYears = 0;
  bool _isLoading = true;
  int _totalAppointments = 0;
  int _totalServices = 0;

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
      final data = userDoc.data() ?? {};
      if (userDoc.exists && mounted) {
        setState(() {
          _fullName = data['fullName'] ?? '';
          _email = data['email'] ?? _currentUser.email ?? '';
          _phone = data['phone'] ?? '';
          _location = data['location'] ?? '';
          _services = data['services'] != null
              ? List<String>.from(data['services'])
              : [];
          _bio = data['bio'] ?? '';
        });
      }
      // عدد المواعيد
      final appointmentsSnap = await _firestore
          .collection('bookings')
          .where('professionalId', isEqualTo: _currentUser.uid)
          .get();
      print('عدد المواعيد: ${appointmentsSnap.docs.length}');
      if (mounted) {
        setState(() {
          _totalAppointments = appointmentsSnap.docs.length;
        });
      }
      // عدد الخدمات
      final servicesSnap = await _firestore
          .collection('services')
          .where('professionalId', isEqualTo: _currentUser.uid)
          .get();
      print('عدد الخدمات: ${servicesSnap.docs.length}');
      if (mounted) {
        setState(() {
          _totalServices = servicesSnap.docs.length;
        });
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading profile data: $e');
      if (mounted) {
        Get.snackbar('خطأ', 'حدث خطأ في تحميل بيانات الملف الشخصي: $e');
        setState(() => _isLoading = false);
      }
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
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: primaryColor),
            tooltip: 'تعديل الملف',
            onPressed: () async {
              await Get.to(() => const EditProfileScreen());
              _loadProfileData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // دائرة حول أيقونة البروفايل
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: primaryColor, width: 2),
                    ),
                    child: Center(
                      child: Icon(Icons.person, size: 60, color: iconColor),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow(Icons.person, 'الاسم الكامل', _fullName,
                      textColor, iconColor),
                  _buildInfoRow(Icons.email, 'البريد الإلكتروني', _email,
                      textColor, iconColor),
                  _buildInfoRow(
                      Icons.phone, 'رقم الهاتف', _phone, textColor, iconColor),
                  _buildInfoRow(Icons.location_on, 'المدينة/المنطقة', _location,
                      textColor, iconColor),
                  // عرض عدد المواعيد وعدد الخدمات
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: Row(
                      children: [
                        Icon(Icons.event_note, color: iconColor),
                        const SizedBox(width: 10),
                        Text('عدد المواعيد: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: textColor)),
                        Text('$_totalAppointments',
                            style: TextStyle(color: textColor)),
                        const SizedBox(width: 24),
                        Icon(Icons.home_repair_service, color: iconColor),
                        const SizedBox(width: 10),
                        Text('عدد الخدمات: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: textColor)),
                        Text('$_totalServices',
                            style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                  // عرض الخدمات كسطر نصي مفصول بفواصل بدون كلمة تنظيف
                  if (_services.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 6),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _services.where((s) => s != 'تنظيف').join('، '),
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
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

  Widget _buildInfoRow(IconData icon, String label, String value,
      Color textColor, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Text('$label: ',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          Expanded(
            child: Text(value,
                style: TextStyle(color: textColor),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesRow(
      List<String> services, Color textColor, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.handyman, color: iconColor),
          const SizedBox(width: 10),
          Text('الخدمات: ',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          Expanded(
            child: services.isEmpty
                ? Text('لا توجد خدمات', style: TextStyle(color: textColor))
                : Wrap(
                    spacing: 6,
                    children: services
                        .map((s) => Chip(
                            label: Text(s, style: TextStyle(color: textColor))))
                        .toList(),
                  ),
          ),
        ],
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
