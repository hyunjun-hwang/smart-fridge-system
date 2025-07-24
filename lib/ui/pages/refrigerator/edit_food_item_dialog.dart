import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart'; // AppColors.primary 사용을 위해 유지
import 'package:smart_fridge_system/data/models/food_item.dart';

class EditFoodItemDialog extends StatefulWidget {
  final FoodItem item;

  const EditFoodItemDialog({super.key, required this.item});

  @override
  State<EditFoodItemDialog> createState() => _EditFoodItemDialogState();
}

class _EditFoodItemDialogState extends State<EditFoodItemDialog> {
  // --- 1. 색상 상수 정의 ---
  static const Color _textColor = Color(0xFF003508);
  static const Color _borderColor = Color(0xFFC7D8A4);

  // --- 상태 변수 및 컨트롤러 ---
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _expiryDateController;
  late TextEditingController _stockedDateController;

  late Unit _selectedUnit;
  late StorageType _selectedStorage;
  late String _selectedCategory;

  final List<String> _categoryOptions = ['과일', '고기', '채소', '유제품'];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item.name);
    _quantityController = TextEditingController(text: item.quantity.toString());
    _expiryDateController = TextEditingController(text: "${item.expiryDate.year}.${item.expiryDate.month}.${item.expiryDate.day}");
    _stockedDateController = TextEditingController(text: "${item.stockedDate.year}.${item.stockedDate.month}.${item.stockedDate.day}");
    _selectedUnit = item.unit;
    _selectedStorage = item.storage;
    _selectedCategory = item.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _expiryDateController.dispose();
    _stockedDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // 2. 다이얼로그 배경 흰색
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. 사진을 좌우 꽉 차게 ---
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(widget.item.imageUrl, height: 200, fit: BoxFit.cover),
            ),
            // --- 스크롤 가능한 입력 영역 ---
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldRow(controller: _nameController, label: '이름'),
                    _buildQuantityRow(),
                    _buildDateFieldRow(controller: _expiryDateController, label: '유통기한'),
                    _buildDateFieldRow(controller: _stockedDateController, label: '입고일'),
                    _buildStorageRow(),
                    _buildCategoryRow(),
                  ],
                ),
              ),
            ),
            // --- 하단 버튼 영역 ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI 구성을 위한 Helper 위젯들 ---

  TextStyle get _labelStyle => const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _textColor);
  TextStyle get _inputStyle => const TextStyle(color: _textColor);

  InputBorder get _inputBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: const BorderSide(color: _borderColor, width: 1.5),
  );

  Widget _buildTextFieldRow({required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label, style: _labelStyle)),
          Expanded(
            child: TextFormField(
              controller: controller,
              style: _inputStyle,
              decoration: InputDecoration(
                isDense: true,
                border: _inputBorder,
                enabledBorder: _inputBorder,
                focusedBorder: _inputBorder,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text('수량', style: _labelStyle)),
          Expanded(
            child: TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: _inputStyle,
              decoration: InputDecoration(
                isDense: true,
                border: _inputBorder,
                enabledBorder: _inputBorder,
                focusedBorder: _inputBorder,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ToggleButtons(
            isSelected: [_selectedUnit == Unit.count, _selectedUnit == Unit.grams],
            onPressed: (index) => setState(() => _selectedUnit = index == 0 ? Unit.count : Unit.grams),
            borderRadius: BorderRadius.circular(20),
            color: _textColor,
            selectedColor: _textColor,
            fillColor: _borderColor,
            constraints: const BoxConstraints(minHeight: 40, minWidth: 48),
            children: const [Text('개'), Text('g')],
          )
        ],
      ),
    );
  }

  Widget _buildDateFieldRow({required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label, style: _labelStyle)),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: true,
              style: _inputStyle,
              decoration: InputDecoration(
                isDense: true,
                border: _inputBorder,
                enabledBorder: _inputBorder,
                focusedBorder: _inputBorder,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101)
                );
                if(pickedDate != null ){
                  setState(() {
                    controller.text = "${pickedDate.year}.${pickedDate.month}.${pickedDate.day}";
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text('위치', style: _labelStyle)),
          ToggleButtons(
            isSelected: [_selectedStorage == StorageType.freezer, _selectedStorage == StorageType.fridge],
            onPressed: (index) => setState(() => _selectedStorage = index == 0 ? StorageType.freezer : StorageType.fridge),
            borderRadius: BorderRadius.circular(20),
            color: _textColor,
            selectedColor: _textColor,
            fillColor: _borderColor,
            constraints: const BoxConstraints(minHeight: 40),
            children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('냉동고')), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('냉장고'))],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('카테고리', style: _labelStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 0,
            children: [
              ..._categoryOptions.map((cat) => _buildCategoryRadioButton(cat)),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16, color: _textColor),
                label: Text('추가하기', style: TextStyle(color: _textColor)),
                onPressed: () {},
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: _borderColor, width: 1.5)
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCategoryRadioButton(String category) {
    return InkWell(
      onTap: () => setState(() => _selectedCategory = category),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: category,
            groupValue: _selectedCategory,
            onChanged: (value) => setState(() => _selectedCategory = value!),
            visualDensity: VisualDensity.compact,
            activeColor: _textColor,
          ),
          Text(category, style: _inputStyle),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: _borderColor, width: 1.5)
              ),
            ),
            child: Text('취소', style: TextStyle(fontSize: 16, color: _textColor)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: 수정 로직
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _borderColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text('수정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textColor)),
          ),
        ),
      ],
    );
  }
}