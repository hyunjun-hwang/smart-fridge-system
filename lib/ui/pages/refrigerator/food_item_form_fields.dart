import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';

class FoodItemFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController expiryDateController;
  final TextEditingController stockedDateController;
  final XFile? imageFile;
  final String? existingImageUrl;
  final Unit selectedUnit;
  final StorageType selectedStorage;
  final FoodCategory selectedCategory;
  final VoidCallback onImageTap;
  final ValueChanged<Unit> onUnitChanged;
  final ValueChanged<StorageType> onStorageChanged;
  final ValueChanged<FoodCategory> onCategoryChanged;
  final Future<void> Function(TextEditingController) onDateTap;

  const FoodItemFormFields({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.expiryDateController,
    required this.stockedDateController,
    this.imageFile,
    this.existingImageUrl,
    required this.selectedUnit,
    required this.selectedStorage,
    required this.selectedCategory,
    required this.onImageTap,
    required this.onUnitChanged,
    required this.onStorageChanged,
    required this.onCategoryChanged,
    required this.onDateTap,
  });

  static const Color _textColor = Color(0xFF003508);
  static const Color _borderColor = Color(0xFFC7D8A4);
  TextStyle get _labelStyle => const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w500, color: _textColor);
  TextStyle get _inputStyle => const TextStyle(color: _textColor);
  InputBorder get _inputBorder => OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: _borderColor, width: 1.5));

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildImagePicker(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFieldRow(controller: nameController, label: '이름'),
              _buildQuantityRow(),
              _buildDateFieldRow(controller: expiryDateController, label: '유통기한'),
              _buildDateFieldRow(controller: stockedDateController, label: '입고일'),
              _buildStorageRow(),
              _buildCategoryRow(),
            ],
          ),
        ),
      ],
    );
  }

  // --- ⭐️ 이미지 피커 로직 수정 ⭐️ ---
  Widget _buildImagePicker() {
    Widget imageContent;
    final imageUrl = existingImageUrl;

    if (imageFile != null) {
      imageContent = Image.file(File(imageFile!.path), fit: BoxFit.cover);
    } else if (imageUrl != null && imageUrl.isNotEmpty) { // ⭐️ isNotEmpty 추가
      if (imageUrl.startsWith('http')) {
        imageContent = Image.network(imageUrl, fit: BoxFit.cover);
      } else {
        imageContent = Image.file(File(imageUrl), fit: BoxFit.cover);
      }
    } else {
      // ⭐️ 이미지가 아예 없는 경우 (빈 문자열)
      imageContent = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: Colors.grey, size: 40),
            SizedBox(height: 8),
            Text('사진 추가하기', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onImageTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: imageContent,
        ),
      ),
    );
  }

  // ... (나머지 _build... 메서드들은 이전과 동일)
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
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이름을 입력해주세요.';
                }
                return null;
              },
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
              controller: quantityController,
              keyboardType: TextInputType.number,
              style: _inputStyle,
              decoration: InputDecoration(
                isDense: true,
                border: _inputBorder,
                enabledBorder: _inputBorder,
                focusedBorder: _inputBorder,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '수량을 입력해주세요.';
                }
                if (int.tryParse(value) == null) {
                  return '숫자만 입력해주세요.';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          ToggleButtons(
            isSelected: [
              selectedUnit == Unit.count,
              selectedUnit == Unit.grams
            ],
            onPressed: (index) =>
                onUnitChanged(index == 0 ? Unit.count : Unit.grams),
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
  Widget _buildDateFieldRow(
      {required TextEditingController controller, required String label}) {
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
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onTap: () => onDateTap(controller),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '날짜를 선택해주세요.';
                }
                // 날짜 파싱 유효성 검사는 부모에서 수행
                return null;
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
            isSelected: [
              selectedStorage == StorageType.freezer,
              selectedStorage == StorageType.fridge
            ],
            onPressed: (index) => onStorageChanged(
                index == 0 ? StorageType.freezer : StorageType.fridge),
            borderRadius: BorderRadius.circular(20),
            color: _textColor,
            selectedColor: _textColor,
            fillColor: _borderColor,
            constraints: const BoxConstraints(minHeight: 40),
            children: const [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('냉동고')),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('냉장고'))
            ],
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
            children: FoodCategory.values
                .map((cat) => _buildCategoryRadioButton(cat))
                .toList(),
          )
        ],
      ),
    );
  }
  Widget _buildCategoryRadioButton(FoodCategory category) {
    return InkWell(
      onTap: () => onCategoryChanged(category),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<FoodCategory>(
            value: category,
            groupValue: selectedCategory,
            onChanged: (value) => onCategoryChanged(value!),
            visualDensity: VisualDensity.compact,
            activeColor: _textColor,
          ),
          Text(category.displayName, style: _inputStyle),
        ],
      ),
    );
  }
}