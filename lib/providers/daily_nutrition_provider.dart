import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';

class DailyNutritionProvider with ChangeNotifier {
  double _targetCalories = 1800;
  double get totalCalories {
    final keyDate = _normalizeDate(_selectedDate);
    return _dailyNutritions[keyDate]?['calories'] ?? 0;
  }

  double get targetCalories => _targetCalories;

  void setTargetCalories(double calories) {
    _targetCalories = calories;
    notifyListeners();
  }

  final Map<DateTime, Map<String, double>> _dailyNutritions = {};
  final Map<DateTime, Map<String, List<FoodItemn>>> _mealFoods = {};

  DateTime _selectedDate = DateTime.now();

  Map<DateTime, Map<String, double>> get dailyNutritions => _dailyNutritions;
  DateTime get selectedDate => _selectedDate;

  Map<String, double> get currentDayNutrition {
    final keyDate = _normalizeDate(_selectedDate);
    return _dailyNutritions[keyDate] ?? {
      'calories': 0,
      'carbohydrates': 0,
      'protein': 0,
      'fat': 0,
    };
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = _normalizeDate(date);
    notifyListeners();
  }

  void addFood(String mealType, DateTime date, FoodItemn item) {
    final keyDate = _normalizeDate(date);

    _mealFoods.putIfAbsent(keyDate, () => {});
    _mealFoods[keyDate]!.putIfAbsent(mealType, () => []);

    final existingIndex =
    _mealFoods[keyDate]![mealType]!.indexWhere((f) => f.name == item.name);

    if (existingIndex != -1) {
      final existing = _mealFoods[keyDate]![mealType]![existingIndex];
      _mealFoods[keyDate]![mealType]![existingIndex] =
          existing.copyWith(count: existing.count + item.count);
    } else {
      _mealFoods[keyDate]![mealType]!.add(item);
    }

    _recalculateDayNutrition(keyDate);
    notifyListeners();
  }

  void updateFood(String mealType, DateTime date, FoodItemn item) {
    final keyDate = _normalizeDate(date);
    final foodList = _mealFoods[keyDate]?[mealType];
    if (foodList == null) return;

    final index = foodList.indexWhere((f) => f.name == item.name);
    if (index == -1) return;

    if (item.count <= 0) {
      foodList.removeAt(index);
    } else {
      foodList[index] = item;
    }

    _recalculateDayNutrition(keyDate);
    notifyListeners();
  }

  void removeFoodItem(String mealType, DateTime date, String foodName) {
    final keyDate = _normalizeDate(date);
    final foodList = _mealFoods[keyDate]?[mealType];
    if (foodList == null) return;

    foodList.removeWhere((item) => item.name == foodName);

    _recalculateDayNutrition(keyDate);
    notifyListeners();
  }

  /// ✅ 안전한 삭제 (음식 객체 기반)
  void removeFoodItemByObject(String mealType, DateTime date, FoodItemn item) {
    final keyDate = _normalizeDate(date);
    final foodList = _mealFoods[keyDate]?[mealType];
    if (foodList == null) return;

    foodList.removeWhere((element) =>
    element.name == item.name &&
        element.calories == item.calories &&
        element.carbohydrates == item.carbohydrates &&
        element.protein == item.protein &&
        element.fat == item.fat);

    _recalculateDayNutrition(keyDate);
    notifyListeners();
  }

  void _recalculateDayNutrition(DateTime keyDate) {
    double totalCalories = 0, carbs = 0, protein = 0, fat = 0;

    _mealFoods[keyDate]?.forEach((_, List<FoodItemn> mealFoods) {
      for (final item in mealFoods) {
        totalCalories += item.calories * item.count;
        carbs += item.carbohydrates * item.count;
        protein += item.protein * item.count;
        fat += item.fat * item.count;
      }
    });

    _dailyNutritions[keyDate] = {
      'calories': totalCalories,
      'carbohydrates': carbs,
      'protein': protein,
      'fat': fat,
    };
  }

  Map<String, double> getMealNutrition(String meal, DateTime date) {
    final keyDate = _normalizeDate(date);
    final foods = _mealFoods[keyDate]?[meal] ?? [];

    double calories = 0, carbs = 0, protein = 0, fat = 0;

    for (final food in foods) {
      calories += food.calories * food.count;
      carbs += food.carbohydrates * food.count;
      protein += food.protein * food.count;
      fat += food.fat * food.count;
    }

    return {
      'calories': calories,
      'carbohydrates': carbs,
      'protein': protein,
      'fat': fat,
    };
  }

  List<FoodItemn> getFoodsByMeal(String meal, DateTime date) {
    final keyDate = _normalizeDate(date);
    return _mealFoods[keyDate]?[meal] ?? [];
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('M월 d일 (E)', 'ko_KR').format(date);
  }

  Map<DateTime, double> getDailyCaloriesForGraph() {
    final result = <DateTime, double>{};
    for (var entry in _dailyNutritions.entries) {
      final date = _normalizeDate(entry.key);
      result[date] = entry.value['calories'] ?? 0;
    }
    return result;
  }

  Map<DateTime, double> getWeeklyCalories() {
    final sorted = _dailyNutritions.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final result = <DateTime, double>{};

    for (int i = 0; i < sorted.length; i += 7) {
      final chunk = sorted.skip(i).take(7);
      final weekStart = chunk.first.key;
      final total =
      chunk.fold<double>(0, (sum, e) => sum + (e.value['calories'] ?? 0));
      result[weekStart] = total;
    }

    return result;
  }

  Map<DateTime, double> getMonthlyCalories() {
    final Map<String, double> temp = {};
    for (var entry in _dailyNutritions.entries) {
      final key =
          '${entry.key.year}-${entry.key.month.toString().padLeft(2, '0')}';
      temp[key] = (temp[key] ?? 0) + (entry.value['calories'] ?? 0);
    }

    return temp.map((key, value) {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      return MapEntry(DateTime(year, month), value);
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void clearAll() {
    _dailyNutritions.clear();
    _mealFoods.clear();
    notifyListeners();
  }
}
