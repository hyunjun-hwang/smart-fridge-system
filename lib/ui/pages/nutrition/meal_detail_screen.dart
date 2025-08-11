import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/record_entry_screen.dart';
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';

class MealDetailScreen extends StatelessWidget {
  final String mealType;
  final DateTime date;

  const MealDetailScreen({super.key, required this.mealType, required this.date});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DailyNutritionProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD5E8C6),
        elevation: 0,
        leading: const BackButton(color: Colors.green),
        title: Text(
          provider.getFormattedDate(date),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        centerTitle: true,
      ),
      body: Consumer<DailyNutritionProvider>(
        builder: (context, provider, _) {
          final foods = provider.getFoodsByMeal(mealType, date);
          final nutrition = provider.getMealNutrition(mealType, date);
          final targetCal = provider.targetCalories;
          final totalCal = nutrition['calories'] ?? 0;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('총 섭취 칼로리', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${totalCal.toStringAsFixed(0)}kcal',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${targetCal.toStringAsFixed(0)}kcal',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMacroBar('탄수화물', nutrition['carbohydrates'] ?? 0, Colors.blue[100]!),
                    _buildMacroBar('단백질', nutrition['protein'] ?? 0, Colors.purple[100]!),
                    _buildMacroBar('지방', nutrition['fat'] ?? 0, Colors.green[100]!),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];

                    return StatefulBuilder(
                      builder: (context, setState) {
                        double count = provider
                            .getFoodsByMeal(mealType, date)
                            .firstWhere((f) => f.name == food.name)
                            .count;

                        void update(double delta) {
                          count = (count + delta).clamp(0.0, 99.0);

                          if (count == 0) {
                            provider.removeFoodItem(mealType, date, food.name);
                          } else {
                            provider.updateFood(mealType, date, food.copyWith(count: count));
                          }

                          setState(() {});
                        }

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => showFoodInfoDialog(context, food, count),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  // ✅ imagePath 제거 → 기본 아이콘으로 대체
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.fastfood, size: 30, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(
                                          '1개(${food.amount}g) ${food.calories}kcal',
                                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _circleBtn(Icons.remove, () => update(-0.5)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          '${count.toStringAsFixed(1)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      _circleBtn(Icons.add, () => update(0.5)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD5E8C6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecordEntryScreen(mealType: mealType, date: date),
                      ),
                    );
                  },
                  child: const Text('음식 추가', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Icon(icon, size: 24, color: Colors.green.shade800),
        padding: const EdgeInsets.all(4),
      ),
    );
  }

  Widget _buildMacroBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 13))),
          Expanded(
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              color: color,
              backgroundColor: Colors.grey[200],
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          Text('${value.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // ✅ 상세 영양정보 다이얼로그 (현재 개수 반영 + 1개 기준 같이 표시)
  void showFoodInfoDialog(BuildContext context, FoodItemn food, double count) {
    final totalCal = food.calories * count;
    final totalCarb = food.carbohydrates * count;
    final totalProt = food.protein * count;
    final totalFat  = food.fat * count;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(food.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _kv('1개 기준(≈${food.amount}g)', ''),
            const SizedBox(height: 4),
            _kv('칼로리', '${food.calories.toStringAsFixed(1)} kcal'),
            _kv('탄수화물', '${food.carbohydrates.toStringAsFixed(1)} g'),
            _kv('단백질', '${food.protein.toStringAsFixed(1)} g'),
            _kv('지방', '${food.fat.toStringAsFixed(1)} g'),
            const Divider(height: 24),
            _kv('현재 수량', '${count.toStringAsFixed(1)} 개'),
            const SizedBox(height: 4),
            _kv('총 칼로리', '${totalCal.toStringAsFixed(1)} kcal'),
            _kv('총 탄수화물', '${totalCarb.toStringAsFixed(1)} g'),
            _kv('총 단백질', '${totalProt.toStringAsFixed(1)} g'),
            _kv('총 지방', '${totalFat.toStringAsFixed(1)} g'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD5E8C6),
                  foregroundColor: const Color(0xFF003508),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('닫기', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: Colors.black54)),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
