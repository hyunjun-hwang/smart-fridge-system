import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/record_entry_screen.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/addfood_screen.dart';
import 'package:smart_fridge_system/ui/pages/recipe/recipe_main_page.dart';

// ✅ 냉장고(재고) 연동 추가
import 'package:smart_fridge_system/providers/food_provider.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';

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
  // ---------- Colors ----------
  static const Color _primary = Color(0xFF003508);
  static const Color _chipSel = Color(0xFFD5E8C6);

  // ---------- Tabs ----------
  int selectedIndex = 0;
  final List<String> filters = ['검색', '즐겨찾기', '내 음식', '냉장고'];
  final TextEditingController _searchController = TextEditingController();

  // ---------- Data ----------
  List<FoodItemn> recentSearches = [];
  List<FoodItemn> myFoods = [];
  List<FoodItemn> favoriteItems = [];

  // 냉장고 탭 최초 진입 시 한 번만 fetch
  bool _fridgeInitOnce = false;

  // ---------- Loading / Pagination ----------
  bool _isLoading = false;
  final int _pageSize = 100; // API가 보통 허용하는 최대
  int _pageNo = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _currentQuery = '';

  // ---------- API key (encoded) ----------
  static const String _serviceKeyEncoding =
      'aC9p2FWLKdtxRQI%2FqYrTTCIl9LwAHXOl1ZJ3hcon7nFhVsWWxCck2f03W%2BMCrNj1b8F3wJSUzouE7pYGqHKRfQ%3D%3D';

  @override
  void initState() {
    super.initState();
    recentSearches = [];
  }

  // ------------------------
  // 문자열 정규화 & 관련도 점수
  // ------------------------
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

  // 일반식품 우선 점수
  double _genericPreferenceScore(String name) {
    final n = _norm(name);

    final hasDigits = RegExp(r'\d').hasMatch(n);
    final hasUnit = RegExp(r'(g|ml|kg|l|kcal|mg)\b').hasMatch(n);
    final hasBracket =
        n.contains('(') || n.contains(')') || n.contains('[') || n.contains(']');
    final hasBrandKo = n.contains('㈜') || n.contains('(주)') || n.contains('주식회사');
    final hasBrandEn = RegExp(r'\b(co|corp|ltd|inc)\b').hasMatch(n);
    final hasFlavor =
    RegExp(r'(맛|향|오리지널|라이트|스페셜|프리미엄)').hasMatch(n);
    final hasProductCue =
    RegExp(r'(스낵|라면|음료|드링크|시리얼|바|비스킷|쿠키|캔|펫병|팩|세트)').hasMatch(n);

    final words = n.split(' ').where((w) => w.isNotEmpty).toList();
    final wordCount = words.length;

    double score = 0;
    if (wordCount <= 2) score += 2.0;
    if (n.length <= 6) score += 1.5;
    if (wordCount == 1) score += 1.0;

    if (hasDigits) score -= 2.0;
    if (hasUnit) score -= 1.5;
    if (hasBracket) score -= 1.0;
    if (hasBrandKo || hasBrandEn) score -= 2.0;
    if (hasFlavor) score -= 1.0;
    if (hasProductCue) score -= 1.0;

    if ((hasBrandKo || hasBrandEn) && hasDigits) score -= 1.5;

    return score;
  }

  void _sortFoods(List<FoodItemn> list, String query) {
    list.sort((a, b) {
      final relA = _relevanceScore(a.name, query);
      final relB = _relevanceScore(b.name, query);

      final genA = _genericPreferenceScore(a.name);
      final genB = _genericPreferenceScore(b.name);

      final scoreA = relA + genA * 100;
      final scoreB = relB + genB * 100;

      if (scoreA != scoreB) return scoreB.compareTo(scoreA);

      final lenCmp = a.name.length.compareTo(b.name.length);
      if (lenCmp != 0) return lenCmp;

      final nameCmp = a.name.compareTo(b.name);
      if (nameCmp != 0) return nameCmp;

      return a.calories.compareTo(b.calories);
    });
  }

  // ----------------------------------------
  // 한 페이지 호출 (null-safe 맵 접근)
  // ----------------------------------------
  Future<List<FoodItemn>> _fetchPage(String keyword, int pageNo) async {
    final String q = Uri.encodeQueryComponent(keyword.trim());
    final Uri requestUrl = Uri.parse(
      'https://apis.data.go.kr/1471000/FoodNtrCpntDbInfo02/getFoodNtrCpntDbInq02'
          '?serviceKey=$_serviceKeyEncoding'
          '&pageNo=$pageNo'
          '&numOfRows=$_pageSize'
          '&type=json'
          '&FOOD_NM_KR=$q',
    );

    final res = await http
        .get(requestUrl, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(res.bodyBytes));

    bool okCode = false;
    Map<String, dynamic>? bodyMap;

    if (decoded is Map<String, dynamic>) {
      final header = decoded['header'];
      if (header is Map) {
        final rc = header['resultCode'];
        okCode = rc?.toString() == '00';
      }
      final body = decoded['body'];
      if (body is Map<String, dynamic>) {
        bodyMap = body;
      }
    }

    if (!okCode) {
      throw Exception('API resultCode != 00');
    }

    final dynamic itemsData = bodyMap?['items'];
    final List raw = itemsData == null
        ? const []
        : (itemsData is List ? itemsData : [itemsData]);

    final parsed = <FoodItemn>[];
    for (final e in raw) {
      try {
        if (e is Map) {
          final item = e.containsKey('item') ? e['item'] : e;
          if (item is Map) {
            parsed.add(FoodItemn.fromApiJson(Map<String, dynamic>.from(item)));
          }
        }
      } catch (_) {}
    }
    return parsed;
  }

  // ----------------------------------------
  // 최초 검색(리셋)
  // ----------------------------------------
  Future<void> fetchFoodInfo(String keyword) async {
    final kw = keyword.trim();
    if (kw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('검색어를 입력하세요.')),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _currentQuery = kw;
        _pageNo = 1;
        _hasMore = true;
        recentSearches = [];
      });
    }

    try {
      final first = await _fetchPage(kw, 1);
      if (!mounted) return;

      // 정렬 + 중복 제거
      final seen = <String>{};
      final merged = <FoodItemn>[];
      for (final f in first) {
        if (seen.add(f.name)) merged.add(f);
      }
      _sortFoods(merged, kw);

      setState(() {
        recentSearches = merged;
        _hasMore = first.length >= _pageSize;
        _isLoading = false;
        selectedIndex = 0; // 검색 탭 유지
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API 호출 실패: $e')),
      );
    }
  }

  // ----------------------------------------
  // 더 불러오기
  // ----------------------------------------
  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _currentQuery.isEmpty) return;

    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _pageNo + 1;
      final more = await _fetchPage(_currentQuery, nextPage);
      if (!mounted) return;

      // 합치기 + 중복 제거 + 정렬
      final seen = <String>{for (final f in recentSearches) f.name};
      final added = <FoodItemn>[];
      for (final f in more) {
        if (seen.add(f.name)) added.add(f);
      }
      final merged = [...recentSearches, ...added];
      _sortFoods(merged, _currentQuery);

      setState(() {
        recentSearches = merged;
        _pageNo = nextPage;
        _hasMore = more.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('더 불러오기 실패: $e')),
      );
    }
  }

  // ----------------------------------------
  // 선택 반영
  // ----------------------------------------
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

  // 하단 시트: 영양 성분 + 수량 선택 + 추가하기
  void _openFoodSheet(FoodItemn base) {
    double count = 1.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            final totKcal = (base.calories * count);

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    base.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 18, color: _primary),
                  ),
                  const SizedBox(height: 8),

                  const Text('영양성분', style: TextStyle(
                      fontWeight: FontWeight.w700, color: _primary)),
                  const SizedBox(height: 8),

                  _infoRow('칼로리', '${base.calories.toStringAsFixed(1)} kcal'),
                  _infoRow('탄수화물', '${base.carbohydrates.toStringAsFixed(1)} g'),
                  _infoRow('단백질', '${base.protein.toStringAsFixed(1)} g'),
                  _infoRow('지방', '${base.fat.toStringAsFixed(1)} g'),

                  const SizedBox(height: 14),
                  Container(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Text('수량', style: TextStyle(fontWeight: FontWeight.w700, color: _primary)),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('총 칼로리', style: TextStyle(color: Colors.black54)),
                          Text(
                            '${totKcal.toStringAsFixed(1)} kcal',
                            style: const TextStyle(
                                color: _primary, fontWeight: FontWeight.w800, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _qtyBtn(Icons.remove, () {
                        setState(() {
                          count = (count - 0.5).clamp(0.5, 99.0);
                        });
                      }),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: _chipSel),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Text(count.toStringAsFixed(1),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, color: _primary)),
                      ),
                      _qtyBtn(Icons.add, () {
                        setState(() {
                          count = (count + 0.5).clamp(0.5, 99.0);
                        });
                      }),
                    ],
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // 시트 닫기
                        _addFoodAndReturn(base.copyWith(count: count));
                      },
                      child: const Text('추가하기'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 냉장고 아이템 선택 시 작업 시트 (검색 or 바로 추가)
  void _openFridgeActionSheet(FoodItem fi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(fi.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18, color: _primary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        _searchController.text = fi.name;
                        await fetchFoodInfo(fi.name); // 검색 실행 + 검색 탭 유지
                        setState(() => selectedIndex = 0); // 혹시 모를 탭 강제
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _chipSel),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('영양 검색해서 추가'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // 영양정보가 없는 상태로 바로 추가 (0 기준)
                        final dummy = FoodItemn(
                          name: fi.name,
                          calories: 0,
                          carbohydrates: 0,
                          protein: 0,
                          fat: 0,
                          amount: 100,
                          count: 1.0,
                        );
                        _openFoodSheet(dummy);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('바로 추가(영양정보 없음)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '※ 냉장고 재고는 영양정보가 없을 수 있어요. 정확한 기록을 원하면 영양 검색을 사용하세요.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Ink(
      decoration: BoxDecoration(
        border: Border.all(color: _chipSel),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: _primary),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // ‘냉장고’ 탭으로 전환 시 1회만 fetch
    if (selectedIndex == 3 && !_fridgeInitOnce) {
      _fridgeInitOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<FoodProvider>().fetchFoodItems();
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '음식 검색',
          style: TextStyle(color: _primary, fontWeight: FontWeight.bold),
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
                      selectedColor: _chipSel,
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

          // 검색 탭에서만 검색창/버튼
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
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: '음식 이름을 검색하세요.',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                    backgroundColor: _primary,
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
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3),
                  )
                      : const Text('검색'),
                ),
              ),
            ),
          ],

          // 내 음식 탭에서만 버튼 노출
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
                          setState(() => myFoods.add(newFood));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _chipSel,
                        foregroundColor: _primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('내 음식 추가하기'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final FoodItemn? selectedFromRecipe =
                        await Navigator.push<FoodItemn>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RecipeMainPage(pickMode: true),
                          ),
                        );
                        if (selectedFromRecipe != null) {
                          _addFoodAndReturn(selectedFromRecipe);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _chipSel,
                        foregroundColor: _primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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
                ? const Center(child: CircularProgressIndicator(color: _primary))
                : Builder(
              builder: (_) {
                if (selectedIndex == 0) {
                  return _buildFoodList(
                    recentSearches,
                    showLoadMore: _hasMore,
                    onLoadMore: _loadMore,
                    loadingMore: _isLoadingMore,
                  );
                }
                if (selectedIndex == 1) return _buildFoodList(favoriteItems);
                if (selectedIndex == 2) return _buildFoodList(myFoods);
                if (selectedIndex == 3) {
                  // ✅ 냉장고 탭: FoodProvider 데이터 표시
                  return Consumer<FoodProvider>(
                    builder: (context, fp, _) {
                      if (fp.isLoading && fp.foodItems.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (fp.error != null) {
                        return Center(
                            child: Text('냉장고 데이터를 불러오지 못했습니다: ${fp.error}'));
                      }
                      if (fp.foodItems.isEmpty) {
                        return const Center(child: Text('냉장고에 음식이 없어요!'));
                      }
                      return _buildFridgeList(fp.foodItems);
                    },
                  );
                }
                return const Center(child: Text('항목이 없습니다.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  // 검색/즐겨찾기/내 음식 공용 리스트 + "더 보기"
  Widget _buildFoodList(
      List<FoodItemn> items, {
        bool showLoadMore = false,
        VoidCallback? onLoadMore,
        bool loadingMore = false,
      }) {
    if (items.isEmpty) {
      return const Center(child: Text('표시할 항목이 없습니다.'));
    }

    final extra = showLoadMore ? 1 : 0;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length + extra,
      itemBuilder: (context, index) {
        // 마지막 셀: 더 보기
        if (showLoadMore && index == items.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: loadingMore
                  ? const CircularProgressIndicator(color: _primary)
                  : ElevatedButton(
                onPressed: onLoadMore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('더 보기'),
              ),
            ),
          );
        }

        final item = items[index];
        final isFavorite = favoriteItems.any((f) => f.name == item.name);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _chipSel, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            title: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '열량: ${item.calories.toStringAsFixed(1)} kcal  •  탄 ${item.carbohydrates.toStringAsFixed(1)}g  단 ${item.protein.toStringAsFixed(1)}g  지 ${item.fat.toStringAsFixed(1)}g',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
            onTap: () => _openFoodSheet(item),
          ),
        );
      },
    );
  }

  // ✅ 냉장고(재고) 전용 리스트: FoodItem 기반
  Widget _buildFridgeList(List<FoodItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final fi = items[index];
        final sub = StringBuffer();
        // 보조 정보 구성 (보유 수량 / 보관 / 유통기한)
        sub.write('수량 ${fi.quantity}');
        sub.write(' • ${fi.storage.displayName}');
        sub.write(' • 유통기한 ${_fmtDate(fi.expiryDate)}');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _chipSel, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            title: Text(
              fi.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              sub.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openFridgeActionSheet(fi),
          ),
        );
      },
    );
  }

  String _fmtDate(DateTime d) {
    // yyyy-MM-dd
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  // 공용 간단 Row
  static Widget _infoRow(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: Colors.black54)),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
