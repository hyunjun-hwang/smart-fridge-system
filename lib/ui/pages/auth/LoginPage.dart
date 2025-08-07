import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/ui/pages/auth/FindAuthInfoPage.dart';
import 'package:smart_fridge_system/ui/widgets/bottom_nav.dart';
import 'package:smart_fridge_system/ui/widgets/primary_button.dart';
import 'package:smart_fridge_system/ui/widgets/custom_text_field.dart';
import 'package:smart_fridge_system/ui/pages/auth/signup_page.dart';

// 1. StatefulWidget으로 변경
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 2. 아이디와 비밀번호 입력을 위한 컨트롤러 추가
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 3. 에러 메시지와 로딩 상태 관리를 위한 변수 추가
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    // 컨트롤러 리소스 해제
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 4. 로그인 로직을 처리할 함수 구현
  Future<void> _signIn() async {
    if (_idController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "아이디와 비밀번호를 모두 입력해주세요.";
      });
      return;
    }

    setState(() {
      _isLoading = true; // 로딩 시작
      _errorMessage = null;
    });

    try {
      // 1단계: Firestore에서 아이디로 이메일 찾기
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: _idController.text.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // 해당 아이디를 가진 사용자가 없음
        setState(() {
          _errorMessage = "존재하지 않는 아이디입니다.";
          _isLoading = false; // 로딩 끝
        });
        return;
      }

      // 찾은 문서에서 이메일 가져오기
      final userDoc = querySnapshot.docs.first;
      final email = userDoc.get('email');

      // 2단계: 찾아온 이메일과 입력된 비밀번호로 로그인
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      // 로그인 성공 시 화면 이동 (mounted 체크 필수)
      if (mounted) {
        Navigator.pushReplacement( // 로그인 후 뒤로가기 방지
          context,
          MaterialPageRoute(builder: (context) => const BottomNav()),
        );
      }

    } on FirebaseAuthException catch (e) {
      // 비밀번호가 틀렸을 경우 등 인증 에러 처리
      if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        _errorMessage = "아이디 또는 비밀번호가 잘못되었습니다.";
      } else {
        _errorMessage = "로그인에 실패했습니다. 다시 시도해주세요.";
      }
    } catch (e) {
      // 기타 에러 처리
      _errorMessage = "알 수 없는 오류가 발생했습니다.";
    } finally {
      // 함수가 끝나면 로딩 상태 해제 (mounted 체크 필수)
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


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
                SizedBox(
                  height: 100,
                  child: Image.asset('assets/images/logo.png'),
                ),
                const SizedBox(height: 60),
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

                // 5. 컨트롤러 연결
                CustomTextField(
                  controller: _idController,
                  hintText: '아이디',
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _passwordController,
                  hintText: '비밀번호',
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                // 에러 메시지 표시 위젯
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),

                SizedBox(height: _errorMessage != null ? 140 : 180),

                // 6. 로그인 버튼에 _signIn 함수 연결
                // 로딩 중일 경우 버튼 비활성화 및 로딩 인디케이터 표시
                _isLoading
                    ? const CircularProgressIndicator()
                    : PrimaryButton(
                  text: '로그인',
                  onPressed: _signIn,
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