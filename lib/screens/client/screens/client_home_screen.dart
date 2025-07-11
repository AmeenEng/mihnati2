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
import 'package:mihnati2/screens/about_screen.dart';
import 'package:mihnati2/screens/client/screens/bookings_list_screen.dart';
import 'package:mihnati2/screens/client/screens/professional_details_screen.dart';
import 'package:mihnati2/screens/client/widgets/service_card.dart';
import 'package:mihnati2/screens/client/widgets/professional_card.dart';
import 'package:mihnati2/screens/help_support_screen.dart';
import 'package:mihnati2/screens/profile_screen.dart';
import 'package:mihnati2/screens/service_details_screen.dart';
import 'package:mihnati2/screens/booking_screen.dart';
import 'package:mihnati2/screens/client/screens/client_home_screen.dart';
import 'package:mihnati2/screens/client/screens/client_edit_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

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

  // متغيرات البحث والتصفية
  String _searchQuery = '';
  List<ServiceModel> _allServices = [];
  List<ServiceModel> _filteredServices = [];
  List<ProfessionalModel> _allProfessionals = [];
  List<ProfessionalModel> _filteredProfessionals = [];
  List<String> _selectedFilters = [];
  List<String> _availableCategories = [
    'كهرباء',
    'سباكة',
    'نجارة',
    'بناء',
    'دهان'
  ];

  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _location = '';
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadBookingCount();
    _loadServices();
    _loadProfessionals();
    _loadClientProfile();
  }

  Future<void> _loadBookingCount() async {
    if (currentUser == null) return;

    final snapshot = await _firestore
        .collection('bookings')
        .where('clientId', isEqualTo: currentUser!.uid)
        .get();

    setState(() => _bookingCount = snapshot.docs.length);
  }

  Future<void> _loadServices() async {
    final snapshot = await _firestore.collection('services').get();
    final allServices =
        snapshot.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList();

    setState(() {
      _allServices = allServices;
      _filteredServices = allServices;
    });
  }

  Future<void> _loadProfessionals() async {
    final snapshot = await _firestore
        .collection('users')
        .where('type', isEqualTo: 'professional')
        .get();

    final allProfessionals = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ProfessionalModel(
        id: doc.id,
        name: data['fullName'] ?? 'غير معروف',
        profession: (data['services'] != null && data['services'].isNotEmpty)
            ? data['services'][0]
            : 'مهني',
        rating: (data['rating'] ?? 0.0).toDouble(),
        completedJobs: data['reviewCount'] ?? 0,
        imageUrl: data['photoURL'] ?? '',
        isFeatured: data['isFeatured'] ?? false,
      );
    }).toList();

    setState(() {
      _allProfessionals = allProfessionals;
      _filteredProfessionals = allProfessionals;
    });
  }

  Future<void> _loadClientProfile() async {
    if (currentUser == null) return;
    try {
      final userDoc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      final data = userDoc.data() ?? {};
      setState(() {
        _fullName = data['fullName'] ?? currentUser!.displayName ?? '';
        _email = data['email'] ?? currentUser!.email ?? '';
        _phone = data['phone'] ?? '';
        _location = data['location'] ?? '';
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() => _isLoadingProfile = false);
      Get.snackbar('خطأ', 'حدث خطأ في تحميل بيانات العميل: $e');
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

  void _filterServices() {
    setState(() {
      _filteredServices = _allServices.where((service) {
        // تطبيق البحث
        final matchesSearch = _searchQuery.isEmpty ||
            service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            service.category.toLowerCase().contains(_searchQuery.toLowerCase());

        // تطبيق التصفية
        final matchesCategory = _selectedFilters.isEmpty ||
            _selectedFilters.contains(service.category);

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _filterProfessionals() {
    setState(() {
      _filteredProfessionals = _allProfessionals.where((pro) {
        // تطبيق البحث
        final matchesSearch = _searchQuery.isEmpty ||
            pro.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            pro.profession.toLowerCase().contains(_searchQuery.toLowerCase());

        // تطبيق التصفية
        final matchesCategory = _selectedFilters.isEmpty ||
            _selectedFilters.contains(pro.profession);

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _updateFilters() {
    _filterServices();
    _filterProfessionals();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _selectedFilters.clear();
      _filteredServices = _allServices;
      _filteredProfessionals = _allProfessionals;
    });
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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('مهنتي - للعملاء',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          // زر تبديل الثيم
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: iconColor,
            ),
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
            icon: Icon(Icons.person_outline, color: iconColor),
            onPressed: () => Get.to(const ProfileScreen()),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                currentUser?.displayName ?? "مستخدم مهنتي",
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              accountEmail: Text(
                currentUser?.email ?? "user@mihnati.com",
                style: TextStyle(fontSize: 14, color: textColor),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: backgroundColor,
                backgroundImage: currentUser?.photoURL != null
                    ? NetworkImage(currentUser!.photoURL!)
                    : null,
                child: currentUser?.photoURL == null
                    ? Icon(Icons.person, size: 50, color: iconColor)
                    : null,
              ),
              decoration: BoxDecoration(
                color: primaryColor,
              ),
            ),

            // Navigation Items
            _buildDrawerItem(
              icon: Icons.home,
              title: 'الرئيسية',
              onTap: () {
                Navigator.pop(context); // Close drawer
                Get.offAll(const ClientHomeScreen());
              },
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'الملف الشخصي',
              onTap: () {
                Navigator.pop(context);
                Get.to(const ProfileScreen());
              },
            ),
            _buildDrawerItem(
              icon: Icons.bookmark,
              title: 'الحجوزات',
              badgeCount: _bookingCount,
              onTap: () {
                Navigator.pop(context);
                Get.to(const BookingsListScreen());
              },
            ),
            _buildDrawerItem(
              icon: Icons.favorite,
              title: 'المفضلة',
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/favorites');
              },
            ),
            _buildDrawerItem(
              icon: Icons.history,
              title: 'سجل الخدمات',
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/history');
              },
            ),
            _buildDrawerItem(
              icon: Icons.credit_card,
              title: 'طرق الدفع',
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/payment-methods');
              },
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'الإعدادات',
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/settings');
              },
            ),
            _buildDrawerItem(
              icon: Icons.help,
              title: 'المساعدة والدعم',
              onTap: () {
                Navigator.pop(context);
                Get.to(HelpSupportScreen());
              },
            ),
            _buildDrawerItem(
              icon: Icons.info,
              title: 'عن التطبيق',
              onTap: () {
                Navigator.pop(context);
                Get.to(AboutScreen());
              },
            ),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('تسجيل الخروج',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Get.offAllNamed('/login');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // البحث والتصفية
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'ابحث عن خدمة أو مهني...',
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 15),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _searchController.clear();
                                      _updateFilters();
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          _updateFilters();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () => _showFilterDialog(),
                    ),
                  ],
                ),
              ),
            ),

            // بطاقة بالمستخدم
            _buildClientProfileCard(
                cardColor, textColor, iconColor, primaryColor),

            // فلتر نشط
            if (_selectedFilters.isNotEmpty || _searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Chip(
                      label: Text(
                        'فلتر نشط',
                        style: TextStyle(color: primaryColor),
                      ),
                      backgroundColor: primaryColor.withOpacity(0.2),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (_searchQuery.isNotEmpty)
                              Chip(
                                label: Text('بحث: $_searchQuery'),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _searchController.clear();
                                    _updateFilters();
                                  });
                                },
                              ),
                            ..._selectedFilters.map((filter) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Chip(
                                  label: Text(filter),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedFilters.remove(filter);
                                      _updateFilters();
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('مسح الكل'),
                    ),
                  ],
                ),
              ),

            // الخدمات المتاحة
            SectionHeader(
              title: 'الخدمات المتاحة',
              onSeeAll: () => Get.toNamed('/services'),
              textColor: textColor,
            ),
            _buildServicesSection(),

            // المهنيين
            SectionHeader(
              title: 'المهنيين',
              onSeeAll: () => Get.toNamed('/professionals'),
              textColor: textColor,
            ),
            _buildProfessionals(),

            // خدمات سريعة
            SectionHeader(
              title: 'خدمات سريعة',
              textColor: textColor,
            ),
            _buildServices(),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            Get.to(() => const BookingsListScreen());
          } else {
            setState(() => _currentIndex = index);
          }
        },
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
        backgroundColor: Colors.white,
        textColor: Colors.black,
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.lightIcon : AppColors.darkIcon;
    final avtar = isDark ? AppColors.lightBackground : AppColors.darkBackground;
    final background =
        isDark ? AppColors.secondaryColor : AppColors.primaryColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: avtar,
              backgroundImage: currentUser?.photoURL != null
                  ? NetworkImage(currentUser!.photoURL!)
                  : null,
              child: currentUser?.photoURL == null
                  ? Icon(Icons.person, color: iconColor, size: 30)
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً بك، ${currentUser?.displayName ?? "عزيزي العميل"}',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'كيف يمكننا مساعدتك اليوم؟',
                    style: TextStyle(
                      color: textColor,
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

  Widget _buildClientProfileCard(
      Color cardColor, Color textColor, Color iconColor, Color primaryColor) {
    if (_isLoadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: cardColor,
                  backgroundImage: currentUser?.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : null,
                  child: currentUser?.photoURL == null
                      ? Icon(Icons.person, color: iconColor, size: 40)
                      : null,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_fullName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: textColor)),
                      const SizedBox(height: 4),
                      Text(_email,
                          style: TextStyle(
                              color: textColor.withOpacity(0.7), fontSize: 14)),
                      if (_phone.isNotEmpty)
                        Text(_phone,
                            style: TextStyle(
                                color: textColor.withOpacity(0.7),
                                fontSize: 14)),
                      if (_location.isNotEmpty)
                        Text(_location,
                            style: TextStyle(
                                color: textColor.withOpacity(0.7),
                                fontSize: 14)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: primaryColor),
                  tooltip: 'تعديل الملف',
                  onPressed: () async {
                    await Get.to(() => const ClientEditProfileScreen());
                    _loadClientProfile();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.bookmark, color: iconColor),
                const SizedBox(width: 8),
                Text('عدد الحجوزات: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: textColor)),
                Text('$_bookingCount', style: TextStyle(color: textColor)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                  label: const Text('تسجيل الخروج',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    if (_filteredServices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: Text('لا توجد خدمات متاحة تطابق بحثك'),
        ),
      );
    }

    return SizedBox(
      height: 165,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: _filteredServices.length,
        itemBuilder: (context, index) {
          return ServiceCard(
            service: _filteredServices[index],
            onTap: () =>
                Get.to(ServiceDetailsScreen(service: _filteredServices[index])),
          );
        },
      ),
    );
  }

  Widget _buildProfessionals() {
    if (_filteredProfessionals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: Text('لا يوجد مهنيون متاحون يطابقون بحثك'),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredProfessionals.length,
        itemBuilder: (context, index) {
          return ProfessionalCard(
            professional: _filteredProfessionals[index],
            onBookPressed: () =>
                _bookProfessional(_filteredProfessionals[index]),
            onTap: () => Get.to(
              ProfessionalDetailsScreen(
                  professional: _filteredProfessionals[index]),
            ),
          );
        },
      ),
    );
  }

  // حجز المهني
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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.lightIcon;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

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
            context,
            Icons.home_repair_service_rounded,
            'طلب خدمة',
            cardColor,
            iconColor,
            textColor,
            onTap: () => Get.toNamed('/emergency'),
          ),
          _buildQuickServiceItem(
            context,
            Icons.bookmark_add,
            'حجز مهني',
            AppColors.primaryColor,
            Colors.white,
            Colors.white,
            onTap: () => Get.to(const BookingsListScreen()),
          ),
          _buildQuickServiceItem(
            context,
            Icons.support_agent,
            'الدعم الفني',
            Colors.orange,
            Colors.white,
            Colors.white,
            onTap: () => Get.toNamed('/support'),
          ),
          _buildQuickServiceItem(
            context,
            Icons.receipt_long,
            'الفواتير',
            Colors.green,
            Colors.white,
            Colors.white,
            onTap: () => Get.toNamed('/invoices'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServiceItem(
    BuildContext context,
    IconData icon,
    String title,
    Color backgroundColor,
    Color iconColor,
    Color textColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    List<String> tempFilters = List.from(_selectedFilters);

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('تصفية النتائج'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  ..._availableCategories.map((category) {
                    return CheckboxListTile(
                      title: Text(category),
                      value: tempFilters.contains(category),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            tempFilters.add(category);
                          } else {
                            tempFilters.remove(category);
                          }
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() => tempFilters.clear());
                },
                child: const Text('مسح الكل'),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedFilters = tempFilters;
                  });
                  _updateFilters();
                  Get.back();
                },
                child: const Text('تطبيق التصفية'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final iconColor = isDark ? AppColors.lightIcon : AppColors.darkIcon;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: badgeCount > 0
          ? Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
