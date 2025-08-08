// providers/ndata/foodn_item.dart
class FoodItemn {
  final String name;          // 음식 이름 (예: 사과/김밥 등)
  final double calories;      // kcal
  final double carbohydrates; // g
  final double protein;       // g
  final double fat;           // g
  final double amount;        // 1회 제공량(g) - 기본 100g
  final double count;         // 먹은 개수 (0.5 단위 가능)

  FoodItemn({
    required this.name,
    required this.calories,
    required this.carbohydrates,
    required this.protein,
    required this.fat,
    required this.amount,
    required this.count,
  });

  // 문자열/숫자 혼용 대응
  static double _num(dynamic v) => double.tryParse('${v ?? '0'}') ?? 0.0;

  /// ✅ JSON → 객체 (API 응답 받을 때)
  /// - 신 스키마: AMT_NUM1(열량), AMT_NUM6(탄), AMT_NUM3(단), AMT_NUM4(지), SERVING_SIZE("100g")
  /// - 구 스키마: NUTR_CONT1~4 (열/탄/단/지), 1회 제공량 정보 없으면 100g
  factory FoodItemn.fromApiJson(Map<String, dynamic> json) {
    // 이름키 우선순위: FOOD_NM_KR > DESC_KOR > FOOD_NAME
    final String name =
    (json['FOOD_NM_KR'] ?? json['DESC_KOR'] ?? json['FOOD_NAME'] ?? '이름 없음').toString();

    // 어떤 스키마인지 감지
    final bool isAmtSchema = json.containsKey('AMT_NUM1') || json.containsKey('SERVING_SIZE');

    final double calories = isAmtSchema ? _num(json['AMT_NUM1']) : _num(json['NUTR_CONT1']);
    final double carbs    = isAmtSchema ? _num(json['AMT_NUM6']) : _num(json['NUTR_CONT2']);
    final double protein  = isAmtSchema ? _num(json['AMT_NUM3']) : _num(json['NUTR_CONT3']);
    final double fat      = isAmtSchema ? _num(json['AMT_NUM4']) : _num(json['NUTR_CONT4']);

    // SERVING_SIZE 예: "100g" → 100
    double amount = 100;
    final ss = json['SERVING_SIZE']?.toString();
    if (ss != null) {
      final m = RegExp(r'([\d.]+)').firstMatch(ss);
      if (m != null) amount = double.tryParse(m.group(1)!) ?? 100;
    }

    return FoodItemn(
      name: name.isEmpty ? '이름 없음' : name,
      calories: calories,
      carbohydrates: carbs,
      protein: protein,
      fat: fat,
      amount: amount,
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
  String toString() => 'FoodItemn(name: $name, count: $count, cal: $calories)';
}
