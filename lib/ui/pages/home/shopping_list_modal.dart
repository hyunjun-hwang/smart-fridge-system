import 'package:flutter/material.dart';

class ShoppingListModal extends StatefulWidget {
  final List<String> initialItems;

  const ShoppingListModal({super.key, required this.initialItems});

  @override
  State<ShoppingListModal> createState() => _ShoppingListModalState();
}

class _ShoppingListModalState extends State<ShoppingListModal> {
  late List<String> _items;
  late List<bool> _checked;
  int _editingIndex = -1;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
    _checked = List.filled(_items.length, false);
  }

  void _addItem(String value) {
    setState(() {
      _items.add(value);
      _checked.add(false);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _checked.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, size: 18, color: Colors.grey),
              SizedBox(width: 4),
              Text("냉장고 재고 기반 추천", style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(_items.length, (index) {
            if (_editingIndex == index) {
              return TextField(
                autofocus: true,
                controller: _controller..text = _items[index],
                onSubmitted: (value) {
                  if (value.trim().isEmpty) {
                    _removeItem(index);
                  } else {
                    setState(() => _items[index] = value);
                  }
                  setState(() => _editingIndex = -1);
                },
              );
            }
            return ListTile(
              leading: Checkbox(
                value: _checked[index],
                onChanged: (val) => setState(() => _checked[index] = val ?? false),
              ),
              title: GestureDetector(
                onTap: () {
                  setState(() {
                    _editingIndex = index;
                    _controller.text = _items[index];
                  });
                },
                child: Text(_items[index]),
              ),
            );
          }),
          const Divider(),
          Row(
            children: [
              const Icon(Icons.add, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.grey),
                  decoration: const InputDecoration(
                    hintText: "추가하기",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) _addItem(value.trim());
                    _controller.clear();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
