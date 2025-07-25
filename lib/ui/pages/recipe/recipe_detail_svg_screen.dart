import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'meal.dart'; // 상대 경로로 수정
import 'meal_storage.dart'; // 상대 경로로 수정

class RecipeDetailSvgScreen extends StatelessWidget {
  const RecipeDetailSvgScreen({super.key});

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
            recipeTitle: "아보카도 샐러드", // TODO: 실제 레시피 제목과 연동 가능
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("레시피 상세"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SvgPicture.asset(
          'assets/icons/recipe_detail_page.svg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("식단에 추가"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _showMealSelectionDialog(context),
          ),
        ),
      ),
    );
  }
}
