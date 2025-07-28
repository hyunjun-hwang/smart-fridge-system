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
        leading: BackButton(color: Colors.green),
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

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  food.imagePath,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported, size: 50),
                                ),
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
}
