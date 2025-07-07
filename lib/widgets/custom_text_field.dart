import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Components/theme/theme_provider.dart';
import '../Components/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon; // أضفنا هذه الخاصية

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon, // أضفنا هذه الخاصية في الكونستركتور
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final fillColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.lightIcon;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          filled: true,
          fillColor: fillColor,
          prefixIcon: Icon(prefixIcon ?? Icons.person, color: iconColor),
          suffixIcon: suffixIcon, // تم التعديل هنا
          hintText: hintText,
          hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
