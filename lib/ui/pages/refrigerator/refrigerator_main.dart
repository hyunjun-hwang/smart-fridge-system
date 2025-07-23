import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';

// --- 데이터 모델 ---
class FoodItem {
  final String name;
  final String quantity;
  final String imageUrl;
  final String expiryDate;
  final int dDay;

  FoodItem({
    required this.name,
    required this.quantity,
    required this.imageUrl,
    required this.expiryDate,
    required this.dDay,
  });
}

// --- 페이지 위젯 ---
class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  // 샘플 데이터
  final List<FoodItem> foodItems = [
    FoodItem(name: '사과', quantity: '6개', imageUrl: 'https://images.unsplash.com/photo-1579613832125-5d34a13ffe2a?q=80&w=2940&auto=format&fit=crop', expiryDate: '2025. 08. 22', dDay: 30),
    FoodItem(name: '아보카도', quantity: '2개', imageUrl: 'https://images.unsplash.com/photo-1579613832125-5d34a13ffe2a?q=80&w=2940&auto=format&fit=crop', expiryDate: '2025. 08. 02', dDay: 10),
    FoodItem(name: '소고기', quantity: '350g', imageUrl: 'https://images.unsplash.com/photo-1579613832125-5d34a13ffe2a?q=80&w=2940&auto=format&fit=crop', expiryDate: '2025. 07. 24', dDay: 1),
  ];

  // 필터 및 정렬 상태 관리 변수
  final List<String> categories = ['전체', '과일', '고기', '채소', '유제품'];
  String selectedCategory = '전체';

  final List<String> storageOptions = ['냉장실', '냉동고', '실온'];
  String selectedStorage = '냉장실';

  final List<String> sortOptions = ['유통기한 임박한 순', '유통기한 많이 남은순', '최근에 입고된 순', '예전에 입고된 순', '수량 많은 순', '수량 적은 순'];
  String selectedSortOrder = '유통기한 임박한 순';

  @override
  Widget build(BuildContext context) {
    // 1. 전체 배경을 옅은 회색으로 설정
    return Container(
      color: const Color(0xFFF2F2F7),
      child: Column(
        children: [
          // 2. 필터 영역을 별도의 흰색 컨테이너로 묶고 그림자 효과 적용
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  spreadRadius: 1,
                  blurRadius: 15,
                  offset: const Offset(0, 5), // 아래쪽으로 그림자
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSearchAndFilter(),
                const SizedBox(height: 16),
                _buildSortButton(),
              ],
            ),
          ),
          // 3. 목록 부분
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20), // 목록 전체의 여백
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                return FoodListItemCard(item: foodItems[index]);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            ),
          ),
        ],
      ),
    );
  }

  // --- 상단 검색 및 필터 위젯 ---
  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        Row(
          children: [
            // '냉장실' 드롭다운 버튼
            _buildStorageDropdown(),
            const SizedBox(width: 8),
            // 검색창
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '여기에 검색하세요.',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.textSecondary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.textSecondary, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 카테고리 필터 칩
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final bool isSelected = selectedCategory == categories[index];
              return ChoiceChip(
                label: Text(categories[index]),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => selectedCategory = categories[index]);
                },
                backgroundColor: AppColors.white,
                selectedColor: AppColors.textSecondary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.textSecondary),
                ),
                showCheckmark: false,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 8),
          ),
        )
      ],
    );
  }

  // --- 보관 장소 선택 드롭다운 ---
  Widget _buildStorageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: PopupMenuButton<String>(
        onSelected: (String value) {
          setState(() {
            selectedStorage = value;
          });
        },
        itemBuilder: (BuildContext context) {
          return storageOptions.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        },
        offset: const Offset(0, 40),
        child: Row(
          children: [
            Text(selectedStorage, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
            const Icon(Icons.arrow_drop_down, color: AppColors.white),
          ],
        ),
      ),
    );
  }

  // --- 정렬 기준 선택 드롭다운 ---
  Widget _buildSortButton() {
    return Row(
      children: [
        PopupMenuButton<String>(
          onSelected: (String value) {
            setState(() {
              selectedSortOrder = value;
            });
          },
          itemBuilder: (BuildContext context) {
            return sortOptions.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
          offset: const Offset(0, 40),
          child: Row(
            children: [
              Text(
                selectedSortOrder,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_drop_down, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }
}

// --- 음식 목록 아이템 카드 위젯 (이전과 동일) ---
class FoodListItemCard extends StatelessWidget {
  final FoodItem item;
  const FoodListItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        // 카드 자체에는 그림자 대신 테두리 사용 가능
        // border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl, width: 80, height: 80, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                  width: 80, height: 80, color: const Color(0xFFF2F2F7),
                  child: const Icon(Icons.fastfood_outlined, color: AppColors.textSecondary)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 6),
                Text('남은 수량   ${item.quantity}', style: const TextStyle(color: AppColors.primary, fontSize: 14)),
                const SizedBox(height: 4),
                Text('유통기한   ${item.expiryDate}', style: const TextStyle(color: AppColors.primary, fontSize: 14)),
              ],
            ),
          ),
          DdayTag(dDay: item.dDay),
        ],
      ),
    );
  }
}

// --- D-Day 태그 위젯 (이전과 동일) ---
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
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

// --- D-Day 태그 모양을 위한 Custom Clipper (이전과 동일) ---
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