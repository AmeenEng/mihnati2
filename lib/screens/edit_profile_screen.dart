import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../Components/theme/app_colors.dart';
import '../Components/theme/theme_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  File? _profileImage;
  String? _profileImageUrl;
  bool _isLoading = false;
  String? _selectedUserType;
  List<String> _selectedServices = [];
  String? _customService; // خدمة مخصصة

  final List<String> _availableServices = [
    'كهرباء',
    'سباكة',
    'نجارة',
    'بناء',
    'دهان',
    'تركيب سيراميك',
    'حدادة',
    'تنسيق حدائق',
    'نقل أثاث',
    'تنظيف',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _fullNameController.text = data['fullName'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _locationController.text = data['location'] ?? '';
        _selectedUserType = data['type'] ?? 'client';
        _profileImageUrl = data['profileImageUrl'] ?? '';

        if (data['services'] != null) {
          _selectedServices = List<String>.from(data['services']);
        }
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء تحميل البيانات',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      // طلب الإذن بشكل صحيح
      PermissionStatus status;

      if (kIsWeb || Platform.isIOS) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1200,
          maxHeight: 1200,
        );

        if (pickedFile != null) {
          final file = File(pickedFile.path);
          final compressedFile = await _compressImage(file);
          setState(() {
            _profileImage = compressedFile;
          });
        }
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      } else {
        Get.snackbar('خطأ', 'تم رفض الإذن بالوصول إلى المعرض',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print('🚨 خطأ داخل _pickImage: $e');
      debugPrint('خطأ في اختيار الصورة: $e');
      Get.snackbar('خطأ', 'تعذر اختيار الصورة: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<File> _compressImage(File file) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.absolute.path}_compressed.jpg',
        quality: 70,
        minWidth: 800,
        minHeight: 800,
      );

      if (result != null) {
        return File(result.path);
      } else {
        debugPrint('⚠️ الضغط أعاد null، استخدام الأصل');
        return file;
      }
    } catch (e) {
      debugPrint('خطأ في ضغط الصورة: $e');
      return file;
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // إنشاء مرجع فريد للصورة
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}_$timestamp.jpg');

      // التحقق من وجود الصورة
      debugPrint('📸 مسار الصورة: ${image.path}');
      debugPrint('🧾 الصورة موجودة؟ ${image.existsSync()}');
      debugPrint('📦 حجم الصورة: ${image.lengthSync()} بايت');

      // رفع الصورة مع إدارة تقدم الرفع
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': user.uid},
      );

      // الإصلاح: استخدام مهمة واحدة فقط
      final uploadTask = ref.putFile(image, metadata);
      final snapshot = await uploadTask; // انتظر انتهاء الرفع

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await ref.getDownloadURL();
        debugPrint('✅ تم الرفع بنجاح: $downloadUrl');
        return downloadUrl;
      } else {
        throw 'فشل الرفع: ${snapshot.state}';
      }
    } on FirebaseException catch (e) {
      debugPrint('🔥 خطأ Firebase: ${e.code} - ${e.message}');

      String errorMessage = 'حدث خطأ غير متوقع';
      if (e.code == 'object-not-found') {
        errorMessage = 'المسار غير موجود. تأكد من صحة مرجع التخزين';
      } else if (e.code == 'unauthorized') {
        errorMessage = 'ليست لديك صلاحية للوصول إلى هذا المورد';
      } else if (e.code == 'canceled') {
        errorMessage = 'تم إلغاء العملية';
      } else if (e.code == 'quota-exceeded') {
        errorMessage = 'تم تجاوز سعة التخزين المسموح بها';
      }

      Get.snackbar('خطأ', 'فشل رفع الصورة: $errorMessage',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return null;
    } catch (e) {
      debugPrint('❌ خطأ غير متوقع: $e');
      Get.snackbar('خطأ', 'حدث خطأ غير متوقع: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      try {
        String? newImageUrl = _profileImageUrl;

        if (_profileImage != null) {
          newImageUrl = await _uploadImage(_profileImage!);
          if (newImageUrl == null) {
            Get.snackbar('تحذير', 'تم حفظ البيانات بدون تحديث الصورة',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white);
          }
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fullName': _fullNameController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
          'profileImageUrl': newImageUrl ?? _profileImageUrl,
          'services': _selectedServices,
        });

        Get.back();
        Get.snackbar('نجاح', 'تم تحديث الملف الشخصي بنجاح',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } catch (e) {
        Get.snackbar('خطأ', 'حدث خطأ أثناء حفظ البيانات: ${e.toString()}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      } finally {
        setState(() => _isLoading = false);
      }
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
    final primaryColor = AppColors.primaryColor;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: cardColor,
        iconTheme: IconThemeData(color: iconColor),
        titleTextStyle: TextStyle(
            color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: primaryColor),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // صورة البروفايل
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: _profileImage != null
                              ? ClipOval(
                                  child: Image.file(
                                    _profileImage!,
                                    fit: BoxFit.cover,
                                    width: 150,
                                    height: 150,
                                  ),
                                )
                              : (_profileImageUrl?.isNotEmpty ?? false)
                                  ? ClipOval(
                                      child: Image.network(
                                        _profileImageUrl!,
                                        fit: BoxFit.cover,
                                        width: 150,
                                        height: 150,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.person,
                                              size: 60, color: Colors.grey),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey,
                                      ),
                                      child: const Icon(Icons.person,
                                          size: 60, color: Colors.white),
                                    ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1F3440),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 24),
                            onPressed: _pickImage,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // حقول المعلومات
                    _buildInfoField(
                      controller: _fullNameController,
                      label: 'الاسم الكامل',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال الاسم الكامل';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildInfoField(
                      controller: _phoneController,
                      label: 'رقم الهاتف',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال رقم الهاتف';
                        } else if (value.length != 9) {
                          return 'رقم الهاتف يجب أن يتكون من 9 أرقام';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildInfoField(
                      controller: _locationController,
                      label: 'المدينة أو المنطقة',
                      icon: Icons.location_on,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال المدينة أو المنطقة';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    // الخدمات للمهنيين
                    if (_selectedUserType == 'professional')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الخدمات المقدمة:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ..._availableServices.map((service) {
                                final isSelected =
                                    _selectedServices.contains(service);
                                return ChoiceChip(
                                  label: Text(service,
                                      style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : textColor)),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedServices.add(service);
                                      } else {
                                        _selectedServices.remove(service);
                                      }
                                    });
                                  },
                                  selectedColor: primaryColor,
                                  backgroundColor: cardColor,
                                  labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : textColor),
                                );
                              }).toList(),
                              // زر أخرى
                              FilterChip(
                                label: Text('أخرى',
                                    style: TextStyle(
                                        color: _customService != null
                                            ? Colors.white
                                            : textColor)),
                                selected: _customService != null,
                                onSelected: (selected) {
                                  setState(() {
                                    if (!selected) {
                                      if (_customService != null) {
                                        _selectedServices
                                            .remove(_customService);
                                        _customService = null;
                                      }
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          final controller =
                                              TextEditingController();
                                          return AlertDialog(
                                            title:
                                                const Text('أدخل اسم الخدمة'),
                                            content: TextField(
                                              controller: controller,
                                              decoration: const InputDecoration(
                                                  hintText: 'مثال: أعمال زجاج'),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('إلغاء'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  final value =
                                                      controller.text.trim();
                                                  if (value.isNotEmpty) {
                                                    setState(() {
                                                      _customService = value;
                                                      _selectedServices
                                                          .add(value);
                                                    });
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: const Text('إضافة'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  });
                                },
                                selectedColor: primaryColor,
                                backgroundColor: cardColor,
                                checkmarkColor: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                    // زر الحفظ
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3440),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'حفظ التعديلات',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    required String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1F3440)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1F3440), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          filled: true,
          fillColor: Colors.grey[50],
          labelStyle: const TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
