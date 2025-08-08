class FoodItemn {
  final String name; // 음식 이름 (예: 사과)
  final double calories; // 1개당 칼로리
  final double carbohydrates; // 탄수화물 (g)
  final double protein; // 단백질 (g)
  final double fat; // 지방 (g)
  final double amount; // 1개 기준 무게 (g)
  final double count; // 먹은 개수 (0.5 단위 가능)

  FoodItemn({
    required this.name,
    required this.calories,
    required this.carbohydrates,
    required this.protein,
    required this.fat,
    required this.amount,
    required this.count,
  });

  /// ✅ JSON → 객체 (API 응답 받을 때)
  factory FoodItemn.fromApiJson(Map<String, dynamic> json) {
    return FoodItemn(
      name: json['DESC_KOR'] ?? '이름 없음',
      calories: double.tryParse(json['NUTR_CONT1'] ?? '0') ?? 0,
      carbohydrates: double.tryParse(json['NUTR_CONT2'] ?? '0') ?? 0,
      protein: double.tryParse(json['NUTR_CONT3'] ?? '0') ?? 0,
      fat: double.tryParse(json['NUTR_CONT4'] ?? '0') ?? 0,
      amount: 100,
      count: 1.0,
    );
  }

  /// ✅ 일반 JSON → 객체 (내 저장용)
  factory FoodItemn.fromJson(Map<String, dynamic> json) {
    return FoodItemn(
      name: json['name'],
      calories: (json['calories'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      count: (json['count'] as num).toDouble(),
    );
  }

  /// ✅ 객체 → JSON (저장용)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'carbohydrates': carbohydrates,
      'protein': protein,
      'fat': fat,
      'amount': amount,
      'count': count,
    };
  }

  /// ✅ 일부 속성만 변경해서 새 객체 만들기
  FoodItemn copyWith({
    String? name,
    double? calories,
    double? carbohydrates,
    double? protein,
    double? fat,
    double? amount,
    double? count,
  }) {
    return FoodItemn(
      name: name ?? this.name,
      calories: calories ?? this.calories,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      amount: amount ?? this.amount,
      count: count ?? this.count,
    );
  }

  @override
  String toString() {
    return 'FoodItemn(name: $name, count: $count, cal: $calories)';
  }
}
