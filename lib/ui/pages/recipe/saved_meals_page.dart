import 'package:flutter/material.dart';
import '/storage/meal_storage.dart';

class SavedMealsPage extends StatefulWidget {
  const SavedMealsPage({super.key});

  @override
  State<SavedMealsPage> createState() => _SavedMealsPageState();
}

class _SavedMealsPageState extends State<SavedMealsPage> {
  @override
  Widget build(BuildContext context) {
    final meals = MealStorage.getMeals();

    return Scaffold(
      appBar: AppBar(
        title: const Text("내 식단 목록"),
      ),
      body: meals.isEmpty
          ? const Center(child: Text("추가된 식단이 없습니다."))
          : ListView.builder(
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: Text(meal.recipeTitle),
              subtitle: Text("${meal.type} 식사"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    MealStorage.removeMeal(index); // ✅ 삭제
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("식단이 삭제되었습니다.")),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
