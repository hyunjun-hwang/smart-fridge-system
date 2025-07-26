import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/record_entry_screen.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/nutrition_screen.dart';

class FullNutritionScreen extends StatefulWidget {
  final Map<String, dynamic> current;
  final double consumed;
  final double targetCal;

  const FullNutritionScreen({
    Key? key,
    required this.current,
    required this.consumed,
    required this.targetCal,
  }) : super(key: key);

  @override
  State<FullNutritionScreen> createState() => _FullNutritionScreenState();
}

class _FullNutritionScreenState extends State<FullNutritionScreen> {
  PeriodType _period = PeriodType.daily;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DailyNutritionProvider>(context);

    Map<DateTime, double> graphData;
    switch (_period) {
      case PeriodType.daily:
        graphData = provider.getDailyCaloriesForGraph();
        break;
      case PeriodType.weekly:
        graphData = provider.getWeeklyCalories();
        break;
      case PeriodType.monthly:
        graphData = provider.getMonthlyCalories();
        break;
    }

    final periodLabel = {
      PeriodType.daily: '일별',
      PeriodType.weekly: '주별',
      PeriodType.monthly: '월별',
    }[_period]!;

    const meals = [
      '아침',
      '점심',
      '저녁',
      '아침간식',
      '점심간식',
      '저녁간식',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 & 보기 모드 선택
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: _showPeriodMenu,
                child: Row(
                  children: [
                    Text(periodLabel, style: const TextStyle(color: Colors.green)),
                    const Icon(Icons.arrow_drop_down, color: Colors.green),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                DateTime.now().toString().split(' ')[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 차트 or 탄단지 바
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _period == PeriodType.daily
                ? _buildDailyNutritionBars(widget.current)
                : BarChart(_buildBarData(graphData)),
          ),
        ),

        // 총 칼로리
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.consumed.toInt()}kcal / ${widget.targetCal.toInt()}kcal',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (_period != PeriodType.daily)
                const Text('※ 그래프는 총 섭취량입니다.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),

        // 식사별 섹션
        AspectRatio(
          aspectRatio: 3 / 2,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: meals.length,
            itemBuilder: (_, idx) => _MealCard(
              label: meals[idx],
              kcal: widget.current[meals[idx]]?.toInt() ?? 0,
            ),
          ),
        ),

        // 식사 추가 버튼
        // 식사 추가 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NutritionScreen(), // ← 이 부분 수정됨
                  ),
                );
              },
              child: const Text('식사 추가', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ),

      ],
    );
  }

  // 탄단지 비율 ProgressBar
  Widget _buildDailyNutritionBars(Map<String, dynamic> nutrition) {
    final carbs = (nutrition['carbohydrates'] ?? 0).toDouble();
    final protein = (nutrition['protein'] ?? 0).toDouble();
    final fat = (nutrition['fat'] ?? 0).toDouble();
    final total = carbs + protein + fat;

    double getRatio(double v) => total > 0 ? (v / total) : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBar(label: '탄수화물', value: carbs, ratio: getRatio(carbs), color: Colors.lightGreen),
        const SizedBox(height: 6),
        _buildBar(label: '단백질', value: protein, ratio: getRatio(protein), color: Colors.green),
        const SizedBox(height: 6),
        _buildBar(label: '지방', value: fat, ratio: getRatio(fat), color: Colors.teal),
      ],
    );
  }

  Widget _buildBar({
    required String label,
    required double value,
    required double ratio,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label)),
        Expanded(
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            color: color,
            backgroundColor: Colors.grey[200],
            minHeight: 10,
          ),
        ),
        const SizedBox(width: 8),
        Text('${value.toStringAsFixed(1)}g'),
      ],
    );
  }

  // 그래프 데이터 생성
  BarChartData _buildBarData(Map<DateTime, double> data) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final barGroups = List.generate(sortedEntries.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: sortedEntries[i].value,
            width: 12,
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    return BarChartData(
      barGroups: barGroups,
      titlesData: FlTitlesData(show: false),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
    );
  }

  void _showPeriodMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: PeriodType.values.map((p) {
          final label = {
            PeriodType.daily: '일별',
            PeriodType.weekly: '주별',
            PeriodType.monthly: '월별',
          }[p]!;
          return ListTile(
            title: Text(label),
            onTap: () {
              setState(() => _period = p);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String label;
  final int kcal;

  const _MealCard({required this.label, required this.kcal, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text('$kcal kcal',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

enum PeriodType { daily, weekly, monthly }
