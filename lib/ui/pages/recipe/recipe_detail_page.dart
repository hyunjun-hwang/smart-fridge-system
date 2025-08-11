import 'package:flutter/material.dart';
import 'package:smart_fridge_system/data/models/recipe_model.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  @override
  Widget build(BuildContext context) {
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
              // ✅ 조리시간 제거, 칼로리만 표시
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
              final step = entry.value;
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
