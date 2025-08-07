// lib/data/repositories/food_repository.dart

import 'package:hive/hive.dart';
import '../models/food_item.dart'; // FoodItem 모델의 위치
import 'package:uuid/uuid.dart'; // 고유 ID 생성을 위해 uuid 패키지가 필요합니다.

class FoodRepository {
  // Hive Box의 이름을 상수로 정의합니다.
  static const String _boxName = 'food_items';

  // 고유 ID 생성을 위한 Uuid 인스턴스
  final _uuid = const Uuid();

  // 데이터베이스에서 모든 음식 목록을 가져옵니다.
  Future<List<FoodItem>> getFoodItems() async {
    // 'food_items' 이름의 Box(데이터 저장소)를 엽니다.
    final box = await Hive.openBox<FoodItem>(_boxName);
    // Box에 저장된 모든 값을 리스트로 변환하여 반환합니다.
    return box.values.toList();
  }

  // 새로운 음식을 데이터베이스에 추가합니다.
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
    final box = await Hive.openBox<FoodItem>(_boxName);

    // 고유 ID를 생성합니다.
    final String id = _uuid.v4();

    // 새로운 FoodItem 객체를 생성합니다.
    final newItem = FoodItem(
      id: id,
      name: name,
      imageUrl: imageUrl,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate,
      stockedDate: stockedDate,
      storage: storage,
      category: category,
    );

    // Box에 id를 key로, newItem을 value로 저장합니다.
    await box.put(id, newItem);
  }

  // 기존 음식을 데이터베이스에서 수정합니다.
  // FoodItem이 HiveObject를 상속받았으므로, 객체를 수정한 뒤 save() 메소드만 호출하면 됩니다.
  Future<void> updateFoodItem(FoodItem item) async {
    // ⭐️ item.save() 대신 box.put()을 사용하여 데이터를 덮어씁니다.
    final box = await Hive.openBox<FoodItem>(_boxName);
    await box.put(item.id, item);
  }

  // 음식을 데이터베이스에서 삭제합니다.
  Future<void> deleteFoodItem(FoodItem item) async {
    // item.delete() 역시 HiveObject에 내장된 메소드입니다.
    await item.delete();
  }
}