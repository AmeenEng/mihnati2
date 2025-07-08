import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../routes.dart';
import 'package:provider/provider.dart';
import '../../Components/theme/theme_provider.dart';
import '../../Components/theme/app_colors.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedUserType;
  List<String> _selectedServices = [];
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String? _customService; // خدمة مخصصة

  // قائمة الخدمات المتاحة (للمهنيين)
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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // التأكد من اختيار نوع المستخدم
      if (_selectedUserType == null) {
        Get.snackbar('خطأ', 'يرجى اختيار نوع المستخدم');
        return;
      }

      // إذا كان المستخدم مهنيًا ويجب عليه اختيار خدمة واحدة على الأقل
      if (_selectedUserType == 'professional' && _selectedServices.isEmpty) {
        Get.snackbar('خطأ', 'يرجى اختيار خدمة واحدة على الأقل');
        return;
      }

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // مرجع مستند المستخدم
          final userRef =
              FirebaseFirestore.instance.collection('users').doc(user.uid);

          // البيانات الأساسية
          await userRef.set({
            'fullName': _fullNameController.text,
            'email': user.email,
            'phone': _phoneController.text,
            'type': _selectedUserType,
            'location': _locationController.text,
            'rating': 4.5,
            'reviewCount': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'services':
                _selectedUserType == 'professional' ? _selectedServices : [],
          });

          // إذا كان المستخدم مهنيًا، نقوم بإنشاء الإحصائيات الأولية
          if (_selectedUserType == 'professional') {
            final statsRef = userRef.collection('stats');
            await Future.wait([
              statsRef.doc('earnings').set({'total': 0.0}),
              statsRef.doc('jobs').set({'completed': 0}),
            ]);
          }

          // الانتقال إلى الشاشة الرئيسية
          if (_selectedUserType == 'professional') {
            Get.offAllNamed(AppRoutes.professionalHome);
          } else {
            Get.offAllNamed(AppRoutes.clientHome);
          }
        }
      } catch (e) {
        Get.snackbar('خطأ', 'حدث خطأ أثناء حفظ البيانات: ${e.toString()}');
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
        title: const Text('اكمال الملف الشخصي'),
        centerTitle: true,
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
            color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الملف الشخصي
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: cardColor,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(Icons.person, size: 60, color: iconColor)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Divider(color: cardColor.withOpacity(0.5)),
              const SizedBox(height: 20),

              // حقل الاسم الكامل
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person, color: iconColor),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: cardColor,
                  labelStyle: TextStyle(color: textColor),
                ),
                style: TextStyle(color: textColor),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم الكامل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // حقل الهاتف
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'الهاتف',
                  prefixIcon: Icon(Icons.phone, color: iconColor),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: cardColor,
                  labelStyle: TextStyle(color: textColor),
                ),
                style: TextStyle(color: textColor),
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

              // حقل الموقع
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'المدينة أو المنطقة',
                  prefixIcon: Icon(Icons.location_on, color: iconColor),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: cardColor,
                  labelStyle: TextStyle(color: textColor),
                ),
                style: TextStyle(color: textColor),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المدينة أو المنطقة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // اختيار نوع المستخدم
              DropdownButtonFormField<String>(
                value: _selectedUserType,
                decoration: InputDecoration(
                  labelText: 'نوع المستخدم',
                  prefixIcon: Icon(Icons.group, color: iconColor),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: cardColor,
                  labelStyle: TextStyle(color: textColor),
                ),
                dropdownColor: cardColor,
                items: [
                  DropdownMenuItem(
                    value: 'client',
                    child: Row(
                      children: [
                        Icon(Icons.person, color: primaryColor),
                        const SizedBox(width: 10),
                        Text('عميل', style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'professional',
                    child: Row(
                      children: [
                        Icon(Icons.handyman, color: Colors.green),
                        const SizedBox(width: 10),
                        Text('مهني', style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUserType = newValue;
                    // عند تغيير النوع، نمسح الخدمات المختارة
                    if (newValue != 'professional') {
                      _selectedServices = [];
                    }
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'يرجى اختيار نوع المستخدم';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // إذا كان المستخدم مهنيًا نعرض اختيار الخدمات
              if (_selectedUserType == 'professional')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الخدمات المقدمة',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _availableServices.map((service) {
                        final isSelected = _selectedServices.contains(service);
                        return FilterChip(
                          label: Text(service,
                              style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : textColor)),
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
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    ),
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
                              _selectedServices.remove(_customService);
                              _customService = null;
                            }
                          } else {
                            // إظهار حقل إدخال نصي
                            showDialog(
                              context: context,
                              builder: (context) {
                                final controller = TextEditingController();
                                return AlertDialog(
                                  title: const Text('أدخل اسم الخدمة'),
                                  content: TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                        hintText: 'مثال: أعمال زجاج'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('إلغاء'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        final value = controller.text.trim();
                                        if (value.isNotEmpty) {
                                          setState(() {
                                            _customService = value;
                                            _selectedServices.add(value);
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
                    if (_selectedServices.isEmpty)
                      const Text(
                        'يرجى اختيار خدمة واحدة على الأقل',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'حفظ المعلومات',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
