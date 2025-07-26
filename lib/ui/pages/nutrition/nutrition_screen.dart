import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/full_nutrition_screen.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/record_entry_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  bool _isFullView = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DailyNutritionProvider>(context);
    final current = provider.currentDayNutrition.map((key, value) => MapEntry(key, (value as num).toInt()));
    final targetCal = provider.targetCalories.toDouble();
    final consumed = (current['calories'] ?? 0).toDouble();
    final progress = targetCal > 0 ? (consumed / targetCal).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('영양소', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildSegmentButton(
                    label: '기록하기',
                    selected: !_isFullView,
                    onTap: () => setState(() => _isFullView = false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSegmentButton(
                    label: '전체보기',
                    selected: _isFullView,
                    onTap: () => setState(() => _isFullView = true),
                  ),
                ),
              ],
            ),
          ),
          _buildDateSelector(provider),
          Expanded(
            child: _isFullView
                ? FullNutritionScreen(
              current: current,
              consumed: consumed,
              targetCal: targetCal,
            )
                : _buildSummaryView(context, provider, current, consumed, targetCal, progress),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: '냉장고'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: '레시피'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '영양소'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
        currentIndex: 3,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // TODO: 탭 이동 처리
        },
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: selected ? Colors.green : Colors.white,
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(DailyNutritionProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            provider.setSelectedDate(provider.selectedDate.subtract(const Duration(days: 1)));
          },
        ),
        Text(
          DateFormat('M월 d일 (E)', 'ko_KR').format(provider.selectedDate),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            provider.setSelectedDate(provider.selectedDate.add(const Duration(days: 1)));
          },
        ),
      ],
    );
  }

  Widget _buildSummaryView(
      BuildContext context,
      DailyNutritionProvider provider,
      Map<String, int> current,
      double consumed,
      double targetCal,
      double progress,
      ) {
    const meals = [
      '아침',
      '점심',
      '저녁',
      '아침간식',
      '점심간식',
      '저녁간식',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          CircularPercentIndicator(
            radius: MediaQuery.of(context).size.width * 0.3,
            lineWidth: 12,
            percent: progress,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${consumed.toInt()}kcal', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => _showTargetInputDialog(context),
                  child: Text(
                    '/ ${targetCal.toInt()}kcal',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            progressColor: Colors.green,
            backgroundColor: Colors.grey.shade200,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('탄수화물: ${current["탄수화물"] ?? 0}g'),
              Text('단백질: ${current["단백질"] ?? 0}g'),
              Text('지방: ${current["지방"] ?? 0}g'),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: meals.map((meal) {
              return _MealCard(
                label: meal,
                kcal: current[meal] ?? 0,
                date: provider.selectedDate,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showTargetInputDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEFF7EF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('목표 칼로리 설정', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '예: 1800',
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final newTarget = double.tryParse(controller.text);
                if (newTarget != null && newTarget > 0) {
                  Provider.of<DailyNutritionProvider>(context, listen: false)
                      .setTargetCalories(newTarget);
                }
                Navigator.of(context).pop();
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }
}

class _MealCard extends StatelessWidget {
  final String label;
  final int kcal;
  final DateTime date;

  const _MealCard({
    required this.label,
    required this.kcal,
    required this.date,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RecordEntryScreen(
              mealType: label,
              date: date,
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        height: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text('${kcal}kcal', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
