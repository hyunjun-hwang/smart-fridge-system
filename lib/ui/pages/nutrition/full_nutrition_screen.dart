import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/meal_detail_screen.dart';

class FullNutritionScreen extends StatefulWidget {
  final Map<String, double> current;
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DailyNutritionProvider>(context);
    const meals = ['아침', '점심', '저녁', '아침간식', '점심간식', '저녁간식'];

    final periodLabel = {
      PeriodType.daily: '일별',
      PeriodType.weekly: '주별',
      PeriodType.monthly: '월별',
    }[_period]!;

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
              child: SizedBox(height: 220, child: _buildChartByPeriod()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${widget.consumed.toInt()}kcal / ${widget.targetCal.toInt()}kcal',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: meals.length,
                itemBuilder: (_, idx) {
                  final kcal = provider.getMealNutrition(meals[idx], provider.selectedDate)['calories'] ?? 0;
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MealDetailScreen(mealType: meals[idx], date: provider.selectedDate),
                      ),
                    ),
                    child: _MealCard(label: meals[idx], kcal: kcal.toInt()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartByPeriod() {
    switch (_period) {
      case PeriodType.daily:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDailyCalorieBar(),
            const SizedBox(height: 16),
            _buildDailyNutritionBars(),
          ],
        );
      case PeriodType.weekly:
        final weekly = Provider.of<DailyNutritionProvider>(context, listen: false).getWeeklyCalories();
        final data = weekly.map((date, cal) => MapEntry(_formatLabel(date), {'calories': cal / 7}));
        return _buildBarChart(data);
      case PeriodType.monthly:
        final monthly = Provider.of<DailyNutritionProvider>(context, listen: false).getMonthlyCalories();
        final data = monthly.map((date, cal) => MapEntry(_formatMonthLabel(date), {'calories': cal / DateTime(date.year, date.month + 1, 0).day}));
        return _buildBarChart(data);
    }
  }

  String _formatLabel(DateTime date) => '${date.month}/${date.day}';
  String _formatMonthLabel(DateTime date) => '${date.month}월';

  Widget _buildDailyCalorieBar() {
    final ratio = widget.targetCal > 0 ? (widget.consumed / widget.targetCal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('칼로리 섭취량', style: TextStyle(color: _textColor)),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: ratio,
          color: _accentColor,
          backgroundColor: Colors.grey.shade200,
          minHeight: 18,
        ),
        const SizedBox(height: 8),
        Text('${widget.consumed.toInt()} / ${widget.targetCal.toInt()} kcal',
            style: const TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDailyNutritionBars() {
    final carbs = widget.current['carbohydrates'] ?? 0.0;
    final protein = widget.current['protein'] ?? 0.0;
    final fat = widget.current['fat'] ?? 0.0;
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
        SizedBox(width: 70, child: Text(label, style: const TextStyle(color: _textColor)) ),
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

  Widget _buildBarChart(Map<String, Map<String, double>> data) {
    final keys = data.keys.toList();

    return BarChart(
      BarChartData(
        maxY: 2500,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: const Text('kcal'),
            axisNameSize: 28,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: _textColor),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('기간'),
            axisNameSize: 28,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= keys.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(keys[value.toInt()], style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(keys.length, (index) {
          final kcal = data[keys[index]]!['calories']!;
          return BarChartGroupData(x: index, barRods: [
            BarChartRodData(toY: kcal, width: 20, color: _accentColor),
          ]);
        }),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
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