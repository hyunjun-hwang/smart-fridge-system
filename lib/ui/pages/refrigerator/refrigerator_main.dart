import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';
import 'package:smart_fridge_system/data/repositories/food_repository.dart';
import 'package:smart_fridge_system/ui/pages/refrigerator/food_list_item_card.dart';
import 'package:smart_fridge_system/ui/pages/refrigerator/edit_food_item_dialog.dart'; // 수정용 다이얼로그 import

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  final FoodRepository _foodRepository = FoodRepository();
  Future<List<FoodItem>>? _foodItemsFuture;

  // 필터 및 정렬 상태 변수
  final List<String> categories = ['전체', '과일', '고기', '채소', '유제품'];
  String selectedCategory = '전체';

  final List<String> storageOptions = ['전체', '냉장실', '냉동고'];
  String selectedStorage = '전체';

  final List<String> sortOptions = [
    '유통기한 임박한 순', '유통기한 많이 남은순', '최근에 입고된 순', '예전에 입고된 순', '수량 많은 순', '수량 적은 순'
  ];
  String selectedSortOrder = '유통기한 임박한 순';

  @override
  void initState() {
    super.initState();
    _foodItemsFuture = _foodRepository.getFoodItems();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F2F7),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  spreadRadius: 1,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
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
          Expanded(
            child: FutureBuilder<List<FoodItem>>(
              future: _foodItemsFuture,
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

                // --- 필터링 및 정렬 로직 ---
                List<FoodItem> filteredItems = snapshot.data!;

                if (selectedStorage != '전체') {
                  filteredItems = filteredItems.where((item) => item.storage.displayName == selectedStorage).toList();
                }

                if (selectedCategory != '전체') {
                  filteredItems = filteredItems.where((item) => item.category == selectedCategory).toList();
                }

                filteredItems.sort((a, b) {
                  switch (selectedSortOrder) {
                    case '유통기한 많이 남은순':
                      return b.expiryDate.compareTo(a.expiryDate);
                    case '최근에 입고된 순':
                      return b.stockedDate.compareTo(a.stockedDate);
                    case '예전에 입고된 순':
                      return a.stockedDate.compareTo(b.stockedDate);
                    case '수량 많은 순':
                      return b.quantity.compareTo(a.quantity);
                    case '수량 적은 순':
                      return a.quantity.compareTo(b.quantity);
                    case '유통기한 임박한 순':
                    default:
                      return a.expiryDate.compareTo(b.expiryDate);
                  }
                });
                // --- 로직 끝 ---

                if (filteredItems.isEmpty) {
                  return const Center(child: Text('해당 조건의 음식이 없어요.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return FoodListItemCard(
                      item: item,
                      onTap: () => _showEditFoodDialog(item),
                    );
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

  void _showEditFoodDialog(FoodItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditFoodItemDialog(item: item);
      },
    );
  }

  Widget _buildSearchAndFilter() {
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
            Text(selectedStorage,
                style: const TextStyle(
                    color: AppColors.white, fontWeight: FontWeight.bold)),
            const Icon(Icons.arrow_drop_down, color: AppColors.white),
          ],
        ),
      ),
    );
  }

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
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_drop_down, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }
}