import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/common/models/service_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';
import 'package:provider/provider.dart';

class AddServiceScreen extends StatefulWidget {
  final ServiceModel? service;

  const AddServiceScreen({super.key, this.service});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _categoryController =
        TextEditingController(text: widget.service?.category ?? '');
    _descriptionController =
        TextEditingController(text: widget.service?.description ?? '');
    _priceController =
        TextEditingController(text: widget.service?.price.toString() ?? '');
    _imageFile = null;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final c = AppColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.service == null ? 'إضافة خدمة' : 'تعديل خدمة',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 50,
                                color: isDark
                                    ? AppColors.darkIcon
                                    : AppColors.lightIcon),
                            Text('إضافة صورة',
                                style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkText
                                        : AppColors.lightText)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                style: TextStyle(
                    color: isDark ? AppColors.darkText : AppColors.lightText),
                decoration: InputDecoration(
                  labelText: 'اسم الخدمة',
                  labelStyle: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.lightText),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم الخدمة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _categoryController,
                style: TextStyle(
                    color: isDark ? AppColors.darkText : AppColors.lightText),
                decoration: InputDecoration(
                  labelText: 'التصنيف',
                  labelStyle: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.lightText),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال التصنيف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _priceController,
                style: TextStyle(
                    color: isDark ? AppColors.darkText : AppColors.lightText),
                decoration: InputDecoration(
                  labelText: 'السعر (ر.س)',
                  labelStyle: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.lightText),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال السعر';
                  }
                  if (double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                style: TextStyle(
                    color: isDark ? AppColors.darkText : AppColors.lightText),
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  labelStyle: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.lightText),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                  ),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الوصف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    widget.service == null ? 'إضافة الخدمة' : 'حفظ التعديلات',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveService() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        Get.snackbar('خطأ', 'يجب تسجيل الدخول أولاً');
        return;
      }

      try {
        String imagePath = _imageFile?.path ?? '';
        final serviceData = {
          'name': _nameController.text,
          'category': _categoryController.text,
          'description': _descriptionController.text,
          'price': double.parse(_priceController.text),
          'imagePath': imagePath,
          'professionalId': currentUser.uid,
          'createdAt': FieldValue.serverTimestamp(),
        };

        if (widget.service == null) {
          // إضافة خدمة جديدة
          await _firestore.collection('services').add(serviceData);
        } else {
          // تحديث الخدمة الحالية
          await _firestore
              .collection('services')
              .doc(widget.service!.id)
              .update(serviceData);
        }

        Get.back();
        Get.snackbar(
          'تم الحفظ',
          widget.service == null
              ? 'تمت إضافة الخدمة بنجاح'
              : 'تم تحديث الخدمة بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'خطأ',
          'حدث خطأ أثناء الحفظ: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
