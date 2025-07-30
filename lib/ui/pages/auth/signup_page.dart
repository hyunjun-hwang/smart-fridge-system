import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase 인증 패키지 임포트
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/ui/widgets/custom_text_field.dart';
// import 'package:smart_fridge_system/ui/widgets/input_field_with_button.dart'; // 이 줄을 제거했습니다.
import 'package:smart_fridge_system/ui/widgets/primary_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final List<bool> _genderSelection = [false, true];

  // 텍스트 필드 컨트롤러 추가
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController(); // 생년월일 컨트롤러 (사용하지 않을 수 있음)

  // 에러 메시지를 표시하기 위한 변수
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // 회원가입 로직 함수
  Future<void> _signUp() async {
    setState(() {
      _errorMessage = null; // 에러 메시지 초기화
    });

    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = '모든 필드를 채워주세요.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = '비밀번호가 일치하지 않습니다.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = '비밀번호는 최소 6자 이상이어야 합니다.';
      });
      return;
    }

    try {
      // 1. Firebase를 사용하여 이메일과 비밀번호로 사용자 생성
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. 사용자 프로필(표시 이름) 업데이트 (아이디로 사용)
      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(username); // 아이디를 display name으로 설정

        // 3. 이메일 인증 메일 전송 (선택 사항이지만 강력 권장)
        await user.sendEmailVerification();

        // 회원가입 성공 처리
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('회원가입 성공! 이메일 인증 메일을 확인해주세요: ${user.email}'),
              backgroundColor: Colors.green,
            ),
          );
          // 성공 시 로그인 페이지로 이동하거나 다른 동작 수행
          Navigator.pop(context); // 현재 페이지 닫기 (예시)
        }
      }
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 관련 에러 처리
      String message = '회원가입 중 오류가 발생했습니다.';
      if (e.code == 'weak-password') {
        message = '비밀번호가 너무 약합니다.';
      } else if (e.code == 'email-already-in-use') {
        message = '이미 사용 중인 이메일입니다.';
      } else if (e.code == 'invalid-email') {
        message = '유효하지 않은 이메일 형식입니다.';
      }
      setState(() {
        _errorMessage = message;
      });
      print("Firebase Auth Error: ${e.code} - ${e.message}");
    } catch (e) {
      // 기타 일반적인 에러 처리
      setState(() {
        _errorMessage = '알 수 없는 오류가 발생했습니다.';
      });
      print("General Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                CustomTextField(
                  controller: _usernameController, // 컨트롤러 연결
                  hintText: '아이디',
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _emailController, // 컨트롤러 연결
                  hintText: '이메일',
                  keyboardType: TextInputType.emailAddress, // 이메일 키보드 타입
                ),
                const SizedBox(height: 15),
                // 이전의 '인증번호' 필드를 제거했습니다.
                CustomTextField(
                  controller: _passwordController, // 컨트롤러 연결
                  hintText: '비밀번호',
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _confirmPasswordController, // 컨트롤러 연결
                  hintText: '비밀번호 확인',
                  obscureText: true,
                ),
                const SizedBox(height: 15),

                // 에러 메시지 표시
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // 4. 생년월일 및 성별 선택
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.8 * 0.6,
                      child: CustomTextField(
                        controller: _dobController, // 컨트롤러 연결
                        hintText: '생년월일',
                        keyboardType: TextInputType.datetime, // 날짜 키보드 타입
                      ),
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
                  onPressed: _signUp, // Firebase 회원가입 함수 호출
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}