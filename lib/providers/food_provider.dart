// lib/providers/food_provider.dart
import 'package:flutter/material.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';
import 'package:smart_fridge_system/data/repositories/food_repository.dart';

class FoodProvider with ChangeNotifier {
  final FoodRepository _foodRepository = FoodRepository();

  List<FoodItem> _foodItems = [];
  bool _isLoading = false;
  String? _error;

  // ---------- 기존 공개 프로퍼티 ----------
  List<FoodItem> get foodItems => _foodItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ---------- ✅ 레시피/검색용: 보유 재료 이름 ----------
  /// 예: ['사과', '계란', '두부']
  List<String> get fridgeNames => _foodItems
      .map((e) => e.name.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);

  /// (선택) 매칭 정밀도 향상을 위한 정규화 이름 Set
  /// '청양고추(국산)' -> '청양고추' -> '청양고추' 소문자/기호 제거
  Set<String> get fridgeNamesNormalized => fridgeNames
      .map(_norm)
      .where((s) => s.isNotEmpty)
      .toSet();

  String _norm(String s) {
    final noParen = s.replaceAll(RegExp(r'\([^)]*\)'), '');
    return noParen.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\uac00-\ud7a3]'), '');
  }

  // ---------- CRUD ----------
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
    await fetchFoodItems();
  }

  Future<void> updateFoodItem(FoodItem item) async {
    await _foodRepository.updateFoodItem(item);
    await fetchFoodItems();
  }

  Future<void> deleteFoodItem(FoodItem item) async {
    await _foodRepository.deleteFoodItem(item);
    await fetchFoodItems();
  }
}
