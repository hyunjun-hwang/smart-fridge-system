import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/full_nutrition_screen.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/record_entry_screen.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NutritionContent();
  }
}

class _NutritionContent extends StatefulWidget {
  const _NutritionContent({super.key});

  @override
  State<_NutritionContent> createState() => _NutritionContentState();
}

class _NutritionContentState extends State<_NutritionContent> {
  bool _isFullView = false;

  static const Color _textColor = Color(0xFF003508);
  static const Color _borderColor = Color(0xFFC7D8A4);

  final TextEditingController _targetInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
  }

  @override
  void dispose() {
    _targetInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyNutritionProvider>(
      builder: (context, provider, _) {
        final current = provider.currentDayNutrition;
        final consumed = current['calories'] ?? 0.0;
        final progress = provider.targetCalories > 0
            ? (consumed / provider.targetCalories).clamp(0.0, 1.0)
            : 0.0;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('영양소', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: _textColor),
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
                      child: _buildSegmentButton('기록하기', !_isFullView, () {
                        setState(() => _isFullView = false);
                      }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSegmentButton('전체보기', _isFullView, () {
                        setState(() => _isFullView = true);
                      }),
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
                  targetCal: provider.targetCalories,
                )
                    : _buildSummaryView(context, provider, current, consumed, progress),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSegmentButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: selected ? _borderColor : Colors.white,
          border: Border.all(color: _borderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? _textColor : _textColor.withOpacity(0.6),
              fontWeight: FontWeight.bold,
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
          icon: const Icon(Icons.chevron_left, color: _textColor),
          onPressed: () {
            provider.setSelectedDate(provider.selectedDate.subtract(const Duration(days: 1)));
          },
        ),
        Text(
          DateFormat('M월 d일 (E)', 'ko_KR').format(provider.selectedDate),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textColor),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: _textColor),
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
      Map<String, double> current,
      double consumed,
      double progress,
      ) {
    const meals = ['아침', '점심', '저녁', '아침간식', '점심간식', '저녁간식'];

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
                Text('${consumed.toInt()}kcal',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textColor)),
                GestureDetector(
                  onTap: () => _showTargetInputDialog(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '/ ${provider.targetCalories.toInt()}kcal',
                        style: const TextStyle(
                          fontSize: 14,
                          color: _textColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_circle_left_outlined, size: 18, color: _textColor),
                    ],
                  ),
                ),
              ],
            ),
            progressColor: _borderColor,
            backgroundColor: Colors.grey.shade200,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('탄수화물: ${(current["carbohydrates"] ?? 0).toInt()}g', style: const TextStyle(color: _textColor)),
              Text('단백질: ${(current["protein"] ?? 0).toInt()}g', style: const TextStyle(color: _textColor)),
              Text('지방: ${(current["fat"] ?? 0).toInt()}g', style: const TextStyle(color: _textColor)),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: meals.map((meal) {
              final mealKcal = provider.getMealNutrition(meal, provider.selectedDate)['calories'] ?? 0.0;
              return _MealCard(
                label: meal,
                kcal: mealKcal.toInt(),
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
    _targetInputController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('목표 칼로리 설정', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _targetInputController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: _textColor),
            decoration: const InputDecoration(
              hintText: '예: 1800',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _borderColor)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _borderColor, width: 2)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소', style: TextStyle(color: _textColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _borderColor,
                foregroundColor: _textColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                final newTarget = double.tryParse(_targetInputController.text);
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

  static const Color _textColor = Color(0xFF003508);
  static const Color _borderColor = Color(0xFFC7D8A4);

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
          border: Border.all(color: _borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: _textColor)),
            const SizedBox(height: 6),
            Text('${kcal}kcal', style: const TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
