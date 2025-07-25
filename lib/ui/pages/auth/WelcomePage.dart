import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/ui/pages/auth/LoginPage.dart';
import 'package:smart_fridge_system/ui/pages/auth/signup_page.dart';
import 'package:smart_fridge_system/ui/widgets/primary_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // 1. 로고 이미지
              SizedBox(
                height: 158,
                width: 124,
                child: Image.asset('assets/images/logo.png'),
              ),

              const SizedBox(height: 24),

              // 2. 타이틀 텍스트
              const Text(
                '나의 냉장고',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const Spacer(flex: 3),

              // 3. 시작하기 & 로그인 버튼 (PrimaryButton 위젯 사용)
              PrimaryButton(
                text: '시작하기',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                text: '이미 계정이 있어요',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}