import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final String image;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: const BorderSide(color: Color(0xFF1F3440)),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFF1F3440),
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF1F3440),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image.asset(image, height: 24, width: 24),
                ],
              ),
      ),
    );
  }
}
