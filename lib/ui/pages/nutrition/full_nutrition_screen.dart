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

  static const Color _textColor = Color(0xFF003508);
  static const Color _accentColor = Color(0xFFC7D8A4);

  final Map<String, Map<String, double>> _weeklyAvg = {
    '3주 전': {'calories': 1720, 'carbs': 230, 'protein': 90, 'fat': 60},
    '2주 전': {'calories': 1800, 'carbs': 240, 'protein': 95, 'fat': 65},
    '1주 전': {'calories': 1650, 'carbs': 220, 'protein': 85, 'fat': 55},
    '이번 주': {'calories': 1750, 'carbs': 210, 'protein': 100, 'fat': 70},
  };

  final Map<String, Map<String, double>> _monthlyAvg = {
    '5월': {'calories': 1850, 'carbs': 250, 'protein': 92, 'fat': 68},
    '6월': {'calories': 1780, 'carbs': 240, 'protein': 88, 'fat': 60},
    '7월': {'calories': 1900, 'carbs': 260, 'protein': 96, 'fat': 70},
  };

  @override
  Widget build(BuildContext context) {
    final periodLabel = {
      PeriodType.daily: '일별',
      PeriodType.weekly: '주별',
      PeriodType.monthly: '월별',
    }[_period]!;

    const meals = ['아침', '점심', '저녁', '아침간식', '점심간식', '저녁간식'];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showPeriodMenu,
                    child: Row(
                      children: [
                        Text(periodLabel, style: const TextStyle(color: _textColor)),
                        const Icon(Icons.arrow_drop_down, color: _textColor),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateTime.now().toString().split(' ')[0],
                    style: const TextStyle(fontWeight: FontWeight.bold, color: _textColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 220,
                child: _period == PeriodType.daily
                    ? _buildDailyNutritionBars(widget.current)
                    : BarChart(_buildGroupedBarData(
                    _period == PeriodType.weekly ? _weeklyAvg : _monthlyAvg)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('${widget.consumed.toInt()}kcal / ${widget.targetCal.toInt()}kcal',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textColor)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NutritionScreen()),
                    );
                  },
                  child: const Text('식사 추가', style: TextStyle(color: _textColor, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildBar({required String label, required double value, required double ratio, required Color color}) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(color: _textColor))),
        Expanded(
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            color: color,
            backgroundColor: Colors.grey[200],
            minHeight: 10,
          ),
        ),
        const SizedBox(width: 8),
        Text('${value.toStringAsFixed(1)}g', style: const TextStyle(color: _textColor)),
      ],
    );
  }

  BarChartData _buildGroupedBarData(Map<String, Map<String, double>> data) {
    final nutrients = ['calories', 'carbs', 'protein', 'fat'];
    final colors = [Colors.redAccent, Colors.orange, Colors.green, Colors.blue];
    final barGroups = <BarChartGroupData>[];

    int index = 0;
    for (final entry in data.entries) {
      final rods = List.generate(nutrients.length, (i) {
        return BarChartRodData(
          toY: entry.value[nutrients[i]] ?? 0,
          width: 7,
          color: colors[i],
          borderRadius: BorderRadius.circular(2),
        );
      });
      barGroups.add(BarChartGroupData(x: index++, barRods: rods, barsSpace: 4));
    }

    return BarChartData(
      barGroups: barGroups,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              final keys = data.keys.toList();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(keys[value.toInt()], style: const TextStyle(fontSize: 10, color: _textColor)),
              );
            },

          ),
        ),
      ),
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
            title: Text(label, style: const TextStyle(color: _textColor)),
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

  static const Color _textColor = Color(0xFF003508);

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
            Text(label, style: const TextStyle(fontSize: 14, color: _textColor)),
            const SizedBox(height: 6),
            Text('$kcal kcal', style: const TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

enum PeriodType { daily, weekly, monthly }
