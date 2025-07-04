import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mihnati2/screens/client/screens/client_home_screen.dart';
import 'package:mihnati2/screens/professional/screens/professional_home_screen.dart';
import 'package:mihnati2/Onboarding/onboarding_view.dart';

class HomeRedirectScreen extends StatelessWidget {
  const HomeRedirectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const OnboardingView();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const OnboardingView();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final userType = userData['type'] ?? 'client';

        if (userType == 'professional') {
          return const ProfessionalHomeScreen();
        } else {
          return const ClientHomeScreen();
        }
      },
    );
  }
}
