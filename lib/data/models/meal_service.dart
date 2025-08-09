import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_fridge_system/data/models/recipe_model.dart';

class MealService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 1) 범용: 필드로 직접 추가
  Future<void> addMeal({
    required String uid,            // users/{uid}
    required String slot,           // breakfast | lunch | dinner | snack_morning ...
    required String recipeId,
    required String recipeName,
    required double kcal,
    double? carb,
    double? protein,
    double? fat,
    String? imagePath,
    DateTime? when,                 // 없으면 now
  }) async {
    final now = when ?? DateTime.now();

    await _db
        .collection('users')
        .doc(uid)
        .collection('meals')
        .add({
      'slot': slot,
      'recipeId': recipeId,
      'recipeName': recipeName,
      'kcal': kcal,
      if (carb != null) 'carb': carb,
      if (protein != null) 'protein': protein,
      if (fat != null) 'fat': fat,
      if (imagePath != null) 'imagePath': imagePath,
      'createdAt': FieldValue.serverTimestamp(),
      'date': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
    });
  }

  /// 2) 편의: Recipe 객체 그대로 받아 추가
  Future<void> addMealFromRecipe({
    required String uid,
    required String slot,
    required Recipe recipe,
    DateTime? when,
  }) {
    return addMeal(
      uid: uid,
      slot: slot,
      recipeId: recipe.title,                 // 고유 id 없으면 title 사용
      recipeName: recipe.title,
      kcal: recipe.kcal.toDouble(),
      carb: recipe.carb.toDouble(),
      protein: recipe.protein.toDouble(),
      fat: recipe.fat.toDouble(),
      imagePath: recipe.imagePath,
      when: when,
    );
  }

  /// (옵션) 하루치 조회 스트림
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMealsOfDay({
    required String uid,
    required DateTime day,
  }) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _db
        .collection('users')
        .doc(uid)
        .collection('meals')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots();
  }
}
