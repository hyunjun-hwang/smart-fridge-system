import 'package:flutter/material.dart';
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';


class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _calorieController = TextEditingController();
  final _carbController = TextEditingController();
  final _fatController = TextEditingController();
  final _proteinController = TextEditingController();
  final _satFatController = TextEditingController();
  final _transFatController = TextEditingController();
  final _cholesterolController = TextEditingController();
  final _sodiumController = TextEditingController();
  final _calciumController = TextEditingController();
  final _fiberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 음식 추가'),
        backgroundColor: const Color(0xFFD5E8C6),
        foregroundColor: const Color(0xFF003508),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField('음식 이름', _nameController),
              _buildField('1인분당 칼로리', _calorieController, suffix: 'kcal'),
              _buildField('총 탄수화물', _carbController, suffix: 'g'),
              _buildField('총 지방', _fatController, suffix: 'g'),
              _buildField('단백질', _proteinController, suffix: 'g'),
              _buildField('포화지방', _satFatController, suffix: 'g'),
              _buildField('트랜스지방', _transFatController, suffix: 'g'),
              _buildField('콜레스테롤', _cholesterolController, suffix: 'mg'),
              _buildField('나트륨', _sodiumController, suffix: 'mg'),
              _buildField('칼슘', _calciumController, suffix: 'mg'),
              _buildField('식이섬유', _fiberController, suffix: 'g'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newFood = FoodItemn(
                      name: _nameController.text,
                      calories: double.tryParse(_calorieController.text) ?? 0,
                      carbohydrates: double.tryParse(_carbController.text) ?? 0,
                      fat: double.tryParse(_fatController.text) ?? 0,
                      protein: double.tryParse(_proteinController.text) ?? 0,
                      amount: 100,
                      count: 1,
                      imagePath: 'https://cdn-icons-png.flaticon.com/512/1046/1046870.png',
                    );
                    Navigator.pop(context, newFood);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC7D8A4),
                  foregroundColor: const Color(0xFF003508),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('추가하기', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Color(0xFF003508))),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                isDense: true,
                suffixText: suffix,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFC7D8A4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF003508), width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return '값을 입력하세요';
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
