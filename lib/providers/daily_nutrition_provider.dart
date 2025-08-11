import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';

class DailyNutritionProvider with ChangeNotifier {
  double _targetCalories = 1800;
  final Map<DateTime, Map<String, double>> _dailyNutritions = {};
  final Map<DateTime, Map<String, List<FoodItemn>>> _mealFoods = {};
  DateTime _selectedDate = DateTime.now();

  // ---------- Getter ----------
  double get targetCalories => _targetCalories;
  DateTime get selectedDate => _selectedDate;
  Map<DateTime, Map<String, double>> get dailyNutritions => _dailyNutritions;

  double get totalCalories {
    final keyDate = _normalizeDate(_selectedDate);
    return _dailyNutritions[keyDate]?['calories'] ?? 0;
  }

  Map<String, double> get currentDayNutrition {
    final keyDate = _normalizeDate(_selectedDate);
    return _dailyNutritions[keyDate] ?? {
      'calories': 0,
      'carbohydrates': 0,
      'protein': 0,
      'fat': 0,
    };
  }

  // ---------- 상태 변경(저장 포함) ----------
  void setTargetCalories(double calories) {
    _targetCalories = calories;
    notifyListeners();
    _persist();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = _normalizeDate(date);
    notifyListeners();
    _persist();
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
    _persist();
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
    _persist();
  }

  void removeFoodItem(String mealType, DateTime date, String foodName) {
    final keyDate = _normalizeDate(date);
    final foodList = _mealFoods[keyDate]?[mealType];
    if (foodList == null) return;

    foodList.removeWhere((item) => item.name == foodName);

    _recalculateDayNutrition(keyDate);
    notifyListeners();
    _persist();
  }

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
    _persist();
  }

  Future<void> clearAll() async {
    _dailyNutritions.clear();
    _mealFoods.clear();
    notifyListeners();

    final box = Hive.box('nutritionBox');
    await box.delete(_boxKey); // 로컬 데이터도 삭제
  }

  // ---------- 조회/유틸 ----------
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

  // ===================== Hive 저장/복원 =====================
  static const String _boxKey = 'daily_nutrition_state_v1';

  /// 앱 시작 시 한 번 호출해서 복원
  Future<void> restore() async {
    final box = Hive.box('nutritionBox');
    final raw = box.get(_boxKey);
    if (raw == null) return;

    try {
      final map = Map<String, dynamic>.from(json.decode(raw as String));

      _targetCalories = (map['targetCalories'] ?? 1800).toDouble();

      final sel = map['selectedDate'] as String?;
      if (sel != null) {
        _selectedDate = _parseDateKey(sel);
      }

      _dailyNutritions.clear();
      final dn = map['dailyNutritions'] as Map<String, dynamic>?;
      if (dn != null) {
        dn.forEach((dateKey, nutAny) {
          final nut = Map<String, dynamic>.from(nutAny as Map);
          _dailyNutritions[_parseDateKey(dateKey)] = {
            'calories': (nut['calories'] ?? 0).toDouble(),
            'carbohydrates': (nut['carbohydrates'] ?? 0).toDouble(),
            'protein': (nut['protein'] ?? 0).toDouble(),
            'fat': (nut['fat'] ?? 0).toDouble(),
          };
        });
      }

      _mealFoods.clear();
      final mf = map['mealFoods'] as Map<String, dynamic>?;
      if (mf != null) {
        mf.forEach((dateKey, mealAny) {
          final date = _parseDateKey(dateKey);
          _mealFoods[date] = {};
          final mealMap = Map<String, dynamic>.from(mealAny as Map);
          mealMap.forEach((meal, listAny) {
            final list = (listAny as List)
                .map((e) => _foodFromMap(Map<String, dynamic>.from(e as Map)))
                .toList();
            _mealFoods[date]![meal] = list;
          });
        });
      }

      notifyListeners();
    } catch (_) {
      // 파싱 실패 시 무시 (필요 시 box.delete(_boxKey))
    }
  }

  Future<void> _persist() async {
    final box = Hive.box('nutritionBox');

    final dn = <String, Map<String, double>>{};
    _dailyNutritions.forEach((date, nut) {
      dn[_dateKey(date)] = {
        'calories': (nut['calories'] ?? 0).toDouble(),
        'carbohydrates': (nut['carbohydrates'] ?? 0).toDouble(),
        'protein': (nut['protein'] ?? 0).toDouble(),
        'fat': (nut['fat'] ?? 0).toDouble(),
      };
    });

    final mf = <String, Map<String, List<Map<String, dynamic>>>>{};
    _mealFoods.forEach((date, mealMap) {
      final mealOut = <String, List<Map<String, dynamic>>>{};
      mealMap.forEach((meal, foods) {
        mealOut[meal] = foods.map(_foodToMap).toList();
      });
      mf[_dateKey(date)] = mealOut;
    });

    final snapshot = {
      'targetCalories': _targetCalories,
      'selectedDate': _dateKey(_selectedDate),
      'dailyNutritions': dn,
      'mealFoods': mf,
    };

    await box.put(_boxKey, json.encode(snapshot));
  }

  // ---------- 직렬화 헬퍼 ----------
  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  DateTime _parseDateKey(String s) {
    final p = s.split('-').map(int.parse).toList();
    return DateTime(p[0], p[1], p[2]);
  }

  Map<String, dynamic> _foodToMap(FoodItemn f) => {
    'name': f.name,
    'calories': f.calories,
    'carbohydrates': f.carbohydrates,
    'protein': f.protein,
    'fat': f.fat,
    'amount': f.amount,
    'count': f.count,
    'imagePath': f.imagePath,
  };

  FoodItemn _foodFromMap(Map<String, dynamic> m) => FoodItemn(
    name: (m['name'] ?? '') as String,
    calories: (m['calories'] ?? 0).toDouble(),
    carbohydrates: (m['carbohydrates'] ?? 0).toDouble(),
    protein: (m['protein'] ?? 0).toDouble(),
    fat: (m['fat'] ?? 0).toDouble(),
    amount: (m['amount'] ?? 0).toDouble(),
    count: (m['count'] ?? 0).toDouble(),
    imagePath: (m['imagePath'] ?? '') as String,
  );
}
