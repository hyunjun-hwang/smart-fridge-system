// FILE: lib/ui/pages/nutrition/record_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';
import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/search_food_screen.dart';

class RecordEntryScreen extends StatefulWidget {
  final String mealType;
  final DateTime date;

  const RecordEntryScreen({
    Key? key,
    required this.mealType,
    required this.date,
  }) : super(key: key);

  @override
  State<RecordEntryScreen> createState() => _RecordEntryScreenState();
}

class _RecordEntryScreenState extends State<RecordEntryScreen> {
  final Color _textColor = const Color(0xFF003508);
  final Color _borderColor = const Color(0xFFC7D8A4);

  List<FoodItemn> foods = [];
  late DailyNutritionProvider provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = Provider.of<DailyNutritionProvider>(context);
    final existing = provider.getFoodsByMeal(widget.mealType, widget.date);
    foods = List.from(existing);
  }

  /// 단순 뒤로가기
  void _goBack() {
    Navigator.of(context).pop();
  }

  /// 시스템 뒤로가기 처리
  Future<bool> _onWillPop() async {
    _goBack();
    return false; // 기본 뒤로가기 동작을 막고, 직접 처리
  }

  @override
  Widget build(BuildContext context) {
    // 합계(✔ 1회 제공량 기준: 각 항목의 per-serving 값 × count(회))
    final totalCalories =
    foods.fold<double>(0, (sum, f) => sum + (f.calories * f.count));
    final totalCarbs =
    foods.fold<double>(0, (sum, f) => sum + (f.carbohydrates * f.count));
    final totalProtein =
    foods.fold<double>(0, (sum, f) => sum + (f.protein * f.count));
    final totalFat =
    foods.fold<double>(0, (sum, f) => sum + (f.fat * f.count));
    final targetCalories = provider.targetCalories;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F7),
        appBar: AppBar(
          backgroundColor: _borderColor,
          foregroundColor: _textColor,
          centerTitle: true,
          title: Text('${widget.mealType} 기록하기'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBack,
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: _borderColor),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Text(widget.mealType, style: TextStyle(color: _textColor)),
                        Icon(Icons.arrow_drop_down, color: _textColor),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.date.month}월 ${widget.date.day}일 (${_getWeekday(widget.date)})',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87),
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
                      text: '총 섭취 칼로리 ',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                      children: [
                        TextSpan(
                          text: totalCalories.toStringAsFixed(0),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const TextSpan(
                            text: 'kcal',
                            style: TextStyle(fontSize: 16, color: Colors.black)),
                        TextSpan(
                          text: ' / ${targetCalories.toStringAsFixed(0)} kcal',
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

                  // ✔ 1회 제공량 기준 표기
                  final servingG = food.amount; // amount = 1회 제공량(g)
                  final perServingKcal = food.calories;
                  final totalG = (servingG * food.count);
                  final totalKcal = (perServingKcal * food.count);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _borderColor.withOpacity(0.3)),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.fastfood,
                          size: 40, color: Colors.grey),
                      title: Text(food.name, style: TextStyle(color: _textColor)),
                      subtitle: Text(
                        '1회 제공량 ${servingG.toStringAsFixed(0)}g • '
                            '${perServingKcal.toStringAsFixed(1)}kcal/회  |  '
                            '총 ${totalG.toStringAsFixed(0)}g • ${totalKcal.toStringAsFixed(1)}kcal',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: _textColor),
                            onPressed: () {
                              setState(() {
                                if (food.count > 0.5) {
                                  foods[index] =
                                      food.copyWith(count: food.count - 0.5);
                                  provider.updateFood(
                                      widget.mealType, widget.date, foods[index]);
                                } else {
                                  provider.removeFoodItem(
                                      widget.mealType, widget.date, food.name);
                                  foods.removeAt(index);
                                }
                              });
                            },
                          ),
                          // ✔ "회" 단위로 표시
                          Text('${food.count}회',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline, color: _textColor),
                            onPressed: () {
                              setState(() {
                                foods[index] =
                                    food.copyWith(count: food.count + 0.5);
                                provider.updateFood(
                                    widget.mealType, widget.date, foods[index]);
                              });
                            },
                          ),
                        ],
                      ),
                      onTap: () => _showFoodInfoDialog(context, food),
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
                  onPressed: () async {
                    final result = await Navigator.push<FoodItemn>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchFoodScreen(
                          mealType: widget.mealType,
                          date: widget.date,
                        ),
                      ),
                    );
                    if (result != null) {
                      provider.addFood(widget.mealType, widget.date, result);
                      setState(() {
                        final i =
                        foods.indexWhere((f) => f.name == result.name);
                        if (i != -1) {
                          foods[i] = foods[i]
                              .copyWith(count: foods[i].count + result.count);
                        } else {
                          foods.add(result);
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _borderColor,
                    foregroundColor: _textColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('음식 추가', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
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
          Text('$label ${value.toStringAsFixed(1)}g',
              style: TextStyle(fontSize: 13, color: _textColor)),
        ],
      ),
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  void _showFoodInfoDialog(BuildContext context, FoodItemn food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(food.name,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _textColor)),
                  const SizedBox(height: 12),

                  // ✔ 기준(1회 제공량) 안내
                  _infoRow('기준', '1회 제공량 ${food.amount.toStringAsFixed(0)} g'),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '영양성분 (1회 제공량당)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  _infoRow('칼로리', '${food.calories.toStringAsFixed(1)} kcal'),
                  _infoRow('탄수화물', '${food.carbohydrates.toStringAsFixed(1)} g'),
                  _infoRow('단백질', '${food.protein.toStringAsFixed(1)} g'),
                  _infoRow('지방', '${food.fat.toStringAsFixed(1)} g'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _borderColor,
                  foregroundColor: _textColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('닫기',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}
