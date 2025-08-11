import 'package:flutter/material.dart';
import 'package:smart_fridge_system/data/models/recipe_model.dart';
// ✅ 선택 결과로 돌려줄 타입
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  /// ✅ 추가: pickMode (기본 false)
  /// - false: 기존처럼 상세만 보기
  /// - true : 하단에 '서빙 수 + 추가' 바가 나타나고, 누르면 FoodItemn으로 pop
  final bool pickMode;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    this.pickMode = false,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  // ✅ 선택 모드일 때 사용할 서빙 수 (0.5 단위)
  double _serving = 1.0;

  // ✅ Recipe -> FoodItemn 변환 (서빙 수 반영)
  FoodItemn _toFoodItemn(Recipe r, double serving) {
    // 레시피의 kcal은 int일 수 있으니 double로 변환
    final kcal = (r.kcal.toDouble()) * serving;
    final carb = (r.carb) * serving;
    final prot = (r.protein) * serving;
    final fat  = (r.fat) * serving;

    return FoodItemn(
      name: r.title,
      calories: kcal,
      carbohydrates: carb,
      protein: prot,
      fat: fat,
      amount: 1,      // 레시피 1회분 기준 (SearchFoodScreen 목록엔 안나오므로 큰 영향 없음)
      count: serving, // 서빙 수
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    // ✅ 총 영양(서빙 반영) 표시값 (pickMode에서 하단 바에만 사용)
    final scaledKcal = recipe.kcal.toDouble() * _serving;
    final scaledCarb = recipe.carb * _serving;
    final scaledProt = recipe.protein * _serving;
    final scaledFat  = recipe.fat * _serving;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RecipeHeader(recipe: widget.recipe),
                    const SizedBox(height: 24),
                    _Ingredients(recipe: widget.recipe),
                    const SizedBox(height: 24),
                    _RecipeSteps(recipe: widget.recipe),
                    const SizedBox(height: 12),
                    if (widget.pickMode) ...[
                      // ✅ 선택 모드일 때, 현재 서빙 반영 총 영양 간단 요약(읽기 전용)
                      const Divider(height: 32),
                      _PickedSummary(
                        serving: _serving,
                        kcal: scaledKcal,
                        carb: scaledCarb,
                        protein: scaledProt,
                        fat: scaledFat,
                      ),
                      const SizedBox(height: 80), // 하단 고정 바와 겹치지 않도록 여백
                    ],
                  ],
                ),
              ),
            ),

            // ✅ 하단 고정 선택 바 (pickMode일 때만)
            if (widget.pickMode)
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF000000).withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 서빙 스테퍼
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD6E2C0)),
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFF9FBF5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Color(0xFF003508)),
                              onPressed: () {
                                setState(() {
                                  _serving = (_serving - 0.5).clamp(0.5, 99.0);
                                });
                              },
                              tooltip: '서빙 수 감소',
                            ),
                            Text(
                              _serving.toStringAsFixed(1),
                              style: const TextStyle(
                                fontFamily: 'Pretendard Variable',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF003508),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Color(0xFF003508)),
                              onPressed: () {
                                setState(() {
                                  _serving = (_serving + 0.5).clamp(0.5, 99.0);
                                });
                              },
                              tooltip: '서빙 수 증가',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 총 칼로리 미니표기
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '총 칼로리',
                              style: TextStyle(
                                fontFamily: 'Pretendard Variable',
                                fontSize: 12,
                                color: Color(0xFF7BAA7F),
                              ),
                            ),
                            Text(
                              '${scaledKcal.toStringAsFixed(0)} kcal',
                              style: const TextStyle(
                                fontFamily: 'Pretendard Variable',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Color(0xFF003508),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 추가 버튼
                      ElevatedButton(
                        onPressed: () {
                          final item = _toFoodItemn(recipe, _serving);
                          Navigator.pop(context, item); // ✅ 상위(RecipeMainPage → SearchFoodScreen)로 반환
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003508),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('이 레시피 추가'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ========================= WIDGETS ========================= */

class _TopBar extends StatelessWidget {
  final VoidCallback? onBack;
  const _TopBar({this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF003508)),
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            tooltip: '뒤로가기',
          ),
          const Text(
            '레시피',
            style: TextStyle(
              fontFamily: 'Pretendard Variable',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF003508),
            ),
          ),
          const Icon(Icons.notifications_none, color: Color(0xFF003508)),
        ],
      ),
    );
  }
}

class _RecipeHeader extends StatelessWidget {
  final Recipe recipe;
  const _RecipeHeader({required this.recipe});

  @override
  Widget build(BuildContext context) {
    // 안전 처리
    final double c = (recipe.carb).clamp(0, double.infinity);
    final double p = (recipe.protein).clamp(0, double.infinity);
    final double f = (recipe.fat).clamp(0, double.infinity);
    final double total = c + p + f;

    int flexC = 1, flexP = 1, flexF = 1;
    if (total > 0) {
      flexC = ((c / total) * 100).round().clamp(1, 100);
      flexP = ((p / total) * 100).round().clamp(1, 100);
      flexF = ((f / total) * 100).round().clamp(1, 100);
    }

    final imageWidget = recipe.imagePath.startsWith('http')
        ? Image.network(
      recipe.imagePath,
      width: 150,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _ph(),
    )
        : Image.asset(
      recipe.imagePath,
      width: 150,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _ph(),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.title,
                style: const TextStyle(
                  fontFamily: 'Pretendard Variable',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF003508),
                ),
              ),
              const SizedBox(height: 6),
              // 칼로리만 표시
              Row(
                children: [
                  const Icon(Icons.local_fire_department, size: 18, color: Color(0xFF003508)),
                  const SizedBox(width: 4),
                  Text(
                    '${recipe.kcal}kcal',
                    style: const TextStyle(color: Color(0xFF003508)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 탄단지 막대
              Container(
                height: 20,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                clipBehavior: Clip.hardEdge,
                child: Row(
                  children: [
                    Expanded(flex: flexC, child: Container(color: const Color(0xFFD0E7FF))),
                    Expanded(flex: flexP, child: Container(color: const Color(0xFFD6ECC9))),
                    Expanded(flex: flexF, child: Container(color: const Color(0xFFBFD9D2))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 탄단지 수치
              Column(
                children: const [
                  _NutrientItemRow(name: '탄수화물', color: Color(0xFFD0E7FF)),
                  _NutrientItemRow(name: '단백질', color: Color(0xFFD6ECC9)),
                  _NutrientItemRow(name: '지방', color: Color(0xFFBFD9D2)),
                ],
              ).withValues(c, p, f),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ph() => Container(
    width: 150,
    height: 200,
    color: const Color(0xFFEFEFEF),
    alignment: Alignment.center,
    child: const Icon(Icons.image_not_supported, color: Colors.grey),
  );
}

/* --- Nutrient rows (값 직접 전달용 헬퍼) --- */

class _NutrientItemRow extends StatelessWidget {
  final String name;
  final Color color;
  final double? value; // helper extension에서 주입

  const _NutrientItemRow({
    required this.name,
    required this.color,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final v = value ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Pretendard Variable',
              fontSize: 14,
              color: Color(0xFF003508),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${v.toStringAsFixed(1)}g',
            style: const TextStyle(
              fontFamily: 'Pretendard Variable',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF003508),
            ),
          ),
        ],
      ),
    );
  }
}

// Column(children: [const _NutrientItemRow(...), ...]).withValues(c,p,f)
extension _NutrientColumnValues on Widget {
  Widget withValues(double c, double p, double f) {
    if (this is! Column) return this;
    final col = this as Column;
    final kids = <Widget>[];
    for (var i = 0; i < col.children.length; i++) {
      final child = col.children[i];
      if (child is _NutrientItemRow) {
        final val = i == 0 ? c : (i == 1 ? p : f);
        kids.add(_NutrientItemRow(name: child.name, color: child.color, value: val));
      } else {
        kids.add(child);
      }
    }
    return Column(
      key: col.key,
      mainAxisAlignment: col.mainAxisAlignment,
      mainAxisSize: col.mainAxisSize,
      crossAxisAlignment: col.crossAxisAlignment,
      textDirection: col.textDirection,
      verticalDirection: col.verticalDirection,
      textBaseline: col.textBaseline,
      children: kids,
    );
  }
}

/* --- Ingredients --- */

class _Ingredients extends StatelessWidget {
  final Recipe recipe;
  const _Ingredients({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final hasIngredients = recipe.ingredients.isNotEmpty;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD6E2C0), width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD6E2C0)),
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: const Text(
              '재료',
              style: TextStyle(
                fontFamily: 'Pretendard Variable',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF003508),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!hasIngredients)
            const Text('재료 정보가 없습니다.', style: TextStyle(color: Colors.grey))
          else
            Wrap(
              spacing: 40,
              runSpacing: 16,
              children: recipe.ingredients.entries.map((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Pretendard Variable',
                        color: Color(0xFF003508),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      e.value ? Icons.check : Icons.clear,
                      size: 20,
                      color: e.value ? const Color(0xFFC7DDB3) : const Color(0xFFFF8C7C),
                    ),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

/* --- Steps --- */

class _RecipeSteps extends StatelessWidget {
  final Recipe recipe;
  const _RecipeSteps({required this.recipe});

  // 텍스트 앞의 번호/기호 제거 (예: "1. ", "2) ", "③ " 등)
  String _stripLeadingNumber(String s) {
    final t = s.trimLeft();
    final regex = RegExp(r'^(?:\d+|[①-⑳])\s*[\.\)\-:>]*\s*');
    return t.replaceFirst(regex, '');
  }

  @override
  Widget build(BuildContext context) {
    final hasSteps = recipe.steps.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD6E2C0)),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: const Text(
            '조리순서',
            style: TextStyle(
              fontFamily: 'Pretendard Variable',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF003508),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!hasSteps)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD6E2C0)),
            ),
            child: const Text('조리 단계 정보가 없습니다.', style: TextStyle(color: Colors.grey)),
          )
        else
          Column(
            children: recipe.steps.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final step = _stripLeadingNumber(entry.value);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFBFD9D2)),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$idx',
                        style: const TextStyle(
                          color: Color(0xFF003508),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(
                          fontFamily: 'Pretendard Variable',
                          fontSize: 15,
                          color: Color(0xFF003508),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

/* --- 선택 모드 서머리 (하단 바 위에 간단 표시) --- */

class _PickedSummary extends StatelessWidget {
  final double serving;
  final double kcal;
  final double carb;
  final double protein;
  final double fat;

  const _PickedSummary({
    required this.serving,
    required this.kcal,
    required this.carb,
    required this.protein,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF5),
        border: Border.all(color: const Color(0xFFD6E2C0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _kv('서빙 수', '${serving.toStringAsFixed(1)}'),
          ),
          Expanded(
            child: _kv('총 칼로리', '${kcal.toStringAsFixed(0)} kcal'),
          ),
          Expanded(
            child: _kv('탄/단/지',
                '${carb.toStringAsFixed(1)}/${protein.toStringAsFixed(1)}/${fat.toStringAsFixed(1)} g'),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          k,
          style: const TextStyle(
            fontFamily: 'Pretendard Variable',
            fontSize: 12,
            color: Color(0xFF7BAA7F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          v,
          style: const TextStyle(
            fontFamily: 'Pretendard Variable',
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Color(0xFF003508),
          ),
        ),
      ],
    );
  }
}
