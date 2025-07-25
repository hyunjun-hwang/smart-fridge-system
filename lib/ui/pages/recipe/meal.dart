// lib/models/meal.dart

class Meal {
  final String type;         // 식사 시간 (예: 아침, 점심, 저녁, 간식)
  final String recipeTitle;  // 레시피 제목

  Meal({required this.type, required this.recipeTitle});
}
