import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 숫자 입력을 위해 import
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  // 컨트롤러
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dobController = TextEditingController(); // '나이' -> '생년월일'
  final TextEditingController _emailController = TextEditingController();

  List<bool> _genderSelection = [true, false]; // [남성, 여성]
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ## [변경점] 달력으로 날짜를 선택하는 함수 추가
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        String genderFromDB = data['gender'] ?? '남성';

        setState(() {
          _nameController.text = data['id'] ?? '';
          _heightController.text = (data['height'] ?? 0).toString();
          _weightController.text = (data['weight'] ?? 0).toString();
          _dobController.text = data['dob'] ?? ''; // '나이' -> '생년월일'
          _emailController.text = data['email'] ?? '';
          _genderSelection = [genderFromDB == '남성', genderFromDB == '여성'];
        });
      }
    } catch (e) {
      debugPrint("데이터 로딩 에러: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final dataToUpdate = {
        // 'id'와 'email'은 읽기 전용이므로 저장 로직에서 제외
        'height': int.tryParse(_heightController.text) ?? 0,
        'weight': int.tryParse(_weightController.text) ?? 0,
        'dob': _dobController.text, // '나이' -> '생년월일'
        'gender': _genderSelection[0] ? '남성' : '여성',
      };
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(dataToUpdate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 저장되었습니다.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("프로필 저장 에러: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _dobController.dispose(); // '나이' -> '생년월일'
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF003508),
        centerTitle: true,
        title: const Text('프로필'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('저장하기', style: TextStyle(color: Color(0xFF003508))),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/1.jpg'),
                ),
                SizedBox(width: 12),
                Text('프로필 사진 변경',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003508))),
              ],
            ),
            const SizedBox(height: 24),
            const Text('내 정보',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF003508))),
            const SizedBox(height: 16),

            _buildTextField('이메일', _emailController, enabled: false),
            _buildTextField('사용자 이름', _nameController, enabled: false), // ## 읽기 전용으로 변경
            _buildTextField( // ## 숫자만 입력 가능
              '신장/키 (cm)',
              _heightController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _buildTextField( // ## 숫자만 입력 가능
              '체중(kg)',
              _weightController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            // ## '나이' 필드를 '생년월일' 달력 선택으로 변경
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('생년월일', style: TextStyle(color: Color(0xFF003508))),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.calendar_month_outlined, color: Colors.grey.shade600),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF003508)),
                      ),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('성별', style: TextStyle(color: Color(0xFF003508), fontSize: 16)),
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
                        child: Text('남성'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('여성'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ## inputFormatters 파라미터 추가
  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF003508))),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters, // ## 숫자 입력을 위한 포맷터 적용
            cursorColor: const Color(0xFF003508),
            decoration: InputDecoration(
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF003508)),
              ),
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }
}