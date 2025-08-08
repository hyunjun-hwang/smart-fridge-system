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

  const SearchFoodScreen({
    super.key,
    required this.mealType,
    required this.date,
  });

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

  /// ✅ 500 회피 + 다중 URL 시도 API 호출
  Future<void> fetchFoodInfo(String foodName) async {
    const String serviceKeyEncoding =
        'aC9p2FWLKdtxRQI%2FqYrTTCIl9LwAHXOl1ZJ3hcon7nFhVsWWxCck2f03W%2BMCrNj1b8F3wJSUzouE7pYGqHKRfQ%3D%3D';
    const String? serviceKeyDecoding = null; // 필요 시 Decoding 키 넣기

    final String q = Uri.encodeQueryComponent(foodName);

    final List<Uri> tries = [
      Uri.parse(
          'https://apis.data.go.kr/1471000/FoodNtrCpntDbInfo02/getFoodNtrCpntList?serviceKey=$serviceKeyEncoding&pageNo=1&numOfRows=10&type=json&DESC_KOR=$q'),
      Uri.parse(
          'https://apis.data.go.kr/1471000/FoodNtrCpntDbInfo02/getFoodNtrCpntDbInfo02?serviceKey=$serviceKeyEncoding&pageNo=1&numOfRows=10&type=json&DESC_KOR=$q'),
      Uri.parse(
          'http://apis.data.go.kr/1471000/FoodNtrCpntDbInfo02/getFoodNtrCpntList?serviceKey=$serviceKeyEncoding&pageNo=1&numOfRows=10&type=json&DESC_KOR=$q'),
      if (serviceKeyDecoding != null)
        Uri.parse(
            'https://apis.data.go.kr/1471000/FoodNtrCpntDbInfo02/getFoodNtrCpntList?serviceKey=$serviceKeyDecoding&pageNo=1&numOfRows=10&type=json&DESC_KOR=$q'),
    ];

    Map<String, dynamic>? data;
    http.Response? lastRes;

    for (final u in tries) {
      try {
        debugPrint('🔎 요청: $u');
        final res = await http.get(u, headers: {'Accept': 'application/json'});
        lastRes = res;
        debugPrint('📦 상태코드: ${res.statusCode}');
        debugPrint(
            '📨 바디 미리보기: ${utf8.decode(res.bodyBytes).substring(0, res.bodyBytes.isEmpty ? 0 : (res.bodyBytes.length > 200 ? 200 : res.bodyBytes.length))}');

        if (res.statusCode == 200) {
          data = jsonDecode(utf8.decode(res.bodyBytes))
          as Map<String, dynamic>;
          break;
        } else if (res.statusCode == 500) {
          continue; // 다음 시도
        } else {
          continue; // 404, 403 등도 다음 시도
        }
      } catch (e) {
        debugPrint('⚠️ 요청 예외: $e');
        continue;
      }
    }

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API 호출 실패 (마지막 코드: ${lastRes?.statusCode ?? 'N/A'})')),
      );
      return;
    }

    final rows = data['body']?['items'] ?? data['I2790']?['row'];
    if (rows is! List || rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('검색 결과가 없습니다.')),
      );
      return;
    }

    List<FoodItemn> parsed = [];
    for (final e in rows) {
      try {
        parsed.add(FoodItemn.fromApiJson(Map<String, dynamic>.from(e as Map)));
      } catch (_) {}
    }

    if (parsed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('결과 파싱 실패')),
      );
      return;
    }

    setState(() {
      recentSearches = parsed;
      selectedIndex = 0;
    });
  }

  void _addFoodAndReturn(FoodItemn food) {
    final provider =
    Provider.of<DailyNutritionProvider>(context, listen: false);
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
          style: TextStyle(
            color: Color(0xFF003508),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 상단 필터
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
                  ),
                );
              }),
            ),
          ),
          // 검색창
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
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          // 검색 버튼
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
              ),
              child: const Text('검색'),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Builder(
              builder: (_) {
                if (selectedIndex == 0) return _buildFoodList(recentSearches);
                if (selectedIndex == 1) return _buildFoodList(favoriteItems);
                if (selectedIndex == 2) return _buildFoodList(myFoods);
                if (selectedIndex == 3) return _buildFoodList(fridgeItems);
                return const Center(child: Text('항목이 없습니다.'));
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
          ),
          child: ListTile(
            title: Text(item.name),
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
