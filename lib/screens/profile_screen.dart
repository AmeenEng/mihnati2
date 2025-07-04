import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 15),
            Text(
              user?.displayName ?? 'مستخدم',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'لا يوجد بريد إلكتروني',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _buildProfileItem(Icons.person, 'تعديل الملف الشخصي'),
            _buildProfileItem(Icons.history, 'سجل الحجوزات'),
            _buildProfileItem(Icons.payment, 'طرق الدفع'),
            _buildProfileItem(Icons.settings, 'الإعدادات'),
            _buildProfileItem(Icons.help, 'المساعدة والدعم'),
            _buildProfileItem(Icons.logout, 'تسجيل الخروج', isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : const Color(0xFF1F3440)),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        if (isLogout) {
          FirebaseAuth.instance.signOut();
          Get.offAllNamed('/login');
        }
      },
    );
  }
}