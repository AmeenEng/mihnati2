import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mihnati2/common/models/professional_model.dart';
import 'package:mihnati2/common/models/service_model.dart';

class BookingScreen extends StatefulWidget {
  final ProfessionalModel professional;
  final ServiceModel service;

  const BookingScreen({
    super.key,
    required this.professional,
    required this.service,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        Get.snackbar('خطأ', 'الرجاء اختيار التاريخ والوقت');
        return;
      }

      setState(() => _isLoading = true);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('خطأ', 'يجب تسجيل الدخول أولاً');
        setState(() => _isLoading = false);
        return;
      }

      try {
        // جلب بيانات العميل من Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          Get.snackbar('خطأ', 'لم يتم العثور على بيانات المستخدم');
          setState(() => _isLoading = false);
          return;
        }

        final userData = userDoc.data() as Map<String, dynamic>;
        final clientPhone = userData['phone'] ?? '';
        final clientName = userData['fullName'] ?? user.displayName ?? 'عميل';

        final bookingData = {
          'clientId': user.uid,
          'professionalId': widget.professional.id,
          'serviceId': widget.service.id,
          'clientName': clientName,
          'professionalName': widget.professional.name,
          'serviceName': widget.service.name,
          'serviceCategory': widget.service.category,
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
          'time': _selectedTime!.format(context),
          'address': _addressController.text,
          'notes': _notesController.text,
          'status': 'معلقة',
          'price': widget.service.price,
          'clientPhone': clientPhone,
          'createdAt': FieldValue.serverTimestamp(),
        };

        // إضافة الحجز
        await FirebaseFirestore.instance
            .collection('bookings')
            .add(bookingData);

        Get.back(); // إغلاق شاشة الحجز
        Get.snackbar('تم', 'تم الحجز بنجاح',
            backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        Get.snackbar('خطأ', 'حدث خطأ أثناء الحجز: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز خدمة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: const Text('المهني'),
                subtitle: Text(widget.professional.name),
              ),
              ListTile(
                title: const Text('الخدمة'),
                subtitle: Text(widget.service.name),
              ),
              ListTile(
                title: const Text('التصنيف'),
                subtitle: Text(widget.service.category),
              ),
              ListTile(
                title: const Text('السعر'),
                subtitle:
                    Text('${widget.service.price.toStringAsFixed(2)} ر.س'),
              ),
              ListTile(
                title: const Text('التاريخ'),
                subtitle: Text(
                  _selectedDate == null
                      ? 'اختر التاريخ'
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: const Text('الوقت'),
                subtitle: Text(
                  _selectedTime == null
                      ? 'اختر الوقت'
                      : _selectedTime!.format(context),
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال العنوان';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات إضافية (اختياري)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F3440),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'تأكيد الحجز',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
