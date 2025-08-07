import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth 임포트
import 'package:smart_fridge_system/ui/pages/profile/profile_detail_screen.dart';
import 'package:smart_fridge_system/providers/profile_provider.dart';
import 'package:smart_fridge_system/providers/user_provider.dart';
import 'package:smart_fridge_system/ui/pages/auth/LoginPage.dart'; // LoginPage 임포트

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent({super.key});

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  bool _notificationsEnabled = true;

  // ## 1. 로그아웃 다이얼로그를 보여주는 함수 추가
  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 다이얼로그 바깥을 터치해도 닫히지 않음
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('로그아웃 하시겠습니까?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: const Text('네'),
              onPressed: _signOut, // 로그아웃 함수 호출
            ),
          ],
        );
      },
    );
  }

  // ## 2. Firebase 로그아웃 및 화면 이동을 처리하는 함수 추가
  Future<void> _signOut() async {
    try {
      // 먼저 다이얼로그를 닫습니다.
      Navigator.of(context).pop();

      // Firebase에서 로그아웃합니다.
      await FirebaseAuth.instance.signOut();

      // 로그인 페이지로 이동하고, 이전의 모든 페이지 기록을 삭제합니다.
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint("로그아웃 에러: $e");
      // 에러 발생 시 사용자에게 알림 (선택 사항)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그아웃 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '프로필',
          style: TextStyle(
            color: Color(0xFF003508),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: user,
                    child: const ProfileDetailScreen(),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/men/1.jpg',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('알림'),
            secondary: const Icon(Icons.notifications_none, color: Color(0xFF003508)),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: const Color(0xFFC7D8A4),
          ),
          _buildSettingTile(Icons.devices_other, '기기 연결'),
          // ## 3. '로그아웃' 타일에 _showLogoutDialog 함수 연결
          _buildSettingTile(Icons.logout, '로그아웃', onTap: _showLogoutDialog),
          _buildSettingTile(Icons.delete_outline, '계정 탈퇴'),
        ],
      ),
    );
  }

  // ## 4. _buildSettingTile 함수가 커스텀 onTap 함수를 받을 수 있도록 수정
  Widget _buildSettingTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF003508)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {
        debugPrint('$title 클릭됨');
      },
    );
  }
}