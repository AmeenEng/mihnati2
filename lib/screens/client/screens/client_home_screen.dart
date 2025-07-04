import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mihnati2/common/models/service_model.dart';
import 'package:mihnati2/common/models/professional_model.dart';
import 'package:mihnati2/common/models/booking_model.dart';
import 'package:mihnati2/common/widgets/section_header.dart';
import 'package:mihnati2/common/widgets/custom_bottom_nav.dart';
import 'package:mihnati2/screens/client/screens/bookings_list_screen.dart';
import 'package:mihnati2/screens/client/screens/professional_details_screen.dart';
import 'package:mihnati2/screens/client/widgets/service_card.dart';
import 'package:mihnati2/screens/client/widgets/professional_card.dart';
import 'package:mihnati2/screens/profile_screen.dart';
import 'package:mihnati2/screens/service_details_screen.dart';
import 'package:mihnati2/screens/booking_screen.dart';
import 'package:mihnati2/screens/client/screens/client_home_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  int _currentIndex = 0;
  int _bookingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadBookingCount();
  }

  Future<void> _loadBookingCount() async {
    if (currentUser == null) return;
    
    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('bookings')
        .get();

    setState(() => _bookingCount = snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('مهنتي - للعملاء',
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
              if (_bookingCount > 0)
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
                      '$_bookingCount',
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
            onPressed: () => Get.to(const ProfileScreen()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // البحث
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن خدمة أو مهني...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () => _showFilterDialog(),
                    ),
                  ),
                  onChanged: (value) {
                    // البحث في الوقت الحقيقي
                  },
                ),
              ),
            ),

            // بطاقة بالمستخدم
            _buildWelcomeCard(),

            // الخدمات المتاحة
            SectionHeader(
              title: 'الخدمات المتاحة',
              onSeeAll: () => Get.toNamed('/services'),
            ),
            _buildServicesSection(),

            //  المهنيين
            SectionHeader(
              title: 'المهنيين',
              onSeeAll: () => Get.toNamed('/professionals'),
            ),
            _buildProfessionals(),

            // خدمات
            SectionHeader(title: 'خدمات'),
            _buildServices(),

            const SizedBox(height: 30),
          ],
        ),
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
            icon: Icon(Icons.search),
            label: 'بحث',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'حجوزات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف',
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1F3440), Color(0xFF3A7D8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white24,
              backgroundImage: currentUser?.photoURL != null
                  ? NetworkImage(currentUser!.photoURL!)
                  : null,
              child: currentUser?.photoURL == null
                  ? const Icon(Icons.person, color: Colors.white, size: 30)
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً بك، ${currentUser?.displayName ?? "عزيزي العميل"}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'كيف يمكننا مساعدتك اليوم؟',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    return SizedBox(
      height: 165,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('services').limit(8).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ في تحميل الخدمات'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data!.docs
              .map((doc) => ServiceModel.fromFirestore(doc))
              .toList();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return ServiceCard(
                service: services[index],
                onTap: () =>
                    Get.to(ServiceDetailsScreen(service: services[index])),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfessionals() {
    return SizedBox(
      height: 220,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('type', isEqualTo: 'professional')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            FirebaseException? firebaseError;
            String errorMessage = 'حدث خطأ في تحميل المهنيين';

            if (snapshot.error is FirebaseException) {
              firebaseError = snapshot.error as FirebaseException;
              if (firebaseError.code == 'permission-denied') {
                errorMessage = 'لا تملك الصلاحيات اللازمة لرؤية المهنيين';
              }
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  Text(errorMessage),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('لا يوجد مهنيون في الوقت الحالي'),
            );
          }
          final professionals = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ProfessionalModel(
              id: doc.id,
              name: data['fullName'] ?? 'غير معروف',
              profession:
                  (data['services'] != null && data['services'].isNotEmpty)
                      ? data['services'][0]
                      : 'مهني',
              rating: (data['rating'] ?? 0.0).toDouble(),
              completedJobs: data['reviewCount'] ?? 0,
              imageUrl: data['photoURL'] ?? '',
              isFeatured: data['isFeatured'] ?? false,
            );
          }).toList();
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: professionals.length,
            itemBuilder: (context, index) {
              return ProfessionalCard(
                professional: professionals[index],
                onBookPressed: () => _bookProfessional(professionals[index]),
                onTap: () => Get.to(
                  ProfessionalDetailsScreen(professional: professionals[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  //  حجز المهني
  void _bookProfessional(ProfessionalModel professional) {
    Get.to(
      BookingScreen(
        professional: professional,
        service: ServiceModel(
          id: "service_${professional.id}",
          name: professional.profession,
          category: professional.profession,
          description: 'خدمة احترافية مقدمة من ${professional.name}',
          price: 0.0,
          rating: professional.rating,
          reviews: professional.completedJobs,
          imagePath: professional.imageUrl,
        ),
      ),
    );
  }

  Widget _buildServices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 3.5,
        children: [
          _buildQuickServiceItem(
            Icons.home_repair_service_rounded,
            'طلب خدمة',
            const Color(0xFF1F3440),
            onTap: () => Get.toNamed('/emergency'),
          ),
          _buildQuickServiceItem(
            Icons.bookmark_add,
            'حجز مهني',
            const Color(0xFF3A7D8A),
            onTap: () => Get.to(BookingsListScreen()),
          ),
          _buildQuickServiceItem(
            Icons.support_agent,
            'الدعم الفني',
            Colors.orange,
            onTap: () => Get.toNamed('/support'),
          ),
          _buildQuickServiceItem(
            Icons.receipt,
            'الفواتير',
            Colors.green,
            onTap: () => Get.toNamed('/invoices'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServiceItem(IconData icon, String title, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 15),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('تصفية النتائج'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildFilterOption('الكهرباء'),
              _buildFilterOption('السباكة'),
              _buildFilterOption('النجارة'),
              _buildFilterOption('البناء'),
              _buildFilterOption('الدهان'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('تطبيق التصفية'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title) {
    return CheckboxListTile(
      title: Text(title),
      value: false,
      onChanged: (value) {},
    );
  }
}