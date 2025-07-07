import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _vacationMode = false;
  Map<String, dynamic> _workingHours = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('profile')
          .get();

      if (doc.exists) {
        setState(() {
          _notificationsEnabled = doc['notifications'] ?? true;
          _darkModeEnabled = doc['darkMode'] ?? false;
          _vacationMode = doc['vacationMode'] ?? false;
          _workingHours =
              doc['workingHours'] ?? {'start': '08:00', 'end': '17:00'};
        });
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading settings: $e');
      Get.snackbar('خطأ', 'حدث خطأ في تحميل الإعدادات');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('profile')
          .update({key: value});
    } catch (e) {
      print('Error updating setting: $e');
      Get.snackbar('خطأ', 'حدث خطأ في تحديث الإعداد');
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

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: Text('الإعدادات', style: TextStyle(color: textColor)),
        centerTitle: true,
        iconTheme: IconThemeData(color: iconColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // إعدادات الحساب
          Text(
            'إعدادات الحساب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingItem(
            icon: Icons.person,
            title: 'تعديل الملف الشخصي',
            onTap: () => Get.toNamed('/edit-profile'),
            iconColor: iconColor,
            textColor: textColor,
          ),
          _buildSettingItem(
            icon: Icons.lock,
            title: 'تغيير كلمة المرور',
            onTap: () => Get.toNamed('/change-password'),
            iconColor: iconColor,
            textColor: textColor,
          ),
          SwitchListTile(
            title: Text('وضع الإجازة', style: TextStyle(color: textColor)),
            secondary: Icon(Icons.beach_access, color: iconColor),
            value: _vacationMode,
            onChanged: (value) {
              setState(() => _vacationMode = value);
              _updateSetting('vacationMode', value);
            },
            activeColor: primaryColor,
          ),

          // إعدادات التطبيق
          const SizedBox(height: 20),
          Text(
            'إعدادات التطبيق',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: Text('تمكين الإشعارات', style: TextStyle(color: textColor)),
            secondary: Icon(Icons.notifications, color: iconColor),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _updateSetting('notifications', value);
            },
            activeColor: primaryColor,
          ),
          SwitchListTile(
            title: Text('الوضع الليلي', style: TextStyle(color: textColor)),
            secondary: Icon(Icons.dark_mode, color: iconColor),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
              _updateSetting('darkMode', value);
            },
            activeColor: primaryColor,
          ),
          _buildSettingItem(
            icon: Icons.access_time,
            title:
                'ساعات العمل (${_workingHours['start']} - ${_workingHours['end']})',
            onTap: () => Get.toNamed('/working-hours'),
            iconColor: iconColor,
            textColor: textColor,
          ),
          _buildSettingItem(
            icon: Icons.language,
            title: 'اللغة',
            onTap: () => Get.toNamed('/language'),
            iconColor: iconColor,
            textColor: textColor,
          ),

          // معلومات إضافية
          const SizedBox(height: 20),
          Text(
            'معلومات إضافية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingItem(
            icon: Icons.star,
            title: 'قيم التطبيق',
            onTap: () {},
            iconColor: iconColor,
            textColor: textColor,
          ),
          _buildSettingItem(
            icon: Icons.share,
            title: 'شارك التطبيق',
            onTap: () {},
            iconColor: iconColor,
            textColor: textColor,
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'سياسة الخصوصية',
            onTap: () => Get.toNamed('/privacy'),
            iconColor: iconColor,
            textColor: textColor,
          ),
          _buildSettingItem(
            icon: Icons.description,
            title: 'شروط الاستخدام',
            onTap: () => Get.toNamed('/terms'),
            iconColor: iconColor,
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color iconColor,
    required Color textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
      onTap: onTap,
    );
  }
}
