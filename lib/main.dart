import 'package:flutter/material.dart';
import 'package:mihnati2/Onboarding/onboarding_view.dart';
import 'package:mihnati2/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'Cairo',
        ),
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
          future: isOnboardingCompleted(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else {
              final isCompleted = snapshot.data ?? false;
              return isCompleted ? Login() : OnboardingView();
            }
          },
        ),
      ),
    );
  }
}

Future<bool> isOnboardingCompleted() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding') ?? false;
}
