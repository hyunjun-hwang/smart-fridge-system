import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/widgets/custom_text_field.dart';
import 'package:smart_fridge_system/widgets/input_field_with_button.dart';
import 'package:smart_fridge_system/widgets/primary_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // 성별 선택 버튼의 상태를 관리하는 변수 (남, 여)
  // 이미지처럼 '여'가 기본 선택되도록 설정
  final List<bool> _genderSelection = [false, true];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // 뒤로가기 버튼만 있는 깔끔한 앱바
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
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
                  child: Image.asset('assets/images/logo.png'), // 로고 경로
                ),
                const SizedBox(height: 30),

                // 2. 타이틀 텍스트
                const Text(
                  '회원가입',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 40),

                // 3. 입력 필드들
                const CustomTextField(hintText: '아이디'),
                const SizedBox(height: 15),
                const CustomTextField(hintText: '이메일'),
                const SizedBox(height: 15),
                InputFieldWithButton(
                  hintText: '인증번호',
                  buttonText: '확인',
                  borderColor: AppColors.textSecondary,
                  onButtonPressed: () {
                    // 인증번호 확인 로직
                  },
                ),
                const SizedBox(height: 15),
                const CustomTextField(
                  hintText: '비밀번호',
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                const CustomTextField(
                  hintText: '비밀번호 확인',
                  obscureText: true,
                ),
                const SizedBox(height: 15),

                // 4. 생년월일 및 성별 선택
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 생년월일 필드 (전체 너비의 약 60% 차지)
                    SizedBox(
                      width: screenWidth * 0.8 * 0.6,
                      child: const CustomTextField(hintText: '생년월일'),
                    ),
                    const Spacer(),
                    // 성별 선택 버튼
                    ToggleButtons(
                      isSelected: _genderSelection,
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < _genderSelection.length; i++) {
                            _genderSelection[i] = i == index;
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(30.0),
                      selectedColor: Colors.white,
                      color: AppColors.textSecondary,
                      fillColor: AppColors.textSecondary,
                      splashColor: AppColors.primary.withOpacity(0.12),
                      constraints: const BoxConstraints(
                        minHeight: 40.0,
                        minWidth: 50.0,
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('남'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('여'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                // 5. 회원가입 버튼
                PrimaryButton(
                  text: '회원가입 하기',
                  onPressed: () {
                    // 회원가입 로직
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}