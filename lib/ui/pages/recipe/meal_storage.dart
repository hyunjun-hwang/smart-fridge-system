import 'package:smart_fridge_system/ui/pages/recipe/meal.dart';

class MealStorage {
  static final List<Meal> _meals = [];

  static void addMeal(Meal meal) {
    _meals.add(meal);
  }

  static List<Meal> getMeals() {
    return List.unmodifiable(_meals);
  }

  static void removeMeal(int index) {
    _meals.removeAt(index);
  }

  static void clear() {
    _meals.clear();
  }
}

