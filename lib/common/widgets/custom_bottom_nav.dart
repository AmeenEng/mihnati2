import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;
  final Color backgroundColor;
  final Color textColor;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: textColor,
      unselectedItemColor: textColor.withOpacity(0.6),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: items,
      backgroundColor: backgroundColor,
    );
  }
}
