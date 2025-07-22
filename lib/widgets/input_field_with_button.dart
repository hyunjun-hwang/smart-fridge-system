import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';

class InputFieldWithButton extends StatelessWidget {
  final String hintText;
  final String buttonText;
  final Color borderColor;
  final VoidCallback onButtonPressed;

  const InputFieldWithButton({
    super.key,
    required this.hintText,
    required this.buttonText,
    required this.borderColor,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    // SizedBox로 감싸 높이와 너비를 지정합니다.
    return SizedBox(
      height: 40, // 1. 높이를 40으로 고정
      child: TextFormField(
        decoration: InputDecoration(
          isDense: true,
          // 2. 높이를 줄이기 위해 isDense 속성 추가
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          // 3. 내용이 잘리지 않도록 수직(vertical) 패딩 조정
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          suffixIcon: ElevatedButton(
            onPressed: onButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textSecondary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 0,
            ),
            child: Text(buttonText),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: borderColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: borderColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}