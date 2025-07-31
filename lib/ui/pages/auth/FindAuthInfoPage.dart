import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/ui/widgets/primary_button.dart';
import 'package:smart_fridge_system/ui/widgets/custom_text_field.dart';

class FindAuthInfoPage extends StatefulWidget {
  const FindAuthInfoPage({super.key});

  @override
  State<FindAuthInfoPage> createState() => _FindAuthInfoPageState();
}

class _FindAuthInfoPageState extends State<FindAuthInfoPage> {
  // ## 1. 각 입력 필드를 위한 컨트롤러 추가
  final TextEditingController _findIdEmailController = TextEditingController();
  final TextEditingController _resetPwIdController = TextEditingController();
  final TextEditingController _resetPwEmailController = TextEditingController();

  // ## 2. 결과 및 에러 메시지를 표시할 변수 추가
  String? _findIdMessage;
  String? _resetPasswordMessage;

  @override
  void dispose() {
    _findIdEmailController.dispose();
    _resetPwIdController.dispose();
    _resetPwEmailController.dispose();
    super.dispose();
  }

  // ## 3. 아이디 찾기 로직 함수
  Future<void> _findId() async {
    final email = _findIdEmailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _findIdMessage = '이메일을 입력해주세요.';
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final foundId = querySnapshot.docs.first.get('id');
        setState(() {
          _findIdMessage = "회원님의 아이디는 '$foundId' 입니다.";
        });
      } else {
        setState(() {
          _findIdMessage = '해당 이메일로 가입된 아이디가 없습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _findIdMessage = '오류가 발생했습니다. 다시 시도해주세요.';
      });
    }
  }

  // ## 4. 비밀번호 재설정 로직 함수
  Future<void> _resetPassword() async {
    final id = _resetPwIdController.text.trim();
    final email = _resetPwEmailController.text.trim();

    if (id.isEmpty || email.isEmpty) {
      setState(() {
        _resetPasswordMessage = '아이디와 이메일을 모두 입력해주세요.';
      });
      return;
    }

    try {
      // 먼저 아이디와 이메일이 일치하는 사용자가 있는지 확인
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: id)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _resetPasswordMessage = '아이디와 이메일이 일치하는 사용자를 찾을 수 없습니다.';
        });
        return;
      }

      // 사용자가 확인되면 비밀번호 재설정 이메일 발송
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _resetPasswordMessage = '입력하신 이메일로 비밀번호 재설정 링크를 보냈습니다.';
      });
    } catch (e) {
      setState(() {
        _resetPasswordMessage = '오류가 발생했습니다. 다시 시도해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                CustomTextField(
                  controller: _findIdEmailController,
                  hintText: '이메일',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                if (_findIdMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(_findIdMessage!, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 20),
                // ## [변경점] 버튼을 Center 위젯으로 감싸서 중앙 정렬
                Center(
                  child: PrimaryButton(text: '아이디 찾기', onPressed: _findId),
                ),

                const SizedBox(height: 60),

                const Text(
                  '비밀번호 재설정',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _resetPwIdController,
                  hintText: '아이디 입력',
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _resetPwEmailController,
                  hintText: '이메일',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                if (_resetPasswordMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(_resetPasswordMessage!, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 20),
                // ## [변경점] 버튼을 Center 위젯으로 감싸서 중앙 정렬
                Center(
                  child: PrimaryButton(text: '비밀번호 재설정 메일 받기', onPressed: _resetPassword),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}