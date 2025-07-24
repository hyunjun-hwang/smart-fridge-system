// lib/data/models/food_item.dart

// 음식 카테고리
enum FoodCategory {
  fruit('과일'),
  meat('고기'),
  vegetable('채소'),
  dairy('유제품');

  const FoodCategory(this.displayName);
  final String displayName;
}

// 보관 위치
enum StorageType {
  fridge('냉장실'),
  freezer('냉동고');

  const StorageType(this.displayName);
  final String displayName;
}

// 수량 단위
enum Unit {
  count('개'),
  grams('g');

  const Unit(this.displayName);
  final String displayName;
}

// --- FoodItem 클래스 ---
class FoodItem {
  final String name;       // 이름
  final String imageUrl;   // 사진 URL
  final int quantity;      // 수량
  final Unit unit;         // 단위
  final DateTime expiryDate; // 유통기한
  final DateTime stockedDate;// 입고일
  final StorageType storage;// 위치
  final String category;     // 카테고리

  FoodItem({
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    required this.stockedDate,
    required this.storage,
    required this.category,
  });

  // dDay는 저장하는 대신, 유통기한을 통해 실시간으로 계산
  int get dDay {
    // 오늘 날짜의 자정(0시 0분)을 기준으로 계산해야 날짜가 바뀌어도 정확합니다.
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final expiryDateOnly = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    final difference = expiryDateOnly.difference(todayDate).inDays;
    return difference < 0 ? 0 : difference; // D-0부터 시작 (유통기한 당일)
  }
}