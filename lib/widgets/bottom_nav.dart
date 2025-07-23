import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/pages/refrigerator/refrigerator_main.dart';

// 1. StatefulWidget
class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  // 2. MainScreen에 있던 상태와 로직을 모두 가져옴
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('홈 페이지')),
    FridgePage(),
    Center(child: Text('레시피 페이지')),
    Center(child: Text('영양소 페이지')),
    Center(child: Text('프로필 페이지')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 3. 위젯이 직접 Scaffold를 반환하도록 구조 변경
    return Scaffold(
      appBar: _selectedIndex == 1
          ? AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('냉장고', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: AppColors.black),
            onPressed: () {},
          ),
        ],
      )
          : null,
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.primary, size: 30),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/home.png', width: 24, height: 24),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/refrigerator.png', width: 24, height: 24),
            label: '냉장고',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/recipe.png', width: 24, height: 24),
            label: '레시피',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/nutrient.png', width: 24, height: 24),
            label: '영양소',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/profile.png', width: 24, height: 24),
            label: '프로필',
          ),
        ],
        currentIndex: _selectedIndex, // 내부 상태 사용
        onTap: _onItemTapped,        // 내부 함수 사용

        // 스타일링
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
}