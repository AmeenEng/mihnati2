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

    _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      setState(() => _unreadNotifications = snapshot.docs.length);
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
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed('/login');
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'جاري تحميل البيانات...',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                'حدث خطأ في تحميل البيانات',
                style: Theme.of(context).textTheme.titleLarge,
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('مهنتي - للمهنيين',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1F3440), Color(0xFF3A7D8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => Get.to(const ProfessionalProfileScreen()),
          ),
        ],
      ),
      drawer: _buildDrawer(),
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
            ),
            TodayAppointments(
              userId: currentUser?.uid ?? '',
              firestore: _firestore,
            ),

            // إدارة الخدمات
            SectionHeader(
              title: 'خدماتي',
              onSeeAll: () => Get.toNamed('/services'),
            ),
            _buildMyServices(),

            // تعليقات العملاء
            SectionHeader(
              title: 'تعليقات العملاء',
              onSeeAll: () => Get.toNamed('/reviews'),
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
        backgroundColor: const Color(0xFF1F3440),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'المواعيد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'الإحصائيات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف',
          ),
        ],
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

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1F3440), Color(0xFF3A7D8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // رأس الدرج
            UserAccountsDrawerHeader(
              accountName: Text(
                currentUser?.displayName ?? 'اسم المستخدم',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                currentUser?.email ?? 'البريد الإلكتروني',
                style: const TextStyle(fontSize: 14),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  currentUser?.displayName?.substring(0, 1) ?? 'U',
                  style: const TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3440),
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
            ),

            // قسم التنقل
            _buildDrawerItem(
              icon: Icons.home,
              title: 'الرئيسية',
              onTap: () {
                Get.back();
              },
            ),
            _buildDrawerItem(
              icon: Icons.calendar_today,
              title: 'المواعيد',
              onTap: () {
                Get.back();
                Get.toNamed('/appointments');
              },
            ),
            _buildDrawerItem(
              icon: Icons.assessment,
              title: 'الإحصائيات',
              onTap: () {
                Get.back();
                Get.toNamed('/stats');
              },
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'الملف الشخصي',
              onTap: () {
                Get.back();
                Get.to(const ProfessionalProfileScreen());
              },
            ),
            _buildDrawerItem(
              icon: Icons.work,
              title: 'خدماتي',
              onTap: () {
                Get.back();
                Get.toNamed('/services');
              },
            ),

            // قسم الإعدادات
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 20, bottom: 8),
              child: Text(
                'الإعدادات',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'الإعدادات',
              onTap: () {
                Get.back();
                Get.to(const SettingsScreen());
              },
            ),
            _buildDrawerItem(
              icon: Icons.help,
              title: 'مساعدة',
              onTap: () {
                Get.back();
                Get.toNamed('/help');
              },
            ),
            _buildDrawerItem(
              icon: Icons.info,
              title: 'حول التطبيق',
              onTap: () {
                Get.back();
                Get.toNamed('/about');
              },
            ),

            // تسجيل الخروج
            const Divider(color: Colors.white24),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'تسجيل الخروج',
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
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
    );
  }
}
