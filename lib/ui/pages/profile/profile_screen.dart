import 'dart:io'; // ⭐️ FileImage를 사용하기 위해 추가
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_fridge_system/constants/app_colors.dart'; // ⭐️ AppColors import
import 'package:smart_fridge_system/ui/pages/profile/profile_detail_screen.dart';
// import 'package:smart_fridge_system/providers/profile_provider.dart'; // 이 파일에서는 사용하지 않으므로 주석 처리 또는 삭제 가능
import 'package:smart_fridge_system/providers/user_provider.dart';
import 'package:smart_fridge_system/ui/pages/auth/LoginPage.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐️ 중요: UserProvider는 앱의 상위 위젯(예: main.dart의 MaterialApp 위)에서 제공되어야 합니다.
    // 여기서 MultiProvider로 UserProvider를 새로 생성하면 다른 화면과 상태가 공유되지 않습니다.
    // 이 화면에서는 이미 상위에서 제공된 UserProvider를 사용한다고 가정합니다.
    return const _ProfileContent();
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent({super.key});

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  bool _notificationsEnabled = true;

  // --- 로그아웃 관련 함수 (기존과 동일) ---
  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('로그아웃 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('아니오', style: TextStyle(color: AppColors.primary)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('네', style: TextStyle(color: AppColors.primary)),
              onPressed: _signOut,
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      Navigator.of(context, rootNavigator: true).pop(); // 다이얼로그 닫기
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint("로그아웃 에러: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그아웃 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⭐️ Consumer를 사용해 UserProvider의 변경사항을 실시간으로 감지
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // ⭐️ 프로필 이미지 표시 로직
        ImageProvider<Object> profileImage;
        final imagePath = userProvider.profileImagePath;

        if (imagePath != null && imagePath.isNotEmpty) {
          profileImage = FileImage(File(imagePath));
        } else {
          // 기본 이미지가 프로젝트에 포함되어 있어야 합니다. (예: assets/placeholder.png)
          profileImage = const AssetImage('assets/placeholder.png');
        }

        return Scaffold(
          // ⭐️ AppColors 적용
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            title: const Text(
              '프로필',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: userProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  // ⭐️ UserProvider는 이미 상위에서 제공되므로, .value 생성자가 필요 없습니다.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileDetailScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // ⭐️ 프로필 이미지 CircleAvatar 수정
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: profileImage,
                        backgroundColor: Colors.grey.shade200,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ⭐️ Provider에서 이름과 이메일 가져오기
                          Text(
                            userProvider.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userProvider.email,
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
                secondary: const Icon(Icons.notifications_none, color: AppColors.primary),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: AppColors.accent,
              ),
              _buildSettingTile(Icons.devices_other, '기기 연결'),
              _buildSettingTile(Icons.logout, '로그아웃', onTap: _showLogoutDialog),
              _buildSettingTile(Icons.delete_outline, '계정 탈퇴'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {
        debugPrint('$title 클릭됨');
      },
    );
  }
}