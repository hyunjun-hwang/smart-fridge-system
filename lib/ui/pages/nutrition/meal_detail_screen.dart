import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/record_entry_screen.dart';

class MealDetailScreen extends StatelessWidget {
  final String mealType;
  final DateTime date;

  const MealDetailScreen({super.key, required this.mealType, required this.date});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DailyNutritionProvider>(context);
    final nutrition = provider.getMealNutrition(mealType, date);
    final foods = provider.getFoodsByMeal(mealType, date);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.green),
        title: Text(
          provider.getFormattedDate(date),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildMacroBar("탄수화물", nutrition['carbohydrates'] ?? 0, Colors.blue[100]!),
                _buildMacroBar("단백질", nutrition['protein'] ?? 0, Colors.purple[100]!),
                _buildMacroBar("지방", nutrition['fat'] ?? 0, Colors.green[100]!),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final food = foods[index];
                return ListTile(
                  leading: const Image(image: AssetImage('assets/apple.png'), width: 40),
                  title: Text(food['name']),
                  subtitle: Text('${food['amount']}g ${food['calories']}kcal'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('x${food['count']}'),
                      const SizedBox(width: 4),
                      const Icon(Icons.more_vert, size: 18),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB4D9A6),
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
                child: const Text('음식 추가'),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMacroBar(String label, double value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            color: color,
            backgroundColor: Colors.grey[200],
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Text('${value.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
