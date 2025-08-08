import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/record_entry_screen.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/addfood_screen.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/food_detail_dialog.dart';

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

  List<FoodItemn> recentSearches = [];
  List<FoodItemn> myFoods = [];
  List<FoodItemn> favoriteItems = [];
  List<FoodItemn> fridgeItems = [];

  @override
  void initState() {
    super.initState();

    // 예시 데이터
    recentSearches = [
      FoodItemn(
        name: '사과',
        calories: 52,
        carbohydrates: 14.0,
        protein: 0.3,
        fat: 0.2,
        amount: 100,
        count: 1.0,
      ),
    ];
    fridgeItems = [
      FoodItemn(
        name: '우유',
        calories: 42,
        carbohydrates: 5.0,
        protein: 3.4,
        fat: 1.0,
        amount: 100,
        count: 1.0,
      ),
    ];
  }

  Future<void> fetchFoodInfo(String foodName) async {
    const String apiKey = 'aC9p2FWLKdtxRQI%2FqYrTTCIl9LwAHXOl1ZJ3hcon7nFhVsWWxCck2f03W%2BMCrNj1b8F3wJSUzouE7pYGqHKRfQ%3D%3D';
    final String baseUrl = 'https://openapi.foodsafetykorea.go.kr/api';
    final String endpoint = '$baseUrl/$apiKey/I2790/json/1/5/DESC_KOR=$foodName';

    try {
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['I2790']?['row'] != null) {
          final List<FoodItemn> newItems = [];

          for (var item in data['I2790']['row']) {
            final name = item['DESC_KOR'] ?? '';
            final cal = double.tryParse(item['NUTR_CONT1'] ?? '0') ?? 0;
            final carbs = double.tryParse(item['NUTR_CONT2'] ?? '0') ?? 0;
            final protein = double.tryParse(item['NUTR_CONT3'] ?? '0') ?? 0;
            final fat = double.tryParse(item['NUTR_CONT4'] ?? '0') ?? 0;

            newItems.add(FoodItemn(
              name: name,
              calories: cal,
              carbohydrates: carbs,
              protein: protein,
              fat: fat,
              amount: 100,
              count: 1.0,
            ));
          }

          setState(() {
            recentSearches = newItems;
            selectedIndex = 0;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('검색 결과가 없습니다.')),
          );
        }
      } else {
        print('응답 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }

  void _addFoodAndReturn(FoodItemn food) {
    final provider = Provider.of<DailyNutritionProvider>(context, listen: false);
    provider.addFood(widget.mealType, widget.date, food);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RecordEntryScreen(
          mealType: widget.mealType,
          date: widget.date,
        ),
      ),
    );
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                final keyword = _searchController.text.trim();
                if (keyword.isNotEmpty) {
                  fetchFoodInfo(keyword);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003508),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('검색'),
            ),
          ),
          const SizedBox(height: 8),
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
                          setState(() {
                            myFoods.add(newFood);
                            recentSearches.add(newFood);
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
                if (selectedIndex == 0) return _buildFoodList(recentSearches);
                if (selectedIndex == 1) return _buildFoodList(favoriteItems);
                if (selectedIndex == 2) return _buildFoodList(myFoods);
                if (selectedIndex == 3) return _buildFoodList(fridgeItems);
                return const Center(child: Text('항목이 없습니다.', style: TextStyle(color: Colors.grey)));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(List<FoodItemn> items) {
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
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('열량: ${item.calories.toStringAsFixed(1)} kcal'),
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
              showFoodDetailDialog(
                context: context,
                item: item,
                onAdd: _addFoodAndReturn,
              );
            },
          ),
        );
      },
    );
  }
}
