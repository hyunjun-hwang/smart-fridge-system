import 'package:flutter/material.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/food_detail_dialog.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/record_entry_screen.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/addfood_screen.dart'; // ✅ 새 음식 추가 화면 연결

class SearchFoodScreen extends StatefulWidget {
  final String mealType;
  final DateTime date;

  const SearchFoodScreen({super.key, required this.mealType, required this.date});

  @override
  State<SearchFoodScreen> createState() => _SearchFoodScreenState();
}

class _SearchFoodScreenState extends State<SearchFoodScreen> {
  int selectedIndex = 0;
  final List<String> filters = ['검색', '즐겨찾기', '내 음식', '냉장고'];
  final TextEditingController _searchController = TextEditingController();

  List<FoodItem> recentSearches = [
    FoodItem(
      name: '사과',
      quantity: 2,
      unit: Unit.count,
      expiryDate: DateTime(2025, 8, 15),
      stockedDate: DateTime(2025, 7, 24),
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/415/415682.png',
      category: '과일',
      storage: StorageType.fridge,
    ),
  ];

  List<FoodItem> favoriteItems = [];

  List<FoodItem> fridgeItems = [
    FoodItem(
      name: '사과',
      quantity: 2,
      unit: Unit.count,
      expiryDate: DateTime(2025, 8, 15),
      stockedDate: DateTime(2025, 7, 24),
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/415/415682.png',
      category: '과일',
      storage: StorageType.fridge,
    ),
    FoodItem(
      name: '우유',
      quantity: 1,
      unit: Unit.count,
      expiryDate: DateTime(2025, 8, 2),
      stockedDate: DateTime(2025, 7, 25),
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/1046/1046870.png',
      category: '유제품',
      storage: StorageType.fridge,
    ),
  ];

  void _addFoodAndReturn(FoodItemn food) {
    Navigator.pop(context, food);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003508)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '영양소',
          style: TextStyle(color: Color(0xFF003508), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Color(0xFF003508)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(filters.length, (index) {
                final isSelected = selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filters[index]),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedIndex = index),
                    selectedColor: const Color(0xFFD5E8C6),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(color: isSelected ? const Color(0xFF003508) : Colors.black54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? const Color(0xFFD5E8C6) : Colors.grey.shade300),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '여기에 검색하세요.',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (selectedIndex == 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD5E8C6),
                        foregroundColor: const Color(0xFF003508),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        final newFood = await Navigator.push<FoodItemn>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddFoodScreen()),
                        );
                        if (newFood != null) {
                          // 새 음식 항목을 recentSearches에 추가
                          setState(() {
                            recentSearches.add(
                              FoodItem(
                                name: newFood.name,
                                quantity: newFood.count.toInt(),
                                unit: Unit.count,
                                expiryDate: DateTime.now().add(const Duration(days: 7)),
                                stockedDate: DateTime.now(),
                                imageUrl: newFood.imagePath,
                                category: '기타',
                                storage: StorageType.fridge,
                              ),
                            );
                          });
                        }
                      },
                      child: const Text('새 음식 추가'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD5E8C6),
                        foregroundColor: const Color(0xFF003508),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: const Text('레시피에서 추가'),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: Builder(
              builder: (_) {
                if (selectedIndex == 0) {
                  return _buildFoodList(recentSearches);
                } else if (selectedIndex == 1) {
                  return _buildFoodList(favoriteItems);
                } else if (selectedIndex == 3) {
                  return _buildFoodList(fridgeItems);
                } else {
                  return const Center(child: Text('최근에 추가한 항목이 없습니다.', style: TextStyle(color: Colors.grey)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(List<FoodItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isFavorite = favoriteItems.contains(item);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD5E8C6), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Image.network(item.imageUrl, width: 48, height: 48),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('수량: ${item.quantity}${item.unit == Unit.count ? '개' : 'g'}'),
            trailing: IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  if (isFavorite) {
                    favoriteItems.remove(item);
                  } else {
                    favoriteItems.add(item);
                  }
                });
              },
            ),
            onTap: () {
              final foodItemn = FoodItemn(
                name: item.name,
                calories: 52,
                carbohydrates: 13.8,
                protein: 0.3,
                fat: 0.2,
                amount: 100,
                count: 1.0,
                imagePath: item.imageUrl,
              );

              showFoodDetailDialog(
                context: context,
                item: foodItemn,
                onAdd: _addFoodAndReturn,
              );
            },
          ),
        );
      },
    );
  }
}
