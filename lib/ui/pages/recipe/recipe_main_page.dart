import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:smart_fridge_system/data/models/recipe_model.dart';
import 'recipe_detail_page.dart';

// ✅ 결과 전달 타입(레시피 선택 시 반환)
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';

// ✅ 냉장고 재고 이름 읽기 위한 Provider (UI 변경 없음)
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/providers/food_provider.dart';

class RecipeMainPage extends StatefulWidget {
  final bool pickMode; // false: 보기, true: 상세에서 FoodItemn 선택 후 상위로 반환
  const RecipeMainPage({super.key, this.pickMode = false});

  @override
  State<RecipeMainPage> createState() => _RecipeMainPageState();
}

class _RecipeMainPageState extends State<RecipeMainPage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = '추천 레시피 순';

  bool _isLoading = false;
  bool _didAutoLoad = false; // 재고가 늦게 로드돼도 초기 추천 1회 자동 실행
  List<Recipe> recipes = [];

  // ✅ 페이지네이션 상태 (검색 모드에서만 사용)
  final int _pageSize = 20;     // 한 번에 20개씩
  int _nextStart = 1;           // 다음 요청의 시작 index
  bool _hasMore = false;        // 더 불러올 게 있는지
  bool _isLoadingMore = false;  // 더보기 로딩
  String _currentQuery = '';    // 현재 검색어

  // ✅ 공공데이터 경로형 포맷 정보
  static const String _keyId = 'ff4910709e05408eba7c';
  static const String _base = 'https://openapi.foodsafetykorea.go.kr/api';
  static const String _serviceId = 'COOKRCP01';
  static const String _dataType = 'json';
  static const Duration _netTimeout = Duration(seconds: 20);

  // ---------------- 매칭 유틸 ----------------
  String _norm(String s) {
    final noParen = s.replaceAll(RegExp(r'\([^)]*\)'), '');
    return noParen.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\uac00-\ud7a3]'), '');
  }

  ({int match, int missing}) _matchScore(Recipe r, Set<String> fridgeNamesNorm) {
    final tokens = r.ingredients.keys.map(_norm).where((e) => e.isNotEmpty).toList();
    int match = 0;
    for (final tok in tokens) {
      final hit = fridgeNamesNorm.any((f) => f.contains(tok) || tok.contains(f));
      if (hit) match++;
    }
    final missing = (tokens.length - match).clamp(0, 1 << 30);
    return (match: match, missing: missing);
  }

  void _applyFridgeAwareSort(Set<String> fridgeNamesNorm) {
    if (recipes.isEmpty) return;
    if (_sortOption == '칼로리 순') {
      recipes.sort((a, b) => a.kcal.compareTo(b.kcal));
      return;
    }
    if (fridgeNamesNorm.isEmpty) {
      recipes.sort((a, b) => a.title.compareTo(b.title));
      return;
    }
    recipes.sort((a, b) {
      final sa = _matchScore(a, fridgeNamesNorm);
      final sb = _matchScore(b, fridgeNamesNorm);
      final byMatch = sb.match.compareTo(sa.match); // 일치 많이
      if (byMatch != 0) return byMatch;
      final byMissing = sa.missing.compareTo(sb.missing); // 부족 적게
      if (byMissing != 0) return byMissing;
      return a.title.compareTo(b.title);
    });
  }

  // ---------------- HTTP 재시도 헬퍼 ----------------
  Future<http.Response> _getWithRetry(
      Uri url, {
        int retries = 2,
        Duration timeout = _netTimeout,
      }) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final res = await http.get(url).timeout(timeout);
        return res;
      } on TimeoutException {
        if (attempt > retries) rethrow;
        await Future.delayed(Duration(milliseconds: 400 * attempt));
      } on SocketException {
        if (attempt > retries) rethrow;
        await Future.delayed(Duration(milliseconds: 400 * attempt));
      }
    }
  }

  // ---------------- 초기 자동 추천 ----------------
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapInitialRecipes());
  }

  Future<void> _bootstrapInitialRecipes() async {
    final names = context.read<FoodProvider?>()?.fridgeNames ?? const <String>[];
    // 냉장고가 비었거나 실패 대비 기본 키워드
    final seeds = (names.isNotEmpty ? names : const ['김치', '계란', '두부']).take(3).toList();

    setState(() => _isLoading = true);
    try {
      final lists = await Future.wait(seeds.map((kw) {
        // 초기 추천은 한 번에 좀 넉넉히(예: 처음 30개)만 가져와서 보여줌
        return _fetchRecipesRaw(kw, startIdx: 1, endIdx: 30);
      })); // 병렬
      // 제목 기준 중복 제거
      final Map<String, Recipe> merged = {};
      for (final list in lists) {
        for (final r in list) {
          merged[r.title] = r;
        }
      }
      recipes = merged.values.toList();

      // 1차: 정렬 옵션 반영
      if (_sortOption == '칼로리 순') {
        recipes.sort((a, b) => a.kcal.compareTo(b.kcal));
      } else {
        recipes.sort((a, b) => a.title.compareTo(b.title));
      }
      // 2차: 냉장고 매칭 우선 정렬
      final fridgeNamesNorm = names.map(_norm).where((e) => e.isNotEmpty).toSet();
      _applyFridgeAwareSort(fridgeNamesNorm);

      if (mounted) setState(() {});
    } on SocketException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('네트워크 연결을 확인해주세요.')),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('초기 추천 불러오기 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- 공용 fetch (범위 지원, 상태 변경 없음) ----------------
  Future<List<Recipe>> _fetchRecipesRaw(
      String keyword, {
        required int startIdx,
        required int endIdx,
      }) async {
    final kw = keyword.trim();
    if (kw.isEmpty) return const [];

    final q = Uri.encodeComponent(kw);
    final url = Uri.parse('$_base/$_keyId/$_serviceId/$_dataType/$startIdx/$endIdx/RCP_NM=$q');

    final res = await _getWithRetry(url, timeout: _netTimeout);
    final bodyStr = utf8.decode(res.bodyBytes);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final root = jsonDecode(bodyStr);
    final rows = root['COOKRCP01']?['row'] as List?;
    if (rows == null || rows.isEmpty) return const [];

    final mapped = <Recipe>[];
    for (final r0 in rows) {
      if (r0 is! Map) continue;
      final r = r0 as Map<String, dynamic>;

      final title = (r['RCP_NM'] ?? '').toString().trim();
      final img = (r['ATT_FILE_NO_MAIN'] ?? '').toString().trim();

      final kcalStr = (r['INFO_ENG'] ?? '').toString().trim();
      final kcalDouble = double.tryParse(kcalStr) ?? 0;
      final kcalVal = kcalDouble.round();

      final carbVal = double.tryParse((r['INFO_CAR'] ?? '').toString().trim()) ?? 0;
      final proteinVal = double.tryParse((r['INFO_PRO'] ?? '').toString().trim()) ?? 0;
      final fatVal = double.tryParse((r['INFO_FAT'] ?? '').toString().trim()) ?? 0;

      final steps = <String>[];
      for (int i = 1; i <= 20; i++) {
        final key = 'MANUAL${i.toString().padLeft(2, '0')}';
        final step = (r[key] ?? '').toString().trim();
        if (step.isNotEmpty) steps.add(step);
      }

      final parts = (r['RCP_PARTS_DTLS'] ?? '').toString().trim();
      final Map<String, bool> ing = {};
      if (parts.isNotEmpty) {
        final tokens = parts
            .split(RegExp(r'[,|\n]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty);
        for (final t in tokens) {
          final k = t.length > 40 ? '${t.substring(0, 40)}…' : t;
          ing[k] = true;
        }
      } else if (title.isNotEmpty) {
        ing[title] = true;
      }

      mapped.add(
        Recipe(
          title: title.isEmpty ? '이름 없음' : title,
          description: (r['RCP_PAT2'] ?? '레시피').toString(),
          imagePath: img.isEmpty ? 'assets/images/placeholder_food.jpg' : img,
          time: 0,
          kcal: kcalVal,
          carb: carbVal,
          protein: proteinVal,
          fat: fatVal,
          ingredients: ing,
          steps: steps,
        ),
      );
    }
    return mapped;
  }

  // ---------------- 검색: 초기 페이지 로드 ----------------
  Future<void> _fetchRecipes(String keyword) async {
    final kw = keyword.trim();
    if (kw.isEmpty) return;

    setState(() {
      _isLoading = true;
      _currentQuery = kw;
      _nextStart = 1;     // 첫 페이지부터
      _hasMore = false;
    });

    try {
      final first = await _fetchRecipesRaw(
        kw,
        startIdx: _nextStart,
        endIdx: _nextStart + _pageSize - 1,
      );

      // 중복 제거(제목 기준)
      final seen = <String>{};
      final merged = <Recipe>[];
      for (final r in first) {
        if (seen.add(r.title)) merged.add(r);
      }

      // 1차 정렬 (옵션)
      if (_sortOption == '칼로리 순') {
        merged.sort((a, b) => a.kcal.compareTo(b.kcal));
      } else {
        merged.sort((a, b) => a.title.compareTo(b.title));
      }

      // 2차: 냉장고 매칭 정렬
      final fridgeNames = context.read<FoodProvider?>()?.fridgeNames ?? const <String>[];
      final fridgeNamesNorm = fridgeNames.map(_norm).where((e) => e.isNotEmpty).toSet();
      recipes = merged;
      _applyFridgeAwareSort(fridgeNamesNorm);

      // 페이지네이션 진행 여부 결정
      _nextStart += _pageSize;
      _hasMore = first.length >= _pageSize;

      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('호출 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- 더보기: 다음 페이지 로드 ----------------
  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _currentQuery.isEmpty) return;

    setState(() => _isLoadingMore = true);
    try {
      final more = await _fetchRecipesRaw(
        _currentQuery,
        startIdx: _nextStart,
        endIdx: _nextStart + _pageSize - 1,
      );

      // 합치고 제목 중복 제거
      final byTitle = <String, Recipe>{for (final r in recipes) r.title: r};
      for (final r in more) {
        byTitle[r.title] = r;
      }
      final merged = byTitle.values.toList();

      // 1차 정렬 (옵션)
      if (_sortOption == '칼로리 순') {
        merged.sort((a, b) => a.kcal.compareTo(b.kcal));
      } else {
        merged.sort((a, b) => a.title.compareTo(b.title));
      }

      // 2차: 냉장고 매칭 정렬
      final fridgeNames = context.read<FoodProvider?>()?.fridgeNames ?? const <String>[];
      final fridgeNamesNorm = fridgeNames.map(_norm).where((e) => e.isNotEmpty).toSet();
      recipes = merged;
      _applyFridgeAwareSort(fridgeNamesNorm);

      _nextStart += _pageSize;
      _hasMore = more.length >= _pageSize;

      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('더 불러오기 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------- UI (그대로 + 하단 "더 보기"만 추가) ----------------
  @override
  Widget build(BuildContext context) {
    // 냉장고 변경 시 자동 재정렬
    final fridgeNames = context.watch<FoodProvider?>()?.fridgeNames ?? const <String>[];
    final fridgeNamesNorm = fridgeNames.map(_norm).where((e) => e.isNotEmpty).toSet();

    // 냉장고 데이터가 늦게 로드돼도 한 번은 자동 추천 실행
    if (!_didAutoLoad && fridgeNames.isNotEmpty && recipes.isEmpty && !_isLoading) {
      _didAutoLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapInitialRecipes());
    }

    _applyFridgeAwareSort(fridgeNamesNorm);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Spacer(),
                  const Text(
                    '레시피',
                    style: TextStyle(
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Color(0xFF003508),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Color(0xFF003508)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 검색창
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  hintText: '레시피명을 검색하세요. (예: 김치볶음밥, 된장찌개)',
                  hintStyle: const TextStyle(
                    fontFamily: 'Pretendard Variable',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF003508)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: Color(0xFF7BAA7F), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: Color(0xFF003508), width: 2),
                  ),
                ),
                onSubmitted: (kw) => _fetchRecipes(kw),
              ),
            ),
            const SizedBox(height: 12),

            // 정렬 + 검색 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      setState(() {
                        _sortOption = value;
                        if (_sortOption == '칼로리 순') {
                          recipes.sort((a, b) => a.kcal.compareTo(b.kcal));
                        } else {
                          recipes.sort((a, b) => a.title.compareTo(b.title));
                        }
                      });
                      final names = context.read<FoodProvider?>()?.fridgeNames ?? const <String>[];
                      final namesNorm = names.map(_norm).where((e) => e.isNotEmpty).toSet();
                      setState(() => _applyFridgeAwareSort(namesNorm));
                    },
                    itemBuilder: (BuildContext context) => const [
                      PopupMenuItem<String>(
                        value: '추천 레시피 순',
                        child: Text('추천 레시피 순'),
                      ),
                      PopupMenuItem<String>(
                        value: '칼로리 순',
                        child: Text('칼로리 순'),
                      ),
                    ],
                    child: Row(
                      children: [
                        Text(
                          _sortOption,
                          style: const TextStyle(
                            fontFamily: 'Pretendard Variable',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF003508),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Color(0xFF003508)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _fetchRecipes(_searchController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003508),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('검색'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF003508)))
                  : (recipes.isEmpty
                  ? const Center(child: Text('검색 결과가 없습니다.'))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recipes.length + (_currentQuery.isNotEmpty && _hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // 마지막 셀: 더 보기
                  final showLoadMore = _currentQuery.isNotEmpty && _hasMore;
                  final extra = showLoadMore ? 1 : 0;
                  if (showLoadMore && index == recipes.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: _isLoadingMore
                            ? const CircularProgressIndicator(color: Color(0xFF003508))
                            : ElevatedButton(
                          onPressed: _loadMore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003508),
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

                  final recipe = recipes[index];
                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push<FoodItemn>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailPage(
                            recipe: recipe,
                            pickMode: widget.pickMode,
                          ),
                        ),
                      );
                      if (widget.pickMode && result != null && context.mounted) {
                        Navigator.pop(context, result);
                      }
                    },
                    child: RecipeCard(
                      imagePath: recipe.imagePath,
                      title: recipe.title,
                      subtitle: recipe.description,
                      ingredients: recipe.ingredients.keys.join(', '),
                      kcal: recipe.kcal.toDouble(),
                    ),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String ingredients;
  final double kcal;

  const RecipeCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.ingredients,
    required this.kcal,
  });

  @override
  Widget build(BuildContext context) {
    Widget img;
    if (imagePath.startsWith('http')) {
      img = Image.network(
        imagePath,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ph(),
      );
    } else {
      img = Image.asset(
        imagePath,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ph(),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withAlpha(13),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(16), child: img),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Pretendard Variable',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF003508),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Pretendard Variable',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '재료(요약)',
                  style: TextStyle(
                    fontFamily: 'Pretendard Variable',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF003508),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ingredients.isEmpty ? '-' : ingredients,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    fontFamily: 'Pretendard Variable',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF003508),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department, size: 16, color: Color(0xFF003508)),
                    const SizedBox(width: 4),
                    Text(
                      '${kcal.toStringAsFixed(0)}kcal',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF003508)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ph() => Container(
    width: 100,
    height: 100,
    color: const Color(0xFFEFEFEF),
    alignment: Alignment.center,
    child: const Icon(Icons.image_not_supported, color: Colors.grey),
  );
}
