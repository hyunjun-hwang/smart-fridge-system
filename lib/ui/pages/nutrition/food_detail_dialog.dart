import 'package:flutter/material.dart';
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';

Future<void> showFoodDetailDialog({
  required BuildContext context,
  required FoodItemn item,
  required Function(FoodItemn) onAdd,
}) async {
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (item.imagePath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  item.imagePath,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),

            Center(
              child: Text(
                item.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),
            _infoRow('칼로리(1개기준)', '${item.calories} kcal'),
            _infoRow('탄수화물', '${item.carbohydrates.toStringAsFixed(1)} g'),
            _infoRow('단백질', '${item.protein.toStringAsFixed(1)} g'),
            _infoRow('지방', '${item.fat.toStringAsFixed(1)} g'),

            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF003508),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFFC7D8A4), width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('취소하기', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onAdd(item); // ✅ 여기서 Navigator.pop(context, item) 실행됨
                      // ❌ 여기서는 더 이상 Navigator.pop(context) 호출하지 않음
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7D8A4),
                      foregroundColor: const Color(0xFF003508),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('추가하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15)),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
