import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    // Theme-aware gradient
    final backgroundGradient = LinearGradient(
      colors: isDark
          ? [AppColors.darkBackground, AppColors.primaryColor]
          : [AppColors.lightBackground, AppColors.primaryColor],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
    // Theme-aware card color
    final cardColor = isDark
        ? AppColors.darkCard.withOpacity(0.85)
        : AppColors.lightCard.withOpacity(0.85);
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final primaryColor = AppColors.primaryColor;
    final secondaryColor = AppColors.secondaryColor;
    final bulletColor =
        isDark ? AppColors.secondaryColor : AppColors.primaryColor;
    final noteColor = isDark ? AppColors.secondaryColor : Colors.brown;
    final thankColor = isDark ? AppColors.secondaryColor : Colors.redAccent;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 4,
        title: Text(
          'حول التطبيق',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: AnimatedBuilder(
        animation: _fadeIn,
        builder: (context, child) =>
            Opacity(opacity: _fadeIn.value, child: child),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: backgroundGradient),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxCardWidth =
                    screenWidth < 600 ? screenWidth * 0.9 : 500;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: maxCardWidth,
                      margin: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                            color: secondaryColor.withOpacity(0.2), width: 1.5),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 30),
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              backgroundImage: const AssetImage(
                                  'assets/image/logo/logo.png'),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'تطبيق مهنتي',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                fontFamily: 'Cairo',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'تم تطوير هذا التطبيق كمشروع تخرج لنيل درجة الدبلوم في قسم تقنية المعلومات - الكلية الألمانية 2024 / 2025',
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Cairo',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),
                            // Project Info Section
                            _SectionCard(
                              icon: Icons.info_outline,
                              title: 'عن المشروع',
                              color: primaryColor,
                              isDark: isDark,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'تطبيق مهنتي هو مشروع تخرج لنيل درجة الدبلوم في قسم تقنية المعلومات بالكلية الألمانية للعام 2024 / 2025.',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Cairo',
                                        color: textColor),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Students Section
                            _SectionCard(
                              icon: Icons.people_alt_rounded,
                              title: 'فريق العمل:',
                              color: primaryColor,
                              isDark: isDark,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _StudentItem(
                                        name: 'أمين جمال العليمي',
                                        bulletColor: bulletColor,
                                        noteColor: noteColor),
                                    _StudentItem(
                                        name: 'عبدالسلام العماري',
                                        bulletColor: bulletColor,
                                        noteColor: noteColor),
                                    _StudentItem(
                                        name: 'عبدالرحمن المقالح',
                                        bulletColor: bulletColor,
                                        noteColor: noteColor),
                                    _StudentItem(
                                        name: 'محمد عماد كراجه',
                                        bulletColor: bulletColor,
                                        noteColor: noteColor),
                                    _StudentItem(
                                        name: 'أبوبكر عبدالسلام الحائر',
                                        bulletColor: bulletColor,
                                        noteColor: noteColor),
                                    _StudentItem(
                                        name: 'أحمد محمد عقبة',
                                        bulletColor: bulletColor,
                                        noteColor: noteColor),
                                    _StudentItem(
                                        name: 'طه الخولاني',
                                        bulletColor: bulletColor,
                                        noteColor: noteColor),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Supervisor Section
                            _SectionCard(
                              icon: Icons.school_rounded,
                              title: 'المشرف الأكاديمي:',
                              color: secondaryColor,
                              isDark: isDark,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'د/ ريان الكمالي',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                      color: textColor),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Thank You Section
                            _SectionCard(
                              icon: Icons.favorite_rounded,
                              title: 'شكر وتقدير',
                              color: thankColor,
                              isDark: isDark,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'كل الشكر والتقدير لكل من ساهم في إنجاح هذا المشروع.',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Cairo',
                                      color: textColor),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;
  final bool isDark;
  const _SectionCard(
      {required this.icon,
      required this.title,
      required this.color,
      required this.child,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.10 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: color.withOpacity(isDark ? 0.25 : 0.18), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontFamily: 'Cairo')),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: color, size: 26),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StudentItem extends StatelessWidget {
  final String name;
  final String? note;
  final Color bulletColor;
  final Color noteColor;
  const _StudentItem(
      {required this.name,
      this.note,
      required this.bulletColor,
      required this.noteColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text(
                '($note)',
                style: TextStyle(
                  fontSize: 14,
                  color: noteColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          Icon(Icons.circle, size: 8, color: bulletColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, fontFamily: 'Cairo'),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
