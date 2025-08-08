import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/record_entry_screen.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/addfood_screen.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/food_detail_dialog.dart';
import 'package:smart_fridge_system/api/nutrition_api.dart'; // 여기에는 fetchFoodInfoFromJson 함수가 있어야 합니다

class SearchFoodScreen extends StatefulWidget {
  final String mealType;
  final DateTime date;

  const SearchFoodScreen({super.key, required this.mealType, required this.date});

  @override
  State<SearchFoodScreen> createState() => _SearchFoodScreenState();
}

class _SearchFoodScreenState extends State<SearchFoodScreen> {
  final TextEditingController _searchController = TextEditingController();
  int selectedIndex = 0;
  final List<String> filters = ['검색', '즐겨찾기', '내 음식', '냉장고'];

  List<FoodItemn> recentSearches = [];
  List<FoodItemn> myFoods = [];
  List<FoodItemn> favoriteItems = [];
  List<FoodItemn> fridgeItems = [];

  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);

    try {
      final List<FoodItemn> result = await fetchFoodInfoFromJson(query);
      setState(() {
        recentSearches = result;
        selectedIndex = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ API 오류: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  void _addFoodAndReturn(FoodItemn food) {
    final provider = Provider.of<DailyNutritionProvider>(context, listen: false);
    provider.addFood(widget.mealType, widget.date, food);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RecordEntryScreen(mealType: widget.mealType, date: widget.date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = selectedIndex == 0
        ? recentSearches
        : selectedIndex == 1
        ? favoriteItems
        : selectedIndex == 2
        ? myFoods
        : fridgeItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003508)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('영양소 검색', style: TextStyle(color: Color(0xFF003508))),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildSearchField(),
          _buildSearchButton(),
          if (selectedIndex == 2) _buildAddButtons(),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Expanded(child: _buildFoodList(list)),
        ],
      ),
    );
  }

  Widget _buildFilterChips() => Padding(
    padding: const EdgeInsets.all(12),
    child: Wrap(
      spacing: 8,
      children: List.generate(filters.length, (index) {
        final selected = selectedIndex == index;
        return ChoiceChip(
          label: Text(filters[index]),
          selected: selected,
          onSelected: (_) => setState(() => selectedIndex = index),
          selectedColor: const Color(0xFFD5E8C6),
          backgroundColor: Colors.white,
          labelStyle: TextStyle(color: selected ? Color(0xFF003508) : Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: selected ? Color(0xFFD5E8C6) : Colors.grey.shade300),
          ),
        );
      }),
    ),
  );

  Widget _buildSearchField() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: '음식을 입력하세요',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    ),
  );

  Widget _buildSearchButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ElevatedButton(
      onPressed: () {
        final keyword = _searchController.text.trim();
        if (keyword.isNotEmpty) _performSearch(keyword);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF003508),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('검색'),
    ),
  );

  Widget _buildAddButtons() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton(
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
            onPressed: () {},
            child: const Text('레시피에서 추가'),
          ),
        ),
      ],
    ),
  );

  Widget _buildFoodList(List<FoodItemn> items) {
    if (items.isEmpty) return const Center(child: Text('결과 없음'));

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
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: const Icon(Icons.fastfood, size: 40, color: Colors.grey), // ✅ imagePath 제거
            title: Text(item.name),
            subtitle: Text('열량: ${item.calories.toStringAsFixed(1)} kcal'),
            trailing: IconButton(
              icon: Icon(isFavorite ? Icons.star : Icons.star_border),
              color: isFavorite ? Colors.amber : Colors.grey,
              onPressed: () {
                setState(() {
                  isFavorite ? favoriteItems.remove(item) : favoriteItems.add(item);
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
