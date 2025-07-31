import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/ui/widgets/custom_text_field.dart';
import 'package:smart_fridge_system/ui/widgets/primary_button.dart';
import 'package:smart_fridge_system/ui/widgets/small_primary_button.dart'; // ## 1. 새로 만든 버튼 임포트

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // ... (State 변수들과 함수들은 이전과 동일)
  final List<bool> _genderSelection = [false, true];
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _errorMessage;
  String? _usernameCheckMessage;
  Color _usernameCheckMessageColor = Colors.red;
  bool _isUsernameChecked = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _checkUsername() async {
    final String username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _usernameCheckMessage = '아이디를 입력해주세요.';
        _usernameCheckMessageColor = Colors.red;
        _isUsernameChecked = false;
      });
      return;
    }
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: username)
        .get();
    setState(() {
      if (querySnapshot.docs.isEmpty) {
        _usernameCheckMessage = '사용 가능한 아이디입니다.';
        _usernameCheckMessageColor = Colors.green;
        _isUsernameChecked = true;
      } else {
        _usernameCheckMessage = '이미 사용 중인 아이디입니다.';
        _usernameCheckMessageColor = Colors.red;
        _isUsernameChecked = false;
      }
    });
  }

  Future<void> _signUp() async {
    if (_usernameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty ||
        _dobController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '모든 필드를 입력해주세요.';
      });
      return;
    }
    if (!_isUsernameChecked) {
      setState(() {
        _errorMessage = '아이디 중복 확인을 해주세요.';
      });
      return;
    }
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = '비밀번호가 일치하지 않습니다.';
      });
      return;
    }
    if (_passwordController.text.trim().length < 6) {
      setState(() {
        _errorMessage = '비밀번호는 최소 6자 이상이어야 합니다.';
      });
      return;
    }
    setState(() {
      _errorMessage = null;
    });
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;
      if (user != null) {
        final userData = {
          'uid': user.uid,
          'id': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'dob': _dobController.text.trim(),
          'gender': _genderSelection[0] ? '남' : '여',
          'createdAt': Timestamp.now(),
        };
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData);
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원가입 성공! 이메일 인증 메일을 확인해주세요.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = '비밀번호가 너무 약합니다.';
      } else if (e.code == 'email-already-in-use') {
        message = '이미 사용 중인 이메일입니다.';
      } else if (e.code == 'invalid-email') {
        message = '유효하지 않은 이메일 형식입니다.';
      } else {
        message = '회원가입 중 오류가 발생했습니다.';
      }
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '알 수 없는 오류가 발생했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // ... (AppBar는 이전과 동일)
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ... (로고, 타이틀 등은 이전과 동일)
                SizedBox(
                  height: 100,
                  child: Image.asset('assets/images/logo.png'),
                ),
                const SizedBox(height: 30),
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

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.8 * 0.6,
                      child: CustomTextField(
                        controller: _usernameController,
                        hintText: '아이디',
                      ),
                    ),
                    const Spacer(),

                    // ## 2. 기존 ElevatedButton을 새로 만든 SmallPrimaryButton으로 교체
                    SmallPrimaryButton(
                      text: '중복확인',
                      onPressed: _checkUsername,
                    ),
                  ],
                ),

                // ... (이하 나머지 UI 코드는 이전과 동일)
                if (_usernameCheckMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _usernameCheckMessage!,
                        style: TextStyle(
                          color: _usernameCheckMessageColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _emailController,
                  hintText: '이메일',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _passwordController,
                  hintText: '비밀번호',
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: '비밀번호 확인',
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.8 * 0.6,
                      child: CustomTextField(
                        controller: _dobController,
                        hintText: '생년월일',
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                    const Spacer(),
                    ToggleButtons(
                      isSelected: _genderSelection,
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0;
                          i < _genderSelection.length;
                          i++) {
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
                const SizedBox(height: 45),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                PrimaryButton(
                  text: '회원가입 하기',
                  onPressed: _signUp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}