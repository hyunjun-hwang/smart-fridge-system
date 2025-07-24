import 'package:flutter/material.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';

class FoodItemDialog extends StatelessWidget {
  final FoodItem item;
  const FoodItemDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('카테고리', item.category),
          _buildInfoRow('남은 수량', '${item.quantity}${item.unit.displayName}'),
          _buildInfoRow('보관 위치', item.storage.displayName),
          _buildInfoRow('입고일', '${item.stockedDate.year}.${item.stockedDate.month}.${item.stockedDate.day}'),
          _buildInfoRow('유통기한', '${item.expiryDate.year}.${item.expiryDate.month}.${item.expiryDate.day} (D-${item.dDay})'),
        ],
      ),
      actions: <Widget>[
        TextButton(child: const Text('수정'), onPressed: () => Navigator.of(context).pop()),
        TextButton(child: const Text('닫기'), onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }

  // 정보 행을 만드는 helper 위젯
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}