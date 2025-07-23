import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/ui/pages/auth/FindAuthInfoPage.dart';
import 'package:smart_fridge_system/ui/widgets/primary_button.dart';
import 'package:smart_fridge_system/ui/widgets/custom_text_field.dart';
import 'package:smart_fridge_system/ui/pages/auth/signup_page.dart';
import 'package:smart_fridge_system/ui/pages/home/mainpage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. 로고 이미지
                SizedBox(
                  height: 100,
                  child: Image.asset('assets/images/logo.png'),
                ),
                const SizedBox(height: 60),

                // 2. 타이틀 텍스트
                const Text(
                  '로그인',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 30),

                // 3. 아이디/비밀번호 입력 필드
                const CustomTextField(
                  hintText: '아이디',
                ),
                const SizedBox(height: 15),
                const CustomTextField(
                  hintText: '비밀번호',
                  obscureText: true,
                ),
                const SizedBox(height: 180),

                // 4. 로그인/회원가입 버튼
                PrimaryButton(
                  text: '로그인',
                  onPressed: () { Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainScreen()),
                      );
                      },
                ),
                const SizedBox(height: 13),
                PrimaryButton(
                  text: '회원가입 하기',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 5. 아이디/비밀번호 찾기 버튼
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FindAuthInfoPage()),
                    );
                  },
                  child: const Text(
                    '아이디/비밀번호 찾기',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}