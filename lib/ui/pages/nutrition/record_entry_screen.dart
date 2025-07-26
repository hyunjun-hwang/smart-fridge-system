import 'package:flutter/material.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/search_food_screen.dart'; // ✅ 추가한 화면 import

class RecordEntryScreen extends StatelessWidget {
  final String mealType;
  final DateTime date;

  const RecordEntryScreen({
    Key? key,
    required this.mealType,
    required this.date,
  }) : super(key: key);

  static const Color _textColor = Color(0xFF003508);
  static const Color _borderColor = Color(0xFFC7D8A4);

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    final foods = List.generate(4, (_) => {
      'name': '사과',
      'amount': '1개(200g)',
      'calories': 100,
      'carbs': 27.8,
      'protein': 0.3,
      'fat': 0.2,
      'image': 'https://cdn-icons-png.flaticon.com/512/415/415682.png',
    });

    final totalCalories = foods.fold(0, (sum, f) => sum + (f['calories'] as int));
    final totalCarbs = foods.fold(0.0, (sum, f) => sum + (f['carbs'] as double));
    final totalProtein = foods.fold(0.0, (sum, f) => sum + (f['protein'] as double));
    final totalFat = foods.fold(0.0, (sum, f) => sum + (f['fat'] as double));
    final targetCal = 1800;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: _borderColor,
        foregroundColor: _textColor,
        centerTitle: true,
        title: Text('$mealType 기록하기'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _borderColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Text(mealType, style: const TextStyle(color: _textColor)),
                      const Icon(Icons.arrow_drop_down, color: _textColor),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${date.month}월 ${date.day}일 (${_getWeekday(date)})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    text: '총 섭취 칼로리\n',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    children: [
                      TextSpan(
                        text: '$totalCalories',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const TextSpan(
                        text: 'kcal',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      TextSpan(
                        text: ' /$targetCal kcal',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildNutritionBar('탄수화물', totalCarbs, Colors.blue.shade200),
                _buildNutritionBar('단백질', totalProtein, Colors.green.shade200),
                _buildNutritionBar('지방', totalFat, Colors.teal.shade200),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: foods.length,
              itemBuilder: (_, index) {
                final food = foods[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderColor.withOpacity(0.3)),
                  ),
                  child: ListTile(
                    leading: Image.network(food['image'] as String, width: 40, height: 40),
                    title: Text(food['name'] as String, style: const TextStyle(color: _textColor)),
                    subtitle: Text('${food['amount']} ${food['calories']}kcal', style: const TextStyle(color: Colors.black54)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('1', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        SizedBox(width: 4),
                        Icon(Icons.add_circle_outline, color: _textColor),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchFoodScreen(mealType: mealType, date: date),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _borderColor,
                  foregroundColor: _textColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('음식 추가', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              color: color,
              backgroundColor: Colors.grey.shade300,
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 12),
          Text('$label ${value.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 13, color: _textColor)),
        ],
      ),
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }
}