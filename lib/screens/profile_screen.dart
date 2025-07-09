import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';
import 'client/screens/client_edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User _currentUser;

  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _location = '';
  bool _isLoading = true;
  int _bookingCount = 0;

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
        });
      }
      // عدد الحجوزات
      final bookingsSnap = await _firestore
          .collection('bookings')
          .where('clientId', isEqualTo: _currentUser.uid)
          .get();
      if (mounted) {
        setState(() {
          _bookingCount = bookingsSnap.docs.length;
        });
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
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

  void _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد حذف الحساب'),
        content: const Text(
            'هل أنت متأكد أنك تريد حذف حسابك نهائيًا؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      setState(() => _isLoading = true);
      // حذف مستند المستخدم من Firestore
      await _firestore.collection('users').doc(_currentUser.uid).delete();
      // حذف المستخدم من Firebase Auth
      await _currentUser.delete();
      Get.offAllNamed('/login');
      Get.snackbar('تم', 'تم حذف الحساب بنجاح');
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('خطأ', 'حدث خطأ أثناء حذف الحساب: $e');
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
        title: Text('الملف الشخصي', style: TextStyle(color: textColor)),
        centerTitle: true,
        iconTheme: IconThemeData(color: iconColor),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: primaryColor),
            tooltip: 'تعديل الملف',
            onPressed: () async {
              await Get.to(() => const ClientEditProfileScreen());
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
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: Row(
                      children: [
                        Icon(Icons.bookmark, color: iconColor),
                        const SizedBox(width: 10),
                        Text('عدد الحجوزات: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: textColor)),
                        Text('$_bookingCount',
                            style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildProfileItem(Icons.settings, 'الإعدادات',
                      () => Get.toNamed('/settings'), textColor, iconColor),
                  _buildProfileItem(Icons.logout, 'تسجيل الخروج', _logout,
                      textColor, iconColor,
                      isLogout: true),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(45),
                      ),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('حذف الحساب'),
                      onPressed: _deleteAccount,
                    ),
                  ),
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
