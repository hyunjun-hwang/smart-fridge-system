import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/ui/pages/refrigerator/refrigerator_main.dart';
import 'package:smart_fridge_system/ui/pages/home/mainpage.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  // --- 1. 스피드 다이얼 메뉴의 노출 상태를 관리하는 변수 추가 ---
  bool _isMenuOpen = false;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    FridgePage(),
    Center(child: Text('레시피 페이지')),
    Center(child: Text('영양소 페이지')),
    Center(child: Text('프로필 페이지')),
  ];

  void _onItemTapped(int index) {
    // 다른 탭으로 이동 시 메뉴가 열려있으면 닫기
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
      });
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- 2. 플로팅 버튼 클릭 시 메뉴를 토글하는 함수 ---
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 1
          ? AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('냉장고',
            style: TextStyle(
                color: AppColors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined,
                color: AppColors.black),
            onPressed: () {},
          ),
        ],
      )
          : null,
      // --- 3. Stack을 사용해 기존 화면 위에 메뉴를 띄울 수 있도록 구조 변경 ---
      body: Stack(
        children: [
          _widgetOptions.elementAt(_selectedIndex),
          // 메뉴가 열렸을 때만 표시
          if (_isMenuOpen)
          // 뒷 배경을 눌러도 메뉴가 닫히도록 GestureDetector 추가
            GestureDetector(
              onTap: _toggleMenu, // 어두운 배경 클릭 시 메뉴 닫기
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          if (_isMenuOpen)
          // --- 4. 요청하신 디자인의 커스텀 메뉴 위젯 ---
            Positioned(
              bottom: 90, // FAB 위치에 맞게 조정
              right: 20,
              child: _buildSpeedDialMenu(),
            ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
        onPressed: _toggleMenu, // 이제 메뉴를 토글하는 함수 호출
        backgroundColor: AppColors.accent,
        child: Icon(
          _isMenuOpen ? Icons.close : Icons.add, // 메뉴 상태에 따라 아이콘 변경
          color: AppColors.primary,
          size: 30,
        ),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/home.png', width: 24, height: 24),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/refrigerator.png',
                width: 24, height: 24),
            label: '냉장고',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/recipe.png', width: 24, height: 24),
            label: '레시피',
          ),
          BottomNavigationBarItem(
            icon:
            Image.asset('assets/images/nutrient.png', width: 24, height: 24),
            label: '영양소',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/profile.png', width: 24, height: 24),
            label: '프로필',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: AppColors.accent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.8),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
      ),
    );
  }

  // --- 5. 스피드 다이얼 메뉴를 그리는 별도 함수 ---
  Widget _buildSpeedDialMenu() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.accent, width: 2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuOption(
            text: '직접 추가하기',
            iconPath: 'assets/images/finger.png',
            onTap: () {
              print('직접 추가하기 선택');
              _toggleMenu();
            },
          ),
          const Divider(height: 1, color: AppColors.accent),
          _buildMenuOption(
            text: '바코드로 추가하기',
            iconPath: 'assets/images/bacode.png',
            onTap: () {
              print('바코드로 추가하기 선택');
              _toggleMenu();
            },
          ),
        ],
      ),
    );
  }

  // 메뉴 옵션을 만드는 helper 함수
  Widget _buildMenuOption({
    required String text,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Image.asset(iconPath, width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}