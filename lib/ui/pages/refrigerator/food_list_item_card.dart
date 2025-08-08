import 'dart:io'; // ⭐️ Image.file을 사용하기 위해 import
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../data/models/food_item.dart';

class FoodListItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const FoodListItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    // isNotEmpty 체크 추가
    if (item.imageUrl.isNotEmpty) {
      if (item.imageUrl.startsWith('http')) {
        imageWidget = Image.network(
          item.imageUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildImageError(),
        );
      } else {
        imageWidget = Image.file(
          File(item.imageUrl),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildImageError(),
        );
      }
    } else {
      // ⭐️ 이미지가 없는 경우 (빈 문자열)
      imageWidget = _buildImageError();
    }

    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageWidget, // ⭐️ 동적으로 선택된 이미지 위젯 사용
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                      const SizedBox(height: 6),
                      Text('남은 수량   ${item.quantity}${item.unit.displayName}',
                          style: const TextStyle(
                              color: AppColors.primary, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                          '유통기한   ${item.expiryDate.year}.${item.expiryDate.month}.${item.expiryDate.day}',
                          style: const TextStyle(
                              color: AppColors.primary, fontSize: 14)),
                    ],
                  ),
                ),
                DdayTag(dDay: item.dDay),
              ],
            ),
          ),
        ),
        if (onDelete != null)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close,
                  color: AppColors.textSecondary, size: 20),
              onPressed: onDelete,
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(),
            ),
          ),
      ],
    );
  }

  // 이미지 로드 실패 시 보여줄 위젯
  Widget _buildImageError() {
    return Container(
        width: 80,
        height: 80,
        color: const Color(0xFFF2F2F7),
        child: const Icon(Icons.fastfood_outlined,
            color: AppColors.textSecondary));
  }
}

// ... DdayTag, DdayTagClipper는 수정 없음 ...
class DdayTag extends StatelessWidget {
  final int dDay;
  const DdayTag({super.key, required this.dDay});
  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    if (dDay <= 3) {
      bgColor = AppColors.statusDanger;
      textColor = AppColors.white;
    } else if (dDay <= 10) {
      bgColor = AppColors.statusSafe;
      textColor = AppColors.black;
    } else {
      bgColor = AppColors.accent;
      textColor = AppColors.primary;
    }
    return ClipPath(
      clipper: DdayTagClipper(),
      child: Container(
        width: 80,
        height: 40,
        color: bgColor,
        padding: const EdgeInsets.only(left: 10),
        alignment: Alignment.center,
        child: Text(
          'D-${dDay.toString()}',
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
class DdayTagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 10);
    path.lineTo(10, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}