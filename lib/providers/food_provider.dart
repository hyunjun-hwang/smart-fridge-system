// lib/providers/food_provider.dart

import 'package:flutter/material.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';
import 'package:smart_fridge_system/data/repositories/food_repository.dart';

class FoodProvider with ChangeNotifier {
  final FoodRepository _foodRepository = FoodRepository();

  List<FoodItem> _foodItems = [];
  bool _isLoading = false;
  String? _error;

  List<FoodItem> get foodItems => _foodItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFoodItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _foodItems = await _foodRepository.getFoodItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFoodItem({
    required String name,
    required String imageUrl,
    required int quantity,
    required Unit unit,
    required DateTime expiryDate,
    required DateTime stockedDate,
    required StorageType storage,
    required FoodCategory category,
  }) async {
    await _foodRepository.addFoodItem(
      name: name,
      imageUrl: imageUrl,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate,
      stockedDate: stockedDate,
      storage: storage,
      category: category,
    );
    // 데이터 추가 후 목록을 다시 불러옵니다.
    await fetchFoodItems();
  }

  Future<void> updateFoodItem(FoodItem item) async {
    await _foodRepository.updateFoodItem(item);
    // 데이터 수정 후 목록을 다시 불러옵니다.
    await fetchFoodItems();
  }

  Future<void> deleteFoodItem(FoodItem item) async {
    await _foodRepository.deleteFoodItem(item);
    // 데이터 삭제 후 목록을 다시 불러옵니다.
    await fetchFoodItems();
  }
}