import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/record_entry_screen.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/food_detail_dialog.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/addfood_screen.dart'; // ✅ 내 음식 추가 화면

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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    recentSearches = [];
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

  String _norm(String s) {
    s = s.toLowerCase().replaceAll(RegExp(r'[_/()\-\[\]]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.trim();
  }

  double _relevanceScore(String name, String query) {
    final n = _norm(name);
    final q = _norm(query);
    if (q.isEmpty || n.isEmpty) return 0;

    final words = n.split(' ');
    double score = 0;
    if (n == q) score += 1000;
    if (words.contains(q)) score += 800;
    if (n.startsWith(q)) score += 700;
    if (n.contains(q)) score += 600;
    score += (200 - (n.length - q.length).abs()).clamp(0, 200);
    return score;
  }

  /// 식품안전나라 영양DB 호출 (FOOD_NM_KR 기준, getFoodNtrCpntDbInq02)
  Future<void> fetchFoodInfo(String keyword) async {
    if (mounted) setState(() => _isLoading = true);

    const String serviceKeyEncoding =
        'aC9p2FWLKdtxRQI%2FqYrTTCIl9LwAHXOl1ZJ3hcon7nFhVsWWxCck2f03W%2BMCrNj1b8F3wJSUzouE7pYGqHKRfQ%3D%3D';

    final String q = Uri.encodeQueryComponent(keyword);
    final Uri requestUrl = Uri.parse(
      'https://apis.data.go.kr/1471000/FoodNtrCpntDbInfo02/getFoodNtrCpntDbInq02'
          '?serviceKey=$serviceKeyEncoding&pageNo=1&numOfRows=20&type=json&FOOD_NM_KR=$q',
    );

    Map<String, dynamic>? data;
    http.Response? lastRes;

    try {
      final res = await http.get(requestUrl, headers: {'Accept': 'application/json'});
      lastRes = res;
      if (res.statusCode == 200) {
        data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        if (data?['header']?['resultCode'] != '00') data = null;
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);

    if (data == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API 호출 실패 (코드: ${lastRes?.statusCode ?? 'N/A'})')),
      );
      return;
    }

    final itemsData = data['body']?['items'];
    if (itemsData == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('검색 결과가 없습니다.')),
      );
      return;
    }

    final rows = itemsData is List ? itemsData : [itemsData];

    final parsed = <FoodItemn>[];
    for (final e in rows) {
      try {
        final itemData = e is Map && e.containsKey('item') ? e['item'] : e;
        if (itemData is Map) {
          parsed.add(FoodItemn.fromApiJson(Map<String, dynamic>.from(itemData)));
        }
      } catch (_) {}
    }

    // 정렬: 관련도 → 이름 짧은 순 → 가나다 → 칼로리 낮은 순
    parsed.sort((a, b) {
      final qa = _relevanceScore(a.name, keyword);
      final qb = _relevanceScore(b.name, keyword);
      if (qa != qb) return qb.compareTo(qa);
      final lenCmp = a.name.length.compareTo(b.name.length);
      if (lenCmp != 0) return lenCmp;
      final nameCmp = a.name.compareTo(b.name);
      if (nameCmp != 0) return nameCmp;
      return a.calories.compareTo(b.calories);
    });

    if (!mounted) return;
    setState(() {
      recentSearches = parsed;
      selectedIndex = 0;
    });
  }

  void _addFoodAndReturn(FoodItemn food) {
    final provider = Provider.of<DailyNutritionProvider>(context, listen: false);
    provider.addFood(widget.mealType, widget.date, food);

    if (!mounted) return;
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
          '음식 검색',
          style: TextStyle(color: Color(0xFF003508), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 탭
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
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
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey[600],
                      ),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : Colors.grey.shade300,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ✅ 검색 탭에서만 검색창/버튼 보이기
          if (selectedIndex == 0) ...[
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
                    hintText: '음식 이름을 검색하세요.',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (keyword) {
                    if (keyword.trim().isNotEmpty) {
                      fetchFoodInfo(keyword.trim());
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    final keyword = _searchController.text.trim();
                    if (keyword.isNotEmpty) {
                      FocusScope.of(context).unfocus();
                      fetchFoodInfo(keyword);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003508),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                      : const Text('검색'),
                ),
              ),
            ),
          ],

          // ✅ 내 음식 탭에서만 “내 음식 추가/레시피에서 추가” 버튼 노출
          if (selectedIndex == 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD5E8C6),
                        foregroundColor: const Color(0xFF003508),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('내 음식 추가하기'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: 레시피에서 추가하기 동작 연결
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('레시피에서 추가하기: 구현 예정')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD5E8C6),
                        foregroundColor: const Color(0xFF003508),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('레시피에서 추가하기'),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF003508)))
                : Builder(
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
    if (items.isEmpty) {
      return const Center(child: Text('표시할 항목이 없습니다.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isFavorite = favoriteItems.any((f) => f.name == item.name);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD5E8C6), width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('1회 제공량(${item.amount}g)당 열량: ${item.calories.toStringAsFixed(1)} kcal'),
            trailing: IconButton(
              icon: Icon(isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.amber : Colors.grey),
              onPressed: () {
                setState(() {
                  if (isFavorite) {
                    favoriteItems.removeWhere((f) => f.name == item.name);
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