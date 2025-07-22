import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/widgets/input_field_with_button.dart'; // 새로 만든 위젯 import

class FindAuthInfoPage extends StatelessWidget {
  const FindAuthInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 공통으로 사용할 스타일 정의
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: const BorderSide(color: AppColors.textSecondary, width: 1.5),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    height: 100,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '아이디 찾기',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 15),
                // InputFieldWithButton 위젯 사용
                InputFieldWithButton(
                  hintText: '이메일',
                  buttonText: '입력',
                  borderColor: AppColors.textSecondary,
                  onButtonPressed: () {
                    print('아이디 찾기 - 이메일 입력 버튼 클릭');
                    // TODO: 이메일 전송 로직 구현
                  },
                ),
                const SizedBox(height: 15),
                // InputFieldWithButton 위젯 사용
                InputFieldWithButton(
                  hintText: '인증번호',
                  buttonText: '확인',
                  borderColor: AppColors.textSecondary,
                  onButtonPressed: () {
                    print('아이디 찾기 - 인증번호 확인 버튼 클릭');
                    // TODO: 인증번호 확인 로직 구현
                  },
                ),
                const SizedBox(height:11),
                _buildTimerRow(),
                const SizedBox(height: 60),
                const Text(
                  '비밀번호 찾기',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: '아이디 입력',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    focusedBorder: inputBorder,
                  ),
                ),
                const SizedBox(height: 15),
                // InputFieldWithButton 위젯 사용
                InputFieldWithButton(
                  hintText: '이메일',
                  buttonText: '입력',
                  borderColor: AppColors.textSecondary,
                  onButtonPressed: () {
                    print('비밀번호 찾기 - 이메일 입력 버튼 클릭');
                    // TODO: 이메일 전송 로직 구현
                  },
                ),
                const SizedBox(height: 15),
                // InputFieldWithButton 위젯 사용
                InputFieldWithButton(
                  hintText: '인증번호',
                  buttonText: '확인',
                  borderColor: AppColors.textSecondary,
                  onButtonPressed: () {
                    print('비밀번호 찾기 - 인증번호 확인 버튼 클릭');
                    // TODO: 인증번호 확인 로직 구현
                  },
                ),
                const SizedBox(height:11),
                _buildTimerRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '남은 시간 03:00',
            style: TextStyle(color: AppColors.primary, fontSize: 14),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: AppColors.textSecondary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            child: const Text('시간연장', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}