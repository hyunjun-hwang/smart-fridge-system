import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';
import 'package:smart_fridge_system/data/repositories/food_repository.dart';
import 'package:smart_fridge_system/ui/widgets/food_list_item_card.dart'; // <-- 새로 추가된 import

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  // 데이터 로직을 담고 있는 Repository 인스턴스 생성
  final FoodRepository _foodRepository = FoodRepository();
  // 데이터를 비동기적으로 담아둘 Future 변수 선언
  Future<List<FoodItem>>? _foodItemsFuture;

  // 필터 및 정렬 상태 관리 변수
  final List<String> categories = ['전체', '과일', '고기', '채소', '유제품'];
  String selectedCategory = '전체';

  final List<String> storageOptions = ['냉장실', '냉동고', '실온'];
  String selectedStorage = '냉장실';

  final List<String> sortOptions = ['유통기한 임박한 순', '유통기한 많이 남은순', '최근에 입고된 순', '예전에 입고된 순', '수량 많은 순', '수량 적은 순'];
  String selectedSortOrder = '유통기한 임박한 순';

  @override
  void initState() {
    super.initState();
    // 위젯이 처음 생성될 때 데이터 로딩 시작
    _foodItemsFuture = _foodRepository.getFoodItems();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F2F7),
      child: Column(
        children: [
          // 필터 영역
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
          // 목록 부분
          Expanded(
            child: FutureBuilder<List<FoodItem>>(
              future: _foodItemsFuture, // 이 Future의 상태 변화를 감지
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('데이터를 불러오는 데 실패했습니다: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('냉장고에 음식이 없어요!'));
                }

                final foodItems = snapshot.data!;
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: foodItems.length,
                  itemBuilder: (context, index) {
                    // 분리된 위젯을 여기서 사용합니다.
                    return FoodListItemCard(item: foodItems[index]);
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 상단 검색 및 필터 위젯 ---
  Widget _buildSearchAndFilter() {
    // ... (이하 동일, 내용은 생략)
    return Column(
      children: [
        Row(
          children: [
            _buildStorageDropdown(),
            const SizedBox(width: 8),
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
    // ... (이하 동일, 내용은 생략)
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
    // ... (이하 동일, 내용은 생략)
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