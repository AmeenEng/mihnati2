import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // إعدادات الحساب
          const Text(
            'إعدادات الحساب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3440),
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingItem(
            icon: Icons.person,
            title: 'تعديل الملف الشخصي',
            onTap: () => Get.toNamed('/edit-profile'),
          ),
          _buildSettingItem(
            icon: Icons.lock,
            title: 'تغيير كلمة المرور',
            onTap: () => Get.toNamed('/change-password'),
          ),
          SwitchListTile(
            title: const Text('وضع الإجازة'),
            secondary: const Icon(Icons.beach_access),
            value: _vacationMode,
            onChanged: (value) {
              setState(() => _vacationMode = value);
              _updateSetting('vacationMode', value);
            },
          ),

          // إعدادات التطبيق
          const SizedBox(height: 20),
          const Text(
            'إعدادات التطبيق',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3440),
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('تمكين الإشعارات'),
            secondary: const Icon(Icons.notifications),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _updateSetting('notifications', value);
            },
          ),
          SwitchListTile(
            title: const Text('الوضع الليلي'),
            secondary: const Icon(Icons.dark_mode),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() => _darkModeEnabled = value);
              _updateSetting('darkMode', value);
            },
          ),
          _buildSettingItem(
            icon: Icons.access_time,
            title:
                'ساعات العمل (${_workingHours['start']} - ${_workingHours['end']})',
            onTap: () => Get.toNamed('/working-hours'),
          ),
          _buildSettingItem(
            icon: Icons.language,
            title: 'اللغة',
            onTap: () => Get.toNamed('/language'),
          ),

          // معلومات إضافية
          const SizedBox(height: 20),
          const Text(
            'معلومات إضافية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3440),
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingItem(
            icon: Icons.star,
            title: 'قيم التطبيق',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.share,
            title: 'شارك التطبيق',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'سياسة الخصوصية',
            onTap: () => Get.toNamed('/privacy'),
          ),
          _buildSettingItem(
            icon: Icons.description,
            title: 'شروط الاستخدام',
            onTap: () => Get.toNamed('/terms'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3A7D8A)),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
