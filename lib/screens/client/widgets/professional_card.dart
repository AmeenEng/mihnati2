import 'package:flutter/material.dart';
import 'package:mihnati2/common/models/professional_model.dart';
import 'package:provider/provider.dart';
import 'package:mihnati2/Components/theme/theme_provider.dart';
import 'package:mihnati2/Components/theme/app_colors.dart';

class ProfessionalCard extends StatelessWidget {
  final ProfessionalModel professional;
  final VoidCallback onBookPressed;
  final VoidCallback? onTap;

  const ProfessionalCard({
    super.key,
    required this.professional,
    required this.onBookPressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.lightIcon;
    final Except = isDark ? AppColors.primaryColor : AppColors.primaryColor;
    final backgroundColor =
        isDark ? AppColors.secondaryColor : AppColors.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: professional.imageUrl.isNotEmpty
                      ? Image.network(
                          professional.imageUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 100,
                          color: backgroundColor,
                          child: Center(
                            child:
                                Icon(Icons.person, size: 40, color: iconColor),
                          ),
                        ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professional.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    professional.profession,
                    style: TextStyle(
                      fontSize: 12,
                      color: Except,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            professional.rating.toStringAsFixed(1),
                            style: TextStyle(fontSize: 12, color: textColor),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.bookmark_add, size: 18, color: Except),
                        onPressed: onBookPressed,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
