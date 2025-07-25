// lib/screens/record_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';

/// "기록하기" 버튼 클릭 시 나타나는 화면
class RecordEntryScreen extends StatefulWidget {
  const RecordEntryScreen({Key? key, required String mealType, required DateTime date}) : super(key: key);

  @override
  State<RecordEntryScreen> createState() => _RecordEntryScreenState();
}

class _RecordEntryScreenState extends State<RecordEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String _mealType='아침';
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _saveRecord() {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<DailyNutritionProvider>(context, listen: false);
    final food = _foodNameController.text.trim();
    final kcal = double.tryParse(_caloriesController.text) ?? 0;

    // addNutrition 메서드 시그니처에 맞춰 호출
    provider.addNutrition(
      provider.selectedDate,
      _mealType,
      food,

    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기록하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1) 식사 구분
              DropdownButtonFormField<String>(
                value: _mealType,
                decoration: const InputDecoration(labelText: '식사 구분'),
                items: [
                  '아침', '점심', '저녁',
                  '아침간식', '점심간식', '저녁간식',
                ].map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m),
                )).toList(),
                onChanged: (v) => setState(() => _mealType = v!),
              ),
              const SizedBox(height: 16),

              // 2) 음식 이름
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(
                  labelText: '음식 이름',
                  hintText: '예: 사과, 샐러드',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? '음식 이름을 입력해주세요' : null,
              ),
              const SizedBox(height: 16),

              // 3) 칼로리 입력
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: '칼로리',
                  suffixText: 'kcal',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return '유효한 칼로리를 입력해주세요';
                  return null;
                },
              ),
              const Spacer(),

              // 4) 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveRecord,
                  child: const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
