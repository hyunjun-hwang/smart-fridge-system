import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';
import 'package:smart_fridge_system/ui/pages/refrigerator/refrigerator_main.dart';
import 'package:smart_fridge_system/ui/pages/home/mainpage.dart';
import 'package:smart_fridge_system/ui/pages/recipe/recipe_main_page.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/nutrition_screen.dart';
import 'package:smart_fridge_system/ui/pages/refrigerator/add_food_item_dialog.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/ui/pages/profile/profile_screen.dart';
class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  bool _isMenuOpen = false;

  static final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    FridgePage(),
    RecipeMainPage(),
    NutritionScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
      });
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _showAddFoodDialog() async {
    _toggleMenu();

    final newFoodItem = await showDialog<FoodItem>(
      context: context,
      builder: (context) {
        return const AddFoodItemDialog();
      },
    );

    if (newFoodItem != null) {
      print('새로운 음식 추가됨: ${newFoodItem.name}');
    }
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
      body: Stack(
        children: [
          _widgetOptions.elementAt(_selectedIndex),
          if (_isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          if (_isMenuOpen)
            Positioned(
              bottom: 90,
              right: 20,
              child: _buildSpeedDialMenu(),
            ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: AppColors.accent,
              child: Icon(
                _isMenuOpen ? Icons.close : Icons.add,
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

  Widget _buildSpeedDialMenu() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.accent, width: 2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuOption(
            text: '직접 추가하기',
            iconPath: 'assets/images/finger.png',
            onTap: _showAddFoodDialog,
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
