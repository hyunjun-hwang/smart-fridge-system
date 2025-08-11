import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/data/models/shopping_item.dart';
import 'package:smart_fridge_system/providers/shopping_list_provider.dart';

/// 장보기 목록 모달
class ShoppingListModal extends StatefulWidget {
  const ShoppingListModal({super.key});

  @override
  State<ShoppingListModal> createState() => _ShoppingListModalState();
}

class _ShoppingListModalState extends State<ShoppingListModal> {
  final List<ShoppingItem> _tempShoppingList = [];
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  int? _editingId;

  @override
  void initState() {
    super.initState();
    final initialItems = context.read<ShoppingListProvider>().shoppingItems;
    _tempShoppingList.addAll(initialItems.map((item) =>
        ShoppingItem(id: item.id, name: item.name, isChecked: item.isChecked)));
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 새 아이템 추가
  void _addNewItem() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _tempShoppingList.add(ShoppingItem(
            id: DateTime.now().millisecondsSinceEpoch,
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

  /// 아이템 수정 또는 삭제
  void _updateItem(ShoppingItem item) {
    if (_textController.text.trim().isEmpty) {
      setState(() {
        _tempShoppingList.removeWhere((element) => element.id == item.id);
        _editingId = null;
      });
    } else {
      setState(() {
        final targetItem =
        _tempShoppingList.firstWhere((element) => element.id == item.id);
        targetItem.name = _textController.text.trim();
        _editingId = null;
      });
    }
    _textController.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _tempShoppingList.length + 1,
                itemBuilder: (context, index) {
                  if (index == _tempShoppingList.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: _buildAddItemTile(),
                    );
                  }
                  final item = _tempShoppingList[index];
                  return _buildShoppingItemTile(item);
                },
              ),
            ),
            const SizedBox(height: 20),
            // 변경사항 저장 및 닫기
            ElevatedButton(
              onPressed: () {
                context
                    .read<ShoppingListProvider>()
                    .updateShoppingList(_tempShoppingList);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCBD6AB),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
            decoration: const InputDecoration(
                isDense: true, border: InputBorder.none),
            onSubmitted: (_) => _updateItem(item),
          )
              : GestureDetector(
            onTap: () {
              setState(() {
                _editingId = item.id;
                _textController.text = item.name;
                _focusNode.requestFocus();
              });
            },
            child: Text(item.name, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildAddItemTile() {
    bool isAdding = _editingId == -1;

    return Row(
      children: [
        const SizedBox(width: 12),
        Icon(Icons.add, color: isAdding ? Colors.green : Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: isAdding
              ? TextField(
            controller: _textController,
            focusNode: _focusNode,
            autofocus: true,
            decoration: const InputDecoration(
                hintText: '새 항목 추가',
                isDense: true,
                border: InputBorder.none),
            onSubmitted: (_) => _addNewItem(),
          )
              : GestureDetector(
            onTap: () {
              setState(() {
                _editingId = -1;
                _textController.clear();
                _focusNode.requestFocus();
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