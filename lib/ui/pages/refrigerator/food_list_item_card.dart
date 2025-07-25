import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../data/models/food_item.dart';


// --- 음식 목록 아이템 카드 위젯 ---
class FoodListItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap; // 1. onTap 콜백 함수 추가

  const FoodListItemCard({
    super.key,
    required this.item,
    required this.onTap, // 2. 생성자에 onTap 추가
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // 4. 탭 시 onTap 함수 실행
      borderRadius: BorderRadius.circular(16), // 물결 효과를 위해 추가
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
              child: Image.network(
                item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: const Color(0xFFF2F2F7),
                    child: const Icon(Icons.fastfood_outlined,
                        color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 6),
                  // --- 수량과 단위를 함께 표시하도록 수정 ---
                  Text('남은 수량   ${item.quantity}${item.unit.displayName}', style: const TextStyle(color: AppColors.primary, fontSize: 14)),
                  const SizedBox(height: 4),
                  // --- DateFormat을 사용해 날짜 포맷 지정 (intl 패키지 필요) ---
                  Text('유통기한   ${item.expiryDate.year}.${item.expiryDate.month}.${item.expiryDate.day}', style: const TextStyle(color: AppColors.primary, fontSize: 14)),
                ],
              ),
            ),
            DdayTag(dDay: item.dDay),
          ],
        ),
      ),
    );
  }
}

// --- D-Day 태그 위젯 (수정 없음) ---
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

// --- D-Day 태그 모양을 위한 Custom Clipper (수정 없음) ---
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