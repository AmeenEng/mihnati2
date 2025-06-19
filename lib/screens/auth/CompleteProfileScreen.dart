import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../routes.dart';

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
          // تخزين البيانات في Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'fullName': _fullNameController.text,
            'email': user.email,
            'phone': _phoneController.text,
            'type': _selectedUserType,
            'location': _locationController.text,
            'rating': 4.5, // التقييم الابتدائي
            'reviewCount': 0, // عدد التقييمات الابتدائي
            'createdAt': FieldValue.serverTimestamp(),
            'services':
                _selectedUserType == 'professional' ? _selectedServices : [],
            // TODO: رفع صورة الملف الشخصي إذا وجدت والتخزين في Firebase Storage ثم حفظ الرابط
          });

          // الانتقال إلى الشاشة الرئيسية
          Get.offAllNamed(AppRoutes.home);
        }
      } catch (e) {
        Get.snackbar('خطأ', 'حدث خطأ أثناء حفظ البيانات: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اكمال الملف الشخصي'),
        centerTitle: true,
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
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon:
                              const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              // حقل الاسم الكامل
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
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
                decoration: const InputDecoration(
                  labelText: 'الهاتف',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
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
                decoration: const InputDecoration(
                  labelText: 'المدينة أو المنطقة',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
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
                decoration: const InputDecoration(
                  labelText: 'نوع المستخدم',
                  prefixIcon: Icon(Icons.group),
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'client',
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 10),
                        const Text('عميل'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'professional',
                    child: Row(
                      children: [
                        const Icon(Icons.handyman, color: Colors.green),
                        const SizedBox(width: 10),
                        const Text('مهني'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'employer',
                    child: Row(
                      children: [
                        const Icon(Icons.business, color: Colors.orange),
                        const SizedBox(width: 10),
                        const Text('صاحب عمل'),
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
                    const Text(
                      'الخدمات المقدمة',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _availableServices.map((service) {
                        final isSelected = _selectedServices.contains(service);
                        return FilterChip(
                          label: Text(service),
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
                          selectedColor: Colors.green[100],
                          checkmarkColor: Colors.green,
                        );
                      }).toList(),
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
                    backgroundColor: const Color(0xFF1F3440),
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
