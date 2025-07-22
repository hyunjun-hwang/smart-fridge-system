import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.9, // 화면 너비의 80%
      height: 40, // 고정 높이
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(23.0),
            borderSide: const BorderSide(
              color: AppColors.textSecondary,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(23.0),
            borderSide: const BorderSide(
              color: AppColors.textSecondary,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(23.0),
            borderSide: const BorderSide(
              color: AppColors.textSecondary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
