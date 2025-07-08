import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mihnati2/common/models/review_model.dart';
import 'package:mihnati2/common/models/service_model.dart';
import 'package:mihnati2/common/widgets/section_header.dart';
import 'package:mihnati2/common/widgets/custom_bottom_nav.dart';
import 'package:mihnati2/screens/professional/screens/settings_screen.dart';
import 'package:mihnati2/screens/professional/widgets/service_management_card.dart';
import 'package:mihnati2/screens/professional/screens/professional_profile_screen.dart';
import 'package:mihnati2/screens/add_service_screen.dart';
import 'package:mihnati2/screens/professional/widgets/professional_performance_card.dart';
import 'package:mihnati2/screens/professional/widgets/customer_reviews_section.dart';
import 'package:mihnati2/screens/professional/widgets/today_appointments.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

class ProfessionalHomeScreen extends StatefulWidget {
  const ProfessionalHomeScreen({super.key});

  @override
  State<ProfessionalHomeScreen> createState() => _ProfessionalHomeScreenState();
}

class _ProfessionalHomeScreenState extends State<ProfessionalHomeScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;
  int _currentIndex = 0;
  int Appointments = 0;
  int _completedJobs = 0;
  double _rating = 0.0;
  bool _isLoading = true;
  bool _hasError = false;
  int _unreadNotifications = 0;
  StreamSubscription? _notificationSubscription;

  // متغيرات لتعليقات العملاء
  List<ReviewModel> _reviews = [];
  bool _reviewsLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeProfessionalData();
      await _loadAllData();
      await _loadReviews();
      await _loadAppointmentsCount();
      _loadUnreadNotifications();
    });
  }

  Future<void> _loadAppointmentsCount() async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final query = _firestore
          .collection('bookings')
          .where('professionalId', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay);

      final snapshot = await query.get();
      setState(() => Appointments = snapshot.docs.length);
    } catch (e) {
      print('Error loading appointments count: $e');
    }
  }

  void _loadUnreadNotifications() {
    final uid = currentUser?.uid;
    if (uid == null) return;

    _notificationSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() => _unreadNotifications = snapshot.docs.length);
      }
    });
  }

  // التحقق من الاتصال بالإنترنت
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // تهيئة البيانات الأساسية للمهني
  Future<void> _initializeProfessionalData() async {
    try {
      if (!await _checkInternetConnection()) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        Get.snackbar("خطأ", "لا يوجد اتصال بالإنترنت",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final uid = currentUser?.uid;
      if (uid == null) return;

      // 1. إنشاء/تحديث مستند المستخدم
      final userDoc = _firestore.collection('users').doc(uid);
      final userData = await userDoc.get();

      if (!userData.exists) {
        await userDoc.set({
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'userType': 'professional',
          'name': currentUser?.displayName ?? 'مهني جديد',
          'email': currentUser?.email,
          'phone': currentUser?.phoneNumber ?? '',
          'profileCompleted': false,
          'bio': 'أهلا، أنا محترف في خدماتي',
        });

        // إنشاء الإحصائيات الأولية
        await _ensureStatsDocumentsExist(uid);
      } else {
        // تحديث البيانات إذا كانت موجودة
        await userDoc.update({
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // 2. إنشاء الإحصائيات الأساسية إذا لم تكن موجودة
      await _ensureStatsDocumentsExist(uid);

      // 3. إنشاء المجموعات الأساسية مع وثيقة بداية
      final collections = [
        'services',
        'bookings',
        'ratings',
        'notifications',
        'availability'
      ];

      for (final collection in collections) {
        final collectionRef = userDoc.collection(collection);
        final snapshot = await collectionRef.limit(1).get();

        if (snapshot.docs.isEmpty) {
          await collectionRef.add({
            'type': 'initial_document',
            'message': 'تم إنشاء هذه المجموعة تلقائيًا',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // 4. إنشاء إعدادات الملف الشخصي
      final settingsDoc = userDoc.collection('settings').doc('profile');
      if (!(await settingsDoc.get()).exists) {
        await settingsDoc.set({
          'notifications': true,
          'availability': {'monday': true, 'tuesday': true},
          'workingHours': {'start': '08:00', 'end': '17:00'},
          'vacationMode': false,
        });
      }

      // 5. إنشاء توفر افتراضي
      final availabilityDoc = userDoc.collection('availability').doc('default');
      if (!(await availabilityDoc.get()).exists) {
        await availabilityDoc.set({
          'days': {
            'sunday': true,
            'monday': true,
            'tuesday': true,
            'wednesday': true,
            'thursday': true,
            'friday': true,
            'saturday': true,
          },
          'slots': [
            {'start': '09:00', 'end': '12:00'},
            {'start': '13:00', 'end': '17:00'},
          ]
        });
      }
    } on FirebaseException catch (e) {
      print("Firebase error: $e");
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      Get.snackbar("خطأ", "حدث خطأ في الاتصال بقاعدة البيانات",
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      print("Error initializing professional data: $e");
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      Get.snackbar("خطأ", "حدث خطأ غير متوقع",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _loadReviews() async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return;

      setState(() => _reviewsLoading = true);

      final collectionRef = _firestore.collection('reviews');
      final query = collectionRef
          .where('professionalId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .limit(3);

      final snapshot = await query.get();

      // التحقق من وجود مستندات
      if (snapshot.docs.isEmpty) {
        if (mounted) {
          setState(() {
            _reviews = [];
            _reviewsLoading = false;
          });
        }
        return;
      }

      final reviews = <ReviewModel>[];
      for (final doc in snapshot.docs) {
        try {
          // معالجة أخطاء تحويل البيانات
          final review = ReviewModel.fromFirestore(doc);
          reviews.add(review);
        } catch (e) {
          print('Error parsing review ${doc.id}: $e');
        }
      }

      if (mounted) {
        setState(() {
          _reviews = reviews;
          _reviewsLoading = false;
        });
      }
    } on FirebaseException catch (e) {
      print('Firestore error [${e.code}]: ${e.message}');

      String errorMessage = "حدث خطأ في تحميل التعليقات";
      if (e.code == 'permission-denied') {
        errorMessage = "ليس لديك صلاحية الوصول للتعليقات";
      } else if (e.code == 'not-found') {
        errorMessage = "مجموعة التعليقات غير موجودة";
      } else if (e.code == 'invalid-argument') {
        errorMessage = "حقل تاريخ التعليقات غير صالح";
      }

      Get.snackbar("خطأ", errorMessage,
          backgroundColor: Colors.red, colorText: Colors.white);

      setState(() => _reviewsLoading = false);
    } catch (e) {
      print('Unexpected error: $e');
      Get.snackbar("خطأ", "حدث خطأ غير متوقع في تحميل التعليقات",
          backgroundColor: Colors.red, colorText: Colors.white);
      setState(() => _reviewsLoading = false);
    }
  }

  Future<void> _ensureStatsDocumentsExist(String uid) async {
    final userDoc = _firestore.collection('users').doc(uid);

    // الأرباح
    final earningsDoc = userDoc.collection('stats').doc('earnings');
    if (!(await earningsDoc.get()).exists) {
      await earningsDoc.set({'total': 0.0});
    }

    // المهام المكتملة
    final jobsDoc = userDoc.collection('stats').doc('jobs');
    if (!(await jobsDoc.get()).exists) {
      await jobsDoc.set({'completed': 0});
    }

    // التقييمات
    final ratingsDoc = userDoc.collection('stats').doc('ratings');
    if (!(await ratingsDoc.get()).exists) {
      await ratingsDoc.set({'total': 0.0, 'count': 0});
    }
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadProfessionalStats(),
      _loadRatings(),
    ]); // تم إزالة _loadMonthlyStats
    setState(() => _isLoading = false);
  }

  Future<void> _loadProfessionalStats() async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return;

      // final earningsDoc = await _firestore
      //     .collection('users')
      //     .doc(uid)
      //     .collection('stats')
      //     .doc('earnings')
      //     .get();

      final jobsDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('stats')
          .doc('jobs')
          .get();

      if (mounted) {
        setState(() {
          _completedJobs =
              jobsDoc.exists ? (jobsDoc['completed'] ?? 0).toInt() : 0;
        });
      }
    } on FirebaseException catch (e) {
      print("Firestore error: $e");
      if (e.code == 'unavailable') {
        Get.snackbar("خطأ", "لا يوجد اتصال بالسيرفر",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        Get.snackbar("خطأ", "حدث خطأ في تحميل الإحصائيات",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print("Error loading stats: $e");
      Get.snackbar("خطأ", "حدث خطأ غير متوقع",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _logout() async {
    try {
      await _notificationSubscription?.cancel();
      // await FirebaseAuth.instance.signOut();
      Future.delayed(Duration.zero, () {
        Get.offAllNamed('/login');
      });
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء تسجيل الخروج');
    }
  }

  Future<void> _loadRatings() async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return;

      double total = 0.0;
      int count = 0;

      final snapshot = await _firestore
          .collection('ratings')
          .where('professionalId', isEqualTo: uid)
          .get();

      for (var doc in snapshot.docs) {
        if (doc.exists &&
            doc.data().containsKey('rating') &&
            doc['rating'] != null) {
          total += (doc['rating'] as num).toDouble();
          count++;
        }
      }

      if (mounted) {
        setState(() {
          _rating = count > 0 ? total / count : 0.0;
        });
      }
    } on FirebaseException catch (e) {
      print("Firestore error: $e");
      if (e.code == 'unavailable') {
        Get.snackbar("خطأ", "لا يوجد اتصال بالسيرفر",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        Get.snackbar("خطأ", "حدث خطأ في تحميل التقييمات",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print("Error loading ratings: $e");
      Get.snackbar("خطأ", "حدث خطأ غير متوقع",
          backgroundColor: Colors.red, colorText: Colors.white);
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
    final drawerColor = isDark ? AppColors.drawerDark : AppColors.drawerLight;
    final primaryColor = AppColors.primaryColor;
    final gradientColors = [primaryColor, primaryColor.withOpacity(0.8)];
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'جاري تحميل البيانات...',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                'حدث خطأ في تحميل البيانات',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: textColor),
              ),
              const SizedBox(height: 10),
              const Text('تأكد من اتصالك بالإنترنت وحاول مرة أخرى'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  await _loadAllData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F3440),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('مهنتي - للمهنيين',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
              color: iconColor,
            ),
            tooltip:
                themeProvider.isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: iconColor),
                onPressed: () => Get.toNamed('/notifications'),
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: iconColor),
            onPressed: () => Get.to(const ProfessionalProfileScreen()),
          ),
        ],
      ),
      drawer: _buildDrawer(drawerColor, textColor, iconColor, cardColor,
          primaryColor, gradientColors),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة الأداء
            ProfessionalPerformanceCard(
              completedJobs: _completedJobs,
              dailyAppointments: Appointments,
              rating: _rating,
            ),

            // مواعيد اليوم
            SectionHeader(
              title: 'مواعيد اليوم',
              onSeeAll: () => Get.toNamed('/appointments'),
              textColor: textColor,
            ),
            TodayAppointments(
              userId: currentUser?.uid ?? '',
              firestore: _firestore,
            ),

            // إدارة الخدمات
            SectionHeader(
              title: 'خدماتي',
              onSeeAll: () => Get.toNamed('/services'),
              textColor: textColor,
            ),
            _buildMyServices(),

            // تعليقات العملاء
            SectionHeader(
              title: 'تعليقات العملاء',
              onSeeAll: () => Get.toNamed('/reviews'),
              textColor: textColor,
            ),
            CustomerReviewsSection(
              reviews: _reviews,
              isLoading: _reviewsLoading,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(const AddServiceScreen()),
        backgroundColor: primaryColor,
        child: Icon(Icons.add, color: iconColor),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: iconColor),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, color: iconColor),
            label: 'المواعيد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment, color: iconColor),
            label: 'الإحصائيات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: iconColor),
            label: 'الملف',
          ),
        ],
        textColor: textColor,
      ),
    );
  }

  Widget _buildMyServices() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('services')
          .where('professionalId', isEqualTo: currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('حدث خطأ في تحميل الخدمات'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('لم تقم بإضافة أي خدمات بعد'),
          );
        }

        final services = snapshot.data!.docs
            .map((doc) => ServiceModel.fromFirestore(doc))
            .toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: services.asMap().entries.map((entry) {
              final service = entry.value;
              final index = entry.key;

              return Padding(
                padding: EdgeInsets.only(
                  left: index == services.length - 1 ? 0 : 15,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 170,
                    maxWidth: 170,
                    minHeight: 170,
                    maxHeight: 240,
                  ),
                  child: ServiceManagementCard(
                    service: service,
                    onEdit: () => Get.to(
                      AddServiceScreen(service: service),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(Color drawerColor, Color textColor, Color iconColor,
      Color cardColor, Color primaryColor, List<Color> gradientColors) {
    return Drawer(
      child: Container(
        color: drawerColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                currentUser?.displayName ?? 'اسم المستخدم',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              accountEmail: Text(
                currentUser?.email ?? 'البريد الإلكتروني',
                style: TextStyle(fontSize: 14, color: textColor),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: cardColor,
                backgroundImage: currentUser?.photoURL != null
                    ? NetworkImage(currentUser!.photoURL!)
                    : null,
                child: currentUser?.photoURL == null
                    ? Text(
                        currentUser?.displayName?.substring(0, 1) ?? 'U',
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      )
                    : null,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            _buildDrawerItem(
                icon: Icons.home,
                title: 'الرئيسية',
                onTap: () {
                  Get.back();
                },
                iconColor: iconColor,
                textColor: textColor),
            _buildDrawerItem(
                icon: Icons.calendar_today,
                title: 'المواعيد',
                onTap: () {
                  Get.back();
                  Get.toNamed('/appointments');
                },
                iconColor: iconColor,
                textColor: textColor),
            _buildDrawerItem(
                icon: Icons.assessment,
                title: 'الإحصائيات',
                onTap: () {
                  Get.back();
                  Get.toNamed('/stats');
                },
                iconColor: iconColor,
                textColor: textColor),
            _buildDrawerItem(
                icon: Icons.person,
                title: 'الملف الشخصي',
                onTap: () {
                  Get.back();
                  Get.to(const ProfessionalProfileScreen());
                },
                iconColor: iconColor,
                textColor: textColor),
            _buildDrawerItem(
                icon: Icons.work,
                title: 'خدماتي',
                onTap: () {
                  Get.back();
                  Get.toNamed('/services');
                },
                iconColor: iconColor,
                textColor: textColor),
            const Divider(),
            _buildDrawerItem(
                icon: Icons.settings,
                title: 'الإعدادات',
                onTap: () {
                  Get.back();
                  Get.to(const SettingsScreen());
                },
                iconColor: iconColor,
                textColor: textColor),
            _buildDrawerItem(
                icon: Icons.help,
                title: 'مساعدة',
                onTap: () {
                  Get.back();
                  Get.toNamed('/help');
                },
                iconColor: iconColor,
                textColor: textColor),
            _buildDrawerItem(
                icon: Icons.info,
                title: 'حول التطبيق',
                onTap: () {
                  Get.back();
                  Get.toNamed('/about');
                },
                iconColor: iconColor,
                textColor: textColor),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color iconColor,
    required Color textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      onTap: onTap,
      hoverColor: textColor.withOpacity(0.1),
    );
  }
}
