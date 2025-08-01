import 'package:flutter/material.dart';

class ShoppingItem {
  final int id;
  String name;
  bool isChecked;

  ShoppingItem(
      {required this.id, required this.name, this.isChecked = false});
}

class ShoppingListModal extends StatefulWidget {
  final List<String> initialItems;
  const ShoppingListModal({super.key, this.initialItems = const []});

  @override
  State<ShoppingListModal> createState() => _ShoppingListModalState();
}

class _ShoppingListModalState extends State<ShoppingListModal> {
  final List<ShoppingItem> _shoppingList = [];
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  int? _editingId; // 현재 편집 중인 아이템의 ID

  @override
  void initState() {
    super.initState();
    // 초기 아이템으로 리스트 구성
    int idCounter = 0;
    for (var name in widget.initialItems) {
      _shoppingList
          .add(ShoppingItem(id: idCounter++, name: name, isChecked: name == "복숭아"));
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addNewItem() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _shoppingList.add(ShoppingItem(
            id: DateTime.now().millisecondsSinceEpoch, // 고유 ID 생성
            name: _textController.text.trim()));
        _textController.clear();
        _editingId = null;
        _focusNode.unfocus();
      });
    } else {
      setState(() {
        _editingId = null;
      });
    }
  }

  void _updateItem(ShoppingItem item) {
    if (_textController.text.trim().isEmpty) {
      // 텍스트를 모두 지우고 엔터치면 삭제
      setState(() {
        _shoppingList.removeWhere((element) => element.id == item.id);
        _editingId = null;
      });
    } else {
      setState(() {
        item.name = _textController.text.trim();
        _editingId = null;
      });
    }
    _textController.clear();
    _focusNode.unfocus();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      // 키보드가 올라올 때 UI가 가려지지 않도록 설정
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
                child: Text('장보기',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text('현재 냉장고에 우유가 없습니다.',
                    style: TextStyle(fontSize: 15, color: Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _shoppingList.length + 1, // '추가하기' 포함
                itemBuilder: (context, index) {
                  if (index == _shoppingList.length) {
                    // 리스트의 마지막 항목: 추가하기 또는 입력 필드
                    return _buildAddItemTile();
                  }
                  final item = _shoppingList[index];
                  return _buildShoppingItemTile(item);
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCBD6AB),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('닫기',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingItemTile(ShoppingItem item) {
    bool isEditing = _editingId == item.id;

    return Row(
      children: [
        Checkbox(
          value: item.isChecked,
          onChanged: (bool? value) {
            setState(() {
              item.isChecked = value!;
            });
          },
          activeColor: Colors.lightGreen,
        ),
        Expanded(
          child: isEditing
              ? TextField(
            controller: _textController,
            focusNode: _focusNode,
            autofocus: true,
            decoration:
            const InputDecoration(isDense: true, border: InputBorder.none),
            onSubmitted: (_) => _updateItem(item),
          )
              : GestureDetector(
            onTap: () {
              setState(() {
                _editingId = item.id;
                _textController.text = item.name;
              });
            },
            child: Text(
              item.name,
              style: TextStyle(
                  fontSize: 16,
                  decoration: item.isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddItemTile() {
    bool isAdding = _editingId == -1; // -1을 '새 항목 추가 중' 상태로 사용

    return Row(
      children: [
        const SizedBox(width: 12), // 체크박스 자리 비우기
        Icon(Icons.add, color: isAdding ? Colors.green : Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: isAdding
              ? TextField(
            controller: _textController,
            focusNode: _focusNode,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '항목 입력 후 Enter',
              isDense: true,
              border: InputBorder.none,
            ),
            onSubmitted: (_) => _addNewItem(),
          )
              : GestureDetector(
            onTap: () {
              setState(() {
                _editingId = -1;
                _textController.clear();
              });
            },
            child: const Text('추가하기',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ),
        ),
      ],
    );
  }
}