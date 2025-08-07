// FILE: lib/ui/widgets/bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/ui/pages/refrigerator/refrigerator_main.dart';
import 'package:smart_fridge_system/ui/pages/home/mainpage.dart';
import 'package:smart_fridge_system/ui/pages/recipe/recipe_main_page.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/nutrition_screen.dart';
import 'package:smart_fridge_system/ui/pages/profile/profile_screen.dart';
import 'package:smart_fridge_system/ui/pages/refrigerator/food_item_dialog.dart';

final GlobalKey<State<BottomNav>> bottomNavKey = GlobalKey<State<BottomNav>>();

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    const FridgePage(),
    const RecipeMainPage(),
    const NutritionScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddFoodDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const FoodItemDialog();
      },
    );
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
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
        onPressed: _showAddFoodDialog,
        backgroundColor: AppColors.accent,
        child: const Icon(
          Icons.add,
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
        onTap: _onItemTapped, // 함수 이름 변경 반영
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
