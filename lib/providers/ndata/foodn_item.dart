// FILE: providers/ndata/foodn_item.dart
// 목적: 외부 API 응답(식품안전나라 등)을 "항상 1회 제공량 기준"으로 매핑
// - 신 스키마(AMT_NUM*): 이미 1회 제공량당 값 → 그대로 사용
// - 구 스키마(NUTR_CONT*): 대부분 100g 기준 → 1회 제공량(g)으로 환산
// - 1회 제공량(g)은 SERVING_WT / SERVING_SIZE / SERVING_UNIT 등에서 최대한 추출
// - SERVING_SIZE가 ml만 있을 땐 1ml ≈ 1g 가정(밀도 정보 없을 때 폴백)

class FoodItemn {
  final String name;          // 음식 이름
  final double calories;      // kcal  (✔ 1회 제공량 기준)
  final double carbohydrates; // g     (✔ 1회 제공량 기준)
  final double protein;       // g     (✔ 1회 제공량 기준)
  final double fat;           // g     (✔ 1회 제공량 기준)
  final double amount;        // 1회 제공량(g)
  final double count;         // 섭취 회수(0.5 단위 가능)
  final String imagePath;     // 이미지 경로/URL (없으면 '')

  FoodItemn({
    required this.name,
    required this.calories,
    required this.carbohydrates,
    required this.protein,
    required this.fat,
    required this.amount,
    required this.count,
    this.imagePath = '',
  });

  // 문자열/숫자 혼용 대응
  static double _num(dynamic v) => double.tryParse('${v ?? '0'}') ?? 0.0;

  /// 자유형 제공량 문자열에서 g 단위 무게를 추출
  /// 우선순위:
  /// 1) SERVING_WT(명확한 g) > 2) SERVING_SIZE(자유 텍스트: "1회(30 g)", "200ml" 등)
  /// > 3) SERVING_UNIT(자유 텍스트: "개(30g)" 등) > 4) 100g 폴백
  static double _parseServingGrams(Map<String, dynamic> json) {
    // 1) 명시적 무게 필드
    final wt = json['SERVING_WT'] ?? json['SERVING_WEIGHT'] ?? json['SERVING_SIZE_WT'];
    final wtVal = _num(wt);
    if (wtVal > 0) return wtVal;

    // 2) 자유 텍스트형 SERVING_SIZE
    final ss = json['SERVING_SIZE']?.toString();
    if (ss != null && ss.trim().isNotEmpty) {
      final m = RegExp(r'([\d.]+)\s*(g|그램|ml|밀리리터)?', caseSensitive: false)
          .firstMatch(ss.replaceAll(',', '.'));
      if (m != null) {
        final val = double.tryParse(m.group(1) ?? '') ?? 0.0;
        final unit = (m.group(2) ?? '').toLowerCase();
        if (val > 0) {
          if (unit.contains('ml') || unit.contains('밀리리터')) {
            return val; // 1ml ≈ 1g 가정
          }
          return val;   // g/그램
        }
      }
    }

    // 3) 단위 텍스트에 g/ml 힌트가 있는 경우
    final unitText = json['SERVING_UNIT']?.toString();
    if (unitText != null && unitText.trim().isNotEmpty) {
      final m = RegExp(r'([\d.]+)\s*(g|그램|ml|밀리리터)', caseSensitive: false)
          .firstMatch(unitText.replaceAll(',', '.'));
      if (m != null) {
        final val = double.tryParse(m.group(1) ?? '') ?? 0.0;
        final unit = (m.group(2) ?? '').toLowerCase();
        if (val > 0) {
          if (unit.contains('ml') || unit.contains('밀리리터')) {
            return val; // 1ml ≈ 1g 가정
          }
          return val; // g/그램
        }
      }
    }

    // 4) 폴백
    return 100.0;
  }

  /// ✅ JSON → 객체 (API 응답 받을 때)
  /// - 신 스키마: AMT_NUM1(열량), AMT_NUM6(탄), AMT_NUM3(단), AMT_NUM4(지)  => "1회 제공량당"
  /// - 구 스키마: NUTR_CONT1~4  => "100g 기준" → 1회 제공량(g)으로 환산
  factory FoodItemn.fromApiJson(Map<String, dynamic> json) {
    // 이름 우선순위
    final String name = (json['FOOD_NM_KR'] ??
        json['DESC_KOR'] ??
        json['FOOD_NAME'] ??
        json['DESC'] ??
        '이름 없음')
        .toString();

    // 1회 제공량(g)
    final double servingG = _parseServingGrams(json);

    // 스키마 판단: SERVING_SIZE 유무가 아니라 AMT_NUM 키 존재로만 판단!
    final bool hasAmt = json.containsKey('AMT_NUM1') ||
        json.containsKey('AMT_NUM3') ||
        json.containsKey('AMT_NUM4') ||
        json.containsKey('AMT_NUM6');

    double calories, carbs, protein, fat;

    if (hasAmt) {
      // ✅ 신 스키마: 이미 1회 제공량 기준
      calories = _num(json['AMT_NUM1']); // kcal / serving
      carbs    = _num(json['AMT_NUM6']); // g / serving
      protein  = _num(json['AMT_NUM3']); // g / serving
      fat      = _num(json['AMT_NUM4']); // g / serving
    } else {
      // ✅ 구 스키마: 100g 기준 → 1회 제공량(g)으로 환산
      final per100Cal = _num(json['NUTR_CONT1']); // kcal / 100g
      final per100Car = _num(json['NUTR_CONT2']); // g / 100g
      final per100Pro = _num(json['NUTR_CONT3']); // g / 100g
      final per100Fat = _num(json['NUTR_CONT4']); // g / 100g

      final ratio = (servingG > 0 ? servingG / 100.0 : 1.0);
      calories = per100Cal * ratio;
      carbs    = per100Car * ratio;
      protein  = per100Pro * ratio;
      fat      = per100Fat * ratio;
    }

    // 이미지 경로(키 다양성 고려)
    final String imagePath = (json['IMAGE_URL'] ??
        json['IMG_URL'] ??
        json['ATT_FILE_URL'] ??
        json['FILE_URL'] ??
        '')
        .toString();

    return FoodItemn(
      name: name.isEmpty ? '이름 없음' : name,
      calories: calories,
      carbohydrates: carbs,
      protein: protein,
      fat: fat,
      amount: servingG, // ✔ 항상 1회 제공량(g)
      count: 1.0,
      imagePath: imagePath,
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
      imagePath: (json['imagePath'] ?? '').toString(),
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
      'amount': amount,   // ✔ 1회 제공량(g)
      'count': count,     // ✔ "회" 수량
      'imagePath': imagePath,
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
    String? imagePath,
  }) {
    return FoodItemn(
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
  String toString() =>
      'FoodItemn(name: $name, amount(g): $amount, count: $count, kcal/serv: $calories, img: $imagePath)';
}
