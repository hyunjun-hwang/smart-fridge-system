import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';
import 'package:smart_fridge_system/providers/food_provider.dart';
import 'package:smart_fridge_system/ui/pages/refrigerator/food_list_item_card.dart';
import 'package:smart_fridge_system/ui/pages/refrigerator/food_item_dialog.dart';

class FridgePage extends StatefulWidget {
  const FridgePage({super.key, this.pickMode = false}); // <- 추가
  final bool pickMode;

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String selectedCategory = '전체';
  String selectedStorage = '전체';
  String selectedSortOrder = '유통기한 임박한 순';

  final List<String> _categoryFilterOptions = [
    '전체',
    ...FoodCategory.values.map((e) => e.displayName)
  ];
  final List<String> _storageOptions = [
    '전체',
    ...StorageType.values.map((e) => e.displayName)
  ];
  final List<String> _sortOptions = [
    '유통기한 임박한 순',
    '유통기한 많이 남은순',
    '최근에 입고된 순',
    '예전에 입고된 순',
    '수량 많은 순',
    '수량 적은 순'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoodProvider>(context, listen: false).fetchFoodItems();
    });
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditFoodDialog(FoodItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // EditFoodItemDialog 대신 FoodItemDialog 호출
        return FoodItemDialog(item: item);
      },
    );
  }

  // --- ⭐️ 삭제 확인 다이얼로그 함수 추가 ⭐️ ---
  Future<bool?> _showDeleteConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('정말로 이 항목을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(false); // false 반환
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('삭제'),
              onPressed: () {
                Navigator.of(context).pop(true); // true 반환
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F2F7),
      child: Column(
        children: [
          _buildFilterAndSortSection(),
          Expanded(
            child: Consumer<FoodProvider>(
              builder: (context, provider, child) {
                // ... (로딩, 에러, 빈 상태 처리는 이전과 동일)
                if (provider.isLoading && provider.foodItems.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return Center(
                      child: Text('데이터를 불러오는 데 실패했습니다: ${provider.error}'));
                }
                if (provider.foodItems.isEmpty) {
                  return const Center(child: Text('냉장고에 음식이 없어요!'));
                }

                // ... (필터링, 정렬 로직은 이전과 동일)
                List<FoodItem> filteredItems = provider.foodItems;
                if (_searchQuery.isNotEmpty) {
                  filteredItems = filteredItems
                      .where((item) => item.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                      .toList();
                }
                if (selectedStorage != '전체') {
                  filteredItems = filteredItems
                      .where((item) => item.storage.displayName == selectedStorage)
                      .toList();
                }
                if (selectedCategory != '전체') {
                  filteredItems = filteredItems
                      .where(
                          (item) => item.category.displayName == selectedCategory)
                      .toList();
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
                      // --- ⭐️ onDelete 콜백 연결 ⭐️ ---
                      onDelete: () async {
                        final confirmed = await _showDeleteConfirmDialog();
                        if (confirmed == true && mounted) {
                          context.read<FoodProvider>().deleteFoodItem(item);
                        }
                      },
                    );
                  },
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UI 빌드 헬퍼 함수들은 이전과 동일 ---
  Widget _buildFilterAndSortSection() {
    return Container(
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
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '여기에 검색하세요.',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon:
                  const Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.textSecondary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                        color: AppColors.textSecondary, width: 1.5),
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
            itemCount: _categoryFilterOptions.length,
            itemBuilder: (context, index) {
              final categoryName = _categoryFilterOptions[index];
              final bool isSelected = selectedCategory == categoryName;
              return ChoiceChip(
                label: Text(categoryName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => selectedCategory = categoryName);
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
          return _storageOptions.map((String choice) {
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
            return _sortOptions.map((String choice) {
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