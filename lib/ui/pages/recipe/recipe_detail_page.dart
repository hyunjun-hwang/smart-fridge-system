import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_fridge_system/data/models/recipe_model.dart';
import 'package:smart_fridge_system/data/models/meal_service.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  String _selectedMeal = '아침';
  final _mealService = MealService();

  int _flexFromDouble(double v) {
    final r = (v * 10).round();
    if (r < 1) return 1;
    if (r > 1000) return 1000;
    return r;
  }

  String _mapMealLabelToSlot(String label) {
    switch (label) {
      case '아침':
        return 'breakfast';
      case '점심':
        return 'lunch';
      case '저녁':
        return 'dinner';
      case '아침 간식':
        return 'snack_morning';
      case '점심 간식':
        return 'snack_afternoon';
      case '저녁 간식':
        return 'snack_evening';
      default:
        return 'etc';
    }
  }

  Future<void> _handleAddPressed() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        String temp = _selectedMeal;
        const meals = [
          {'label': '아침', 'kcal': '0kcal'},
          {'label': '점심', 'kcal': '0kcal'},
          {'label': '저녁', 'kcal': '0kcal'},
          {'label': '아침 간식', 'kcal': '0kcal'},
          {'label': '점심 간식', 'kcal': '0kcal'},
          {'label': '저녁 간식', 'kcal': '0kcal'},
        ];

        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20.0,
                20.0,
                20.0,
                MediaQuery.of(context).viewInsets.bottom + 20.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '식단 추가',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF003508),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Wrap(
                    spacing: 20.0,
                    runSpacing: 16.0,
                    alignment: WrapAlignment.center,
                    children: meals.map((meal) {
                      final label = meal['label']!;
                      final kcal = meal['kcal']!;
                      final isSelected = temp == label;
                      return GestureDetector(
                        onTap: () => setModal(() => temp = label),
                        child: Container(
                          width: 96.0,
                          height: 72.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F8F0),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF003508)
                                  : const Color(0xFFD6E2C0),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF003508),
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                kcal,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14.0,
                                  color: isSelected
                                      ? const Color(0xFF003508)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, temp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6E2C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: const Text(
                        '추가하기',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF003508),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final slot = _mapMealLabelToSlot(selected);

    // 🔁 여기 수정: addMealFromRecipe → addMeal
    await _mealService.addMeal(
      uid: uid,
      slot: slot,
      recipeId: widget.recipe.title, // id 없으면 제목을 임시 id로
      recipeName: widget.recipe.title,
      kcal: widget.recipe.kcal.toDouble(),
    );

    if (!mounted) return;
    setState(() => _selectedMeal = selected);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('[$selected]에 추가되었습니다!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RecipeHeader(
                      recipe: widget.recipe,
                      flexFromDouble: _flexFromDouble,
                    ),
                    const SizedBox(height: 24.0),
                    _Ingredients(recipe: widget.recipe),
                    const SizedBox(height: 24.0),
                    _RecipeSteps(recipe: widget.recipe),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
        child: SizedBox(
          height: 50.0,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleAddPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003508),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text(
              '추가하기',
              style: TextStyle(
                fontFamily: 'Pretendard Variable',
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Icon(Icons.arrow_back, color: Color(0xFF003508)),
          Text(
            '레시피',
            style: TextStyle(
              fontFamily: 'Pretendard Variable',
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
              color: Color(0xFF003508),
            ),
          ),
          Icon(Icons.notifications_none, color: Color(0xFF003508)),
        ],
      ),
    );
  }
}

class _RecipeHeader extends StatelessWidget {
  final Recipe recipe;
  final int Function(double) flexFromDouble;
  const _RecipeHeader({required this.recipe, required this.flexFromDouble});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.asset(
            recipe.imagePath,
            width: 150.0,
            height: 200.0,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 20.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.title,
                style: const TextStyle(
                  fontFamily: 'Pretendard Variable',
                  fontWeight: FontWeight.w700,
                  fontSize: 20.0,
                  color: Color(0xFF003508),
                ),
              ),
              const SizedBox(height: 6.0),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18.0, color: Color(0xFF003508)),
                  const SizedBox(width: 4.0),
                  Text(
                    '${recipe.time}분',
                    style: const TextStyle(color: Color(0xFF003508)),
                  ),
                  const SizedBox(width: 12.0),
                  const Icon(Icons.local_fire_department, size: 18.0, color: Color(0xFF003508)),
                  const SizedBox(width: 4.0),
                  Text(
                    '${recipe.kcal.toStringAsFixed(0)}kcal',
                    style: const TextStyle(color: Color(0xFF003508)),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Container(
                height: 20.0,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0)),
                clipBehavior: Clip.hardEdge,
                child: Row(
                  children: [
                    Expanded(
                      flex: flexFromDouble(recipe.carb),
                      child: Container(color: const Color(0xFFD0E7FF)),
                    ),
                    Expanded(
                      flex: flexFromDouble(recipe.protein),
                      child: Container(color: const Color(0xFFD6ECC9)),
                    ),
                    Expanded(
                      flex: flexFromDouble(recipe.fat),
                      child: Container(color: const Color(0xFFBFD9D2)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              _NutrientRow(recipe: recipe),
            ],
          ),
        ),
      ],
    );
  }
}

class _NutrientRow extends StatelessWidget {
  final Recipe recipe;
  const _NutrientRow({required this.recipe});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NutrientItem('탄수화물', '${recipe.carb}g', const Color(0xFFD0E7FF)),
        _NutrientItem('단백질', '${recipe.protein}g', const Color(0xFFD6ECC9)),
        _NutrientItem('지방', '${recipe.fat}g', const Color(0xFFBFD9D2)),
      ],
    );
  }
}

class _NutrientItem extends StatelessWidget {
  final String name;
  final String value;
  final Color color;
  const _NutrientItem(this.name, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          CircleAvatar(radius: 5.0, backgroundColor: color),
          const SizedBox(width: 6.0),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Pretendard Variable',
              fontSize: 14.0,
              color: Color(0xFF003508),
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard Variable',
              fontWeight: FontWeight.w700,
              fontSize: 14.0,
              color: Color(0xFF003508),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ingredients extends StatelessWidget {
  final Recipe recipe;
  const _Ingredients({required this.recipe});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD6E2C0), width: 1.2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      margin: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD6E2C0)),
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
            ),
            child: const Text(
              '재료',
              style: TextStyle(
                fontFamily: 'Pretendard Variable',
                fontWeight: FontWeight.w700,
                fontSize: 16.0,
                color: Color(0xFF003508),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 40.0,
            runSpacing: 16.0,
            children: recipe.ingredients.entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    e.key,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontFamily: 'Pretendard Variable',
                      color: Color(0xFF003508),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Icon(
                    e.value ? Icons.check : Icons.clear,
                    size: 20.0,
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

class _RecipeSteps extends StatelessWidget {
  final Recipe recipe;
  const _RecipeSteps({required this.recipe});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD6E2C0)),
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
            ),
            child: const Text(
              '조리순서',
              style: TextStyle(
                fontFamily: 'Pretendard Variable',
                fontWeight: FontWeight.w700,
                fontSize: 16.0,
                color: Color(0xFF003508),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Column(
            children: recipe.steps.asMap().entries.map((entry) {
              final idx = entry.key;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26.0,
                      height: 26.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFBFD9D2)),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${idx + 1}',
                        style: const TextStyle(
                          color: Color(0xFF003508),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(
                          fontFamily: 'Pretendard Variable',
                          fontSize: 15.0,
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
      ),
    );
  }
}
