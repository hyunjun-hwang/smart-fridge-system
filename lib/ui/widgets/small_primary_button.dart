import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';

class SmallPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;

  const SmallPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.height = 50.0, // 일반적인 입력 필드 높이와 유사하게 설정
    this.fontSize = 14.0, // 작은 버튼에 어울리는 폰트 크기
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent, // PrimaryButton 스타일
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        child: Text(text),
      ),
    );
  }
}