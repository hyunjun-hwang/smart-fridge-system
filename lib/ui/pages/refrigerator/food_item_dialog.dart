import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';
import 'package:smart_fridge_system/providers/food_provider.dart';
import 'package:smart_fridge_system/ui/pages/refrigerator/food_item_form_fields.dart';
import 'package:uuid/uuid.dart';

class FoodItemDialog extends StatefulWidget {
  final FoodItem? item;
  const FoodItemDialog({super.key, this.item});

  @override
  State<FoodItemDialog> createState() => _FoodItemDialogState();
}

class _FoodItemDialogState extends State<FoodItemDialog> {
  static const Color _textColor = Color(0xFF003508);
  static const Color _borderColor = Color(0xFFC7D8A4);

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _expiryDateController;
  late TextEditingController _stockedDateController;
  late Unit _selectedUnit;
  late StorageType _selectedStorage;
  late FoodCategory _selectedCategory;

  XFile? _selectedImageFile;
  bool get isEditMode => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final item = widget.item!;
      _nameController = TextEditingController(text: item.name);
      _quantityController = TextEditingController(text: item.quantity.toString());
      _expiryDateController = TextEditingController(text: _formatDate(item.expiryDate));
      _stockedDateController = TextEditingController(text: _formatDate(item.stockedDate));
      _selectedUnit = item.unit;
      _selectedStorage = item.storage;
      _selectedCategory = item.category;
      _selectedImageFile = null;
    } else {
      _nameController = TextEditingController();
      _quantityController = TextEditingController();
      _expiryDateController = TextEditingController();
      _stockedDateController = TextEditingController(text: _formatDate(DateTime.now()));
      _selectedUnit = Unit.count;
      _selectedStorage = StorageType.fridge;
      _selectedCategory = FoodCategory.fruit;
      _selectedImageFile = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _expiryDateController.dispose();
    _stockedDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) { return "${date.year}.${date.month}.${date.day}"; }
  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('.');
      if (parts.length != 3) return null;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _parseDate(controller.text) ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (pickedDate != null) {
      setState(() {
        controller.text = _formatDate(pickedDate);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImageFile = image;
      });
    }
  }
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Center(child: Text(isEditMode ? '음식 수정' : '음식 추가')),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: FoodItemFormFields(
                    nameController: _nameController,
                    quantityController: _quantityController,
                    expiryDateController: _expiryDateController,
                    stockedDateController: _stockedDateController,
                    imageFile: _selectedImageFile,
                    existingImageUrl: isEditMode ? widget.item!.imageUrl : null,
                    selectedUnit: _selectedUnit,
                    selectedStorage: _selectedStorage,
                    selectedCategory: _selectedCategory,
                    onImageTap: _showImageSourceActionSheet,
                    onUnitChanged: (unit) => setState(() => _selectedUnit = unit),
                    onStorageChanged: (storage) => setState(() => _selectedStorage = storage),
                    onCategoryChanged: (category) => setState(() => _selectedCategory = category),
                    onDateTap: _pickDate,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildActionButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    final expiryDate = _parseDate(_expiryDateController.text);
    final stockedDate = _parseDate(_stockedDateController.text);
    if (expiryDate == null || stockedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('날짜 형식이 올바르지 않습니다.')));
      return;
    }
    String? oldImagePath;
    if (isEditMode && _selectedImageFile != null) {
      // 수정 모드이고, 새 이미지를 선택했을 때만 이전 이미지 경로를 저장
      oldImagePath = widget.item!.imageUrl;
    }

    String imageUrlToSave;
    if (_selectedImageFile != null) {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final fileName = const Uuid().v4();
      final fileExtension = path.extension(_selectedImageFile!.path);
      final newPath = path.join(documentsDirectory.path, '$fileName$fileExtension');
      final newFile = await File(_selectedImageFile!.path).copy(newPath);
      imageUrlToSave = newFile.path;
    } else if (isEditMode) {
      imageUrlToSave = widget.item!.imageUrl;
    } else {
      imageUrlToSave = '';
    }

    try {
      final foodProvider = context.read<FoodProvider>();
      if (isEditMode) {
        final updatedItem = FoodItem(
          id: widget.item!.id,
          name: _nameController.text,
          imageUrl: imageUrlToSave,
          quantity: int.parse(_quantityController.text),
          unit: _selectedUnit,
          expiryDate: expiryDate,
          stockedDate: stockedDate,
          storage: _selectedStorage,
          category: _selectedCategory,
        );
        await foodProvider.updateFoodItem(updatedItem);
      } else {
        await foodProvider.addFoodItem(
          name: _nameController.text,
          imageUrl: imageUrlToSave,
          quantity: int.parse(_quantityController.text),
          unit: _selectedUnit,
          expiryDate: expiryDate,
          stockedDate: stockedDate,
          storage: _selectedStorage,
          category: _selectedCategory,
        );
      }
      if (oldImagePath != null && oldImagePath.isNotEmpty && !oldImagePath.startsWith('http')) {
        try {
          final oldFile = File(oldImagePath);
          if (await oldFile.exists()) {
            await oldFile.delete();
            print('Old file deleted: $oldImagePath');
          }
        } catch (e) {
          // 파일 삭제에 실패해도 앱이 중단되지 않도록 처리
          print('Error deleting old file: $e');
        }
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장에 실패했습니다: $e')));
      }
    }
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
                  side: const BorderSide(color: _borderColor, width: 1.5)),
            ),
            child: Text('취소', style: TextStyle(fontSize: 16, color: _textColor)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: _onSavePressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _borderColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(isEditMode ? '수정' : '추가',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textColor)),
          ),
        ),
      ],
    );
  }
}