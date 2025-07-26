import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';

class AddFoodItemDialog extends StatefulWidget {
  const AddFoodItemDialog({super.key});

  @override
  State<AddFoodItemDialog> createState() => _AddFoodItemDialogState();
}

class _AddFoodItemDialogState extends State<AddFoodItemDialog> {
  // --- 1. 색상 상수 정의 ---
  static const Color _textColor = Color(0xFF003508);
  static const Color _borderColor = Color(0xFFC7D8A4);

  // --- 상태 변수 및 컨트롤러 ---
  final _formKey = GlobalKey<FormState>(); // 폼 유효성 검사를 위한 키

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _expiryDateController;
  late TextEditingController _stockedDateController;

  Unit _selectedUnit = Unit.count; // 기본값 설정
  StorageType _selectedStorage = StorageType.fridge; // 기본값 설정
  String _selectedCategory = '과일'; // 기본값 설정

  // TODO: 실제 앱에서는 이 목록을 외부(DB)에서 관리
  final List<String> _categoryOptions = ['과일', '고기', '채소', '유제품'];

  // TODO: 이미지 피커로 선택된 이미지 URL을 저장할 변수
  String? _selectedImageUrl;


  @override
  void initState() {
    super.initState();
    // --- 2. '추가'용으로 컨트롤러를 빈 값으로 초기화 ---
    _nameController = TextEditingController();
    _quantityController = TextEditingController();
    _expiryDateController = TextEditingController();
    _stockedDateController = TextEditingController(text: "${DateTime.now().year}.${DateTime.now().month}.${DateTime.now().day}");
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
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- 3. 사진 추가 기능 (플레이스홀더) ---
                      _buildImagePicker(),
                      Padding(
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
                    ],
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

  // --- UI 구성을 위한 Helper 위젯들 (이전과 대부분 동일) ---

  TextStyle get _labelStyle => const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _textColor);
  TextStyle get _inputStyle => const TextStyle(color: _textColor);

  InputBorder get _inputBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: const BorderSide(color: _borderColor, width: 1.5),
  );

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () {
        // TODO: image_picker 패키지를 사용해 이미지 선택 로직 구현
        print("이미지 선택");
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _selectedImageUrl != null
            ? ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Image.network(_selectedImageUrl!, fit: BoxFit.cover),
        )
            : const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, color: Colors.grey, size: 40),
              SizedBox(height: 8),
              Text('사진 추가하기', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

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
              // --- 4. '추가' 버튼 로직 ---
              // TODO: 유효성 검사 추가 (예: 이름이 비어있는지)

              // 입력된 값들로 새로운 FoodItem 객체 생성
              final newFoodItem = FoodItem(
                  name: _nameController.text,
                  imageUrl: _selectedImageUrl ?? 'https://via.placeholder.com/150', // 이미지가 없으면 기본 이미지
                  quantity: int.tryParse(_quantityController.text) ?? 0,
                  unit: _selectedUnit,
                  // TODO: 날짜 텍스트를 DateTime으로 파싱하는 로직 필요
                  expiryDate: DateTime.now().add(const Duration(days: 7)),
                  stockedDate: DateTime.now(),
                  storage: _selectedStorage,
                  category: _selectedCategory
              );

              // 생성된 객체를 반환하며 다이얼로그 닫기
              Navigator.of(context).pop(newFoodItem);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _borderColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text('추가', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textColor)),
          ),
        ),
      ],
    );
  }
}