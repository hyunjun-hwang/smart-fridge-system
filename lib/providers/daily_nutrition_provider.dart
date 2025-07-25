import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyNutritionProvider with ChangeNotifier {
  double _targetCalories = 1800;

  Map<DateTime, Map<String, double>> _dailyNutritions = {
    DateTime(2025, 7, 11): {
      'calories': 1000,
      'carbohydrates': 27,
      'protein': 27,
      'fat': 27,
    },
  };

  DateTime _selectedDate = DateTime.now();

  double get targetCalories => _targetCalories;
  Map<DateTime, Map<String, double>> get dailyNutritions => _dailyNutritions;
  DateTime get selectedDate => _selectedDate;

  Map<String, double> get currentDayNutrition {
    final keyDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    return _dailyNutritions[keyDate] ?? {
      'calories': 0,
      'carbohydrates': 0,
      'protein': 0,
      'fat': 0,
    };
  }

  void setTargetCalories(double calories) {
    _targetCalories = calories;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  void addNutrition(
      DateTime date,
      String mealType,
      String foodName, {
        double? calories,
        double? carbohydrates,
        double? protein,
        double? fat,
      }) {
    final keyDate = DateTime(date.year, date.month, date.day);

    _dailyNutritions.putIfAbsent(keyDate, () => {
      'calories': 0,
      'carbohydrates': 0,
      'protein': 0,
      'fat': 0,
    });

    if (calories != null) {
      _dailyNutritions[keyDate]!['calories'] =
          (_dailyNutritions[keyDate]!['calories'] ?? 0) + calories;
    }
    if (carbohydrates != null) {
      _dailyNutritions[keyDate]!['carbohydrates'] =
          (_dailyNutritions[keyDate]!['carbohydrates'] ?? 0) + carbohydrates;
    }
    if (protein != null) {
      _dailyNutritions[keyDate]!['protein'] =
          (_dailyNutritions[keyDate]!['protein'] ?? 0) + protein;
    }
    if (fat != null) {
      _dailyNutritions[keyDate]!['fat'] =
          (_dailyNutritions[keyDate]!['fat'] ?? 0) + fat;
    }

    notifyListeners();
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('M월 d일 (E)', 'ko_KR').format(date);
  }

  Map<DateTime, double> getDailyCaloriesForGraph() {
    final result = <DateTime, double>{};
    for (var entry in _dailyNutritions.entries) {
      final date = DateTime(entry.key.year, entry.key.month, entry.key.day);
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
      final weekStart = DateTime(
        chunk.first.key.year,
        chunk.first.key.month,
        chunk.first.key.day,
      );
      final total = chunk.fold<double>(0, (sum, e) => sum + (e.value['calories'] ?? 0));
      result[weekStart] = total;
    }

    return result;
  }

  Map<DateTime, double> getMonthlyCalories() {
    final Map<String, double> temp = {};
    for (var entry in _dailyNutritions.entries) {
      final key = '${entry.key.year}-${entry.key.month.toString().padLeft(2, '0')}';
      temp[key] = (temp[key] ?? 0) + (entry.value['calories'] ?? 0);
    }

    return temp.map((key, value) {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      return MapEntry(DateTime(year, month), value);
    });
  }

  Map<String, double> getMealNutrition(String meal, DateTime date) {
    if (meal == '아침' && isSameDay(date, DateTime(2025, 7, 11))) {
      return {
        'calories': 400,
        'carbohydrates': 50,
        'protein': 10,
        'fat': 5,
      };
    } else {
      return {
        'calories': 0,
        'carbohydrates': 0,
        'protein': 0,
        'fat': 0,
      };
    }
  }

  List<Map<String, dynamic>> getFoodsByMeal(String meal, DateTime date) {
    if (meal == '아침' && isSameDay(date, DateTime(2025, 7, 11))) {
      return [
        {'name': '사과', 'amount': 200, 'calories': 100, 'count': 1},
        {'name': '바나나', 'amount': 150, 'calories': 150, 'count': 1},
      ];
    } else {
      return [];
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
