import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final cardColor = isDark
        ? AppColors.darkCard.withOpacity(0.7)
        : AppColors.lightCard.withOpacity(0.85);
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final primaryColor = AppColors.primaryColor;
    final secondaryColor = AppColors.secondaryColor;
    final backgroundGradient = LinearGradient(
      colors: isDark
          ? [AppColors.darkBackground, AppColors.primaryColor.withOpacity(0.7)]
          : [
              AppColors.lightBackground,
              AppColors.primaryColor.withOpacity(0.4)
            ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 4,
        title: Text(
          'المساعدة والدعم',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 22,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Opacity(
            opacity: _fadeIn.value,
            child: SlideTransition(
              position: _slideUp,
              child: child,
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? size.width * 0.95 : 500,
                  minHeight: size.height - (isSmallScreen ? 120 : 80),
                ),
                margin: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 16 : 32,
                  horizontal: isSmallScreen ? 8 : 16,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: isSmallScreen ? 12 : 16,
                        sigmaY: isSmallScreen ? 12 : 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                            BorderRadius.circular(isSmallScreen ? 24 : 32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: secondaryColor.withOpacity(0.15),
                          width: 1.2,
                        ),
                      ),
                      padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Welcome Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 16),
                            decoration: BoxDecoration(
                              color: secondaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'دعم مهنتي معك دائمًا',
                              style: TextStyle(
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 14 : 16,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // Illustration Image
                          Image.asset(
                            'assets/image/Customer feedback-amico.png',
                            height: isSmallScreen ? 100 : 140,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // Main Title
                          Text(
                            'نحن هنا لمساعدتك!',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 24 : 28,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontFamily: 'Cairo',
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),

                          // Description
                          Text(
                            'إذا واجهتك أي مشكلة أو لديك استفسار، لا تتردد في التواصل معنا عبر الطرق التالية. فريق الدعم جاهز دائما لخدمتك',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 15 : 16,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Cairo',
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 28),

                          // Contact Methods Title
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'طرق التواصل:',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 17 : 19,
                                fontWeight: FontWeight.bold,
                                color: secondaryColor,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),

                          // Contact Buttons
                          isSmallScreen
                              ? Column(
                                  children: [
                                    _buildContactButton(
                                      context,
                                      icon: Icons.email,
                                      label: 'البريد الإلكتروني',
                                      color: primaryColor,
                                      isSmallScreen: isSmallScreen,
                                      onPressed: () => _launchEmail(context),
                                    ),
                                    SizedBox(height: 12),
                                    _buildContactButton(
                                      context,
                                      icon: FontAwesomeIcons.whatsapp,
                                      label: 'واتساب',
                                      color: Colors.green,
                                      isSmallScreen: isSmallScreen,
                                      onPressed: () => _launchWhatsApp(context),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: _buildContactButton(
                                        context,
                                        icon: Icons.email,
                                        label: 'البريد الإلكتروني',
                                        color: primaryColor,
                                        isSmallScreen: isSmallScreen,
                                        onPressed: () => _launchEmail(context),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: _buildContactButton(
                                        context,
                                        icon: FontAwesomeIcons.whatsapp,
                                        label: 'واتساب',
                                        color: Colors.green,
                                        isSmallScreen: isSmallScreen,
                                        onPressed: () =>
                                            _launchWhatsApp(context),
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(height: isSmallScreen ? 16 : 22),

                          // Response Time
                          Text(
                            'نرد عادة خلال دقائق في أوقات العمل الرسمية',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: secondaryColor.withOpacity(0.85),
                              fontFamily: 'Cairo',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 28),

                          // Divider
                          Divider(
                            color: secondaryColor.withOpacity(0.2),
                            thickness: 1.1,
                          ),
                          SizedBox(height: isSmallScreen ? 14 : 18),

                          // Support Hours
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time,
                                  color: secondaryColor,
                                  size: isSmallScreen ? 18 : 20),
                              SizedBox(width: 8),
                              Text(
                                'ساعات الدعم: 9 صباحا - 9 مساء (كل أيام الأسبوع)',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 15,
                                  color: textColor.withOpacity(0.8),
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 18 : 24),

                          // Thank You Note
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 10 : 12,
                              horizontal: isSmallScreen ? 14 : 18,
                            ),
                            decoration: BoxDecoration(
                              color: secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite,
                                    color: Colors.redAccent,
                                    size: isSmallScreen ? 18 : 20),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'شكراً لاستخدامك تطبيق مهنتي نحن هنا دائما لدعمك!',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 15 : 16,
                                      color: secondaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required bool isSmallScreen,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        ),
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 14 : 16,
          horizontal: isSmallScreen ? 12 : 16,
        ),
        elevation: 0,
        minimumSize: Size(double.infinity, isSmallScreen ? 50 : 56),
      ),
      icon: Icon(icon, size: isSmallScreen ? 22 : 24),
      label: Text(
        label,
        style: TextStyle(
          fontSize: isSmallScreen ? 15 : 16,
          fontFamily: 'Cairo',
        ),
      ),
      onPressed: onPressed,
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'ameenalalimi170@gmail.com',
      queryParameters: {
        'subject': 'دعم تطبيق مهنتي',
        'body': 'السلام عليكم،\n\nأحتاج إلى مساعدة بخصوص:',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showErrorDialog(context, 'لا يوجد تطبيق بريد إلكتروني مثبت');
    }
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    const phoneNumber = '967737927289';
    const message = 'مرحباً، أحتاج إلى دعم في تطبيق مهنتي';

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorDialog(context, 'تطبيق واتساب غير مثبت');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حدث خطأ', style: TextStyle(fontFamily: 'Cairo')),
        content: Text(message, style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('حسناً', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}
