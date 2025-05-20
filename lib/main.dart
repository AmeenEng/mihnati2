import 'package:flutter/material.dart';
import 'package:mihnati2/Onboarding/onboarding_view.dart';

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
        home: OnboardingView(),
      ),
    );
  }
}
