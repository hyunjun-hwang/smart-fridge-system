class FoodItem {
  final String name;            // 음식 이름 (예: 사과)
  final int calories;           // 1개당 칼로리
  final double carbohydrates;   // 탄수화물 (g)
  final double protein;         // 단백질 (g)
  final double fat;             // 지방 (g)
  final double amount;          // 1개 기준 무게 (g)
  final double count;           // 먹은 개수 (0.5 단위 가능)
  final String imagePath;       // 이미지 경로 (asset path 또는 URL)

  FoodItem({
    required this.name,
    required this.calories,
    required this.carbohydrates,
    required this.protein,
    required this.fat,
    required this.amount,
    required this.count,
    required this.imagePath,
  });

  /// ✅ JSON → 객체 (API 응답 받을 때)
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      calories: json['calories'],
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      count: (json['count'] as num).toDouble(),
      imagePath: json['imagePath'],
    );
  }

  /// ✅ 객체 → JSON (서버에 보낼 때)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'carbohydrates': carbohydrates,
      'protein': protein,
      'fat': fat,
      'amount': amount,
      'count': count,
      'imagePath': imagePath,
    };
  }

  /// ✅ 일부 속성만 변경해서 새 객체 만들기
  FoodItem copyWith({
    String? name,
    int? calories,
    double? carbohydrates,
    double? protein,
    double? fat,
    double? amount,
    double? count,
    String? imagePath,
  }) {
    return FoodItem(
      name: name ?? this.name,
      calories: calories ?? this.calories,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      amount: amount ?? this.amount,
      count: count ?? this.count,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  String toString() {
    return 'FoodItem(name: $name, count: $count, cal: $calories)';
  }
}
