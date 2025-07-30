import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/providers/user_provider.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _gender = '남성';

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = userProvider.name;
    _heightController.text = userProvider.height.toString();
    _weightController.text = userProvider.weight.toString();
    _ageController.text = userProvider.age.toString();
    _emailController.text = userProvider.email;
    _passwordController.text = userProvider.password;
    _gender = userProvider.gender;
  }

  void _saveProfile() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateProfile(
      name: _nameController.text,
      height: int.tryParse(_heightController.text) ?? 0,
      weight: int.tryParse(_weightController.text) ?? 0,
      age: int.tryParse(_ageController.text) ?? 0,
      gender: _gender,
      email: _emailController.text,
      password: _passwordController.text,
    );
    Navigator.pop(context); // 저장 후 뒤로
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
      body: SingleChildScrollView(
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
            _buildTextField('사용자 이름', _nameController),
            _buildTextField('신장/키 (cm)', _heightController),
            _buildTextField('체중(kg)', _weightController),
            _buildTextField('나이 (만)', _ageController),
            _buildDropdownField('성별', ['남성', '여성']),
            _buildTextField('이메일', _emailController),
            _buildTextField('비밀번호', _passwordController, isPassword: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF003508))),
          TextField(
            controller: controller,
            obscureText: isPassword,
            cursorColor: const Color(0xFF003508),
            decoration: const InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF003508)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF003508))),
          DropdownButton<String>(
            value: _gender,
            isExpanded: true,
            items: options
                .map((option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _gender = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
