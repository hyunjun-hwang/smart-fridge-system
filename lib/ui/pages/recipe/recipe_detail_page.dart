import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'meal.dart';
import 'meal_storage.dart';

class RecipeDetailPage extends StatelessWidget {
  const RecipeDetailPage({super.key});

  void _showMealSelectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "어느 식사에 추가할까요?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildMealTile(context, "아침"),
            _buildMealTile(context, "점심"),
            _buildMealTile(context, "저녁"),
            _buildMealTile(context, "간식"),
          ],
        );
      },
    );
  }

  Widget _buildMealTile(BuildContext context, String type) {
    return ListTile(
      leading: const Icon(Icons.fastfood),
      title: Text(type),
      onTap: () {
        Navigator.pop(context);
        MealStorage.addMeal(
          Meal(
            type: type,
            recipeTitle: "아보카도 샐러드",
          ),
        );
        _showSnackBar(context, "$type 식단에 추가되었습니다!");
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildImageIcon(String path) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Image.asset(
        path,
        width: 40,
        height: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("레시피 상세"),
        centerTitle: true,
        backgroundColor: const Color(0xFF003508),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(
              'assets/images/recipe.png',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImageIcon('assets/images/logo.png'),
                _buildImageIcon('assets/images/home.png'),
                _buildImageIcon('assets/images/profile.png'),
                _buildImageIcon('assets/images/refrigerator.png'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImageIcon('assets/images/finger.png'),
                _buildImageIcon('assets/images/nutrient.png'),
                _buildImageIcon('assets/images/bacode.png'),
              ],
            ),
            const SizedBox(height: 16),
            SvgPicture.asset(
              'assets/icons/recipe_detail_page.svg',
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMealSelectionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("식단에 추가"),
        backgroundColor: const Color(0xFF00BBA3),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
