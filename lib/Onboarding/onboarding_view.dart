import 'package:flutter/material.dart';
import 'package:mihnati2/Components/color.dart';
import 'package:mihnati2/Onboarding/onboarding_items.dart';
import 'package:mihnati2/auth/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final controller = OnboardingItems();
  final pageController = PageController();

  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      bottomSheet: Container(
        color: backGroundColor,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: isLastPage
            ? getStarted()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زر التخطي
                  ElevatedButton(
                    onPressed: () =>
                        pageController.jumpToPage(controller.items.length - 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backGroundColor,
                      foregroundColor: textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      shadowColor: secondaryColor,
                    ),
                    child: Text("تخطي"),
                  ),

                  SmoothPageIndicator(
                    controller: pageController,
                    count: controller.items.length,
                    onDotClicked: (index) => pageController.animateToPage(
                      index,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    ),
                    effect: WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: primaryColor,
                    ),
                  ),

                  // زر الرجوع
                  ElevatedButton(
                    onPressed: () => pageController.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeIn),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backGroundColor,
                      foregroundColor: textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      shadowColor: secondaryColor,
                    ),
                    child: Text("التالي"),
                  ),
                ],
              ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: PageView.builder(
            onPageChanged: (index) => setState(
                () => isLastPage = controller.items.length - 1 == index),
            itemCount: controller.items.length,
            controller: pageController,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(controller.items[index].image),
                  SizedBox(height: 15),
                  Text(
                    controller.items[index].title,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                  SizedBox(height: 15),
                  Text(
                    controller.items[index].descriptions,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor2,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }),
      ),
    );
  }

  Widget getStarted() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: primaryColor,
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextButton(
        onPressed: () {
          final prefs = SharedPreferences.getInstance();
          prefs.then((value) {
            value.setBool("onboarding", true);
          });

          if (!mounted) return;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ));
        },
        child: Text(
          "ابدأ الآن",
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
