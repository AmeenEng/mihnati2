import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mihnati2/screens/professional/screens/settings_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف المهني'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _currentUser.photoURL != null
                        ? NetworkImage(_currentUser.photoURL!)
                        : null,
                    child: _currentUser.photoURL == null
                        ? const Icon(Icons.person,
                            size: 60, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _fullName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      _bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem(_rating.toStringAsFixed(1), 'التقييم'),
                      _buildStatItem('$_completedJobs', 'المهام'),
                      _buildStatItem('$_experienceYears سنوات', 'الخبرة'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildProfileItem(Icons.badge, 'الملف المهني',
                      () => Get.toNamed('/edit-profile')),
                  _buildProfileItem(Icons.work_history, 'سجل الأعمال',
                      () => Get.toNamed('/work-history')),
                  _buildProfileItem(Icons.analytics, 'الإحصائيات',
                      () => Get.toNamed('/stats')),
                  _buildProfileItem(Icons.credit_card, 'المدفوعات',
                      () => Get.toNamed('/payments')),
                  _buildProfileItem(Icons.settings, 'إعدادات الحساب',
                      () => Get.to(const SettingsScreen())),
                  _buildProfileItem(Icons.logout, 'تسجيل الخروج', _logout,
                      isLogout: true),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String value, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3440),
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap,
      {bool isLogout = false}) {
    return ListTile(
      leading:
          Icon(icon, color: isLogout ? Colors.red : const Color(0xFF1F3440)),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
