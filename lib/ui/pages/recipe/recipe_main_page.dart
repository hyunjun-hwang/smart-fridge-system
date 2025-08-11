import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:smart_fridge_system/data/models/recipe_model.dart';
import 'package:smart_fridge_system/ui/pages/recipe/recipe_detail_page.dart';

// ✅ 영양 반영을 위해 FoodItemn으로 변환해서 SearchFoodScreen으로 돌려보냄
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';

class RecipeMainPage extends StatefulWidget {
  const RecipeMainPage({super.key});

  @override
  State<RecipeMainPage> createState() => _RecipeMainPageState();
}

class _RecipeMainPageState extends State<RecipeMainPage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = '추천 레시피 순';

  bool _isLoading = false;
  List<Recipe> recipes = [];

  // ✅ 식품안전나라(레시피) 경로형 포맷 정보
  static const String _keyId = 'ff4910709e05408eba7c';
  static const String _base = 'http://openapi.foodsafetykorea.go.kr/api';
  static const String _serviceId = 'COOKRCP01'; // 레시피(조리순서/칼로리/이미지)
  static const String _dataType = 'json';

  // ✅ Recipe → FoodItemn 매핑 (필드명 프로젝트에 맞게 사용 중)
  FoodItemn _toFoodItemn(Recipe r) {
    // 레시피 1인분 기준으로 저장한다고 가정. 제공량이 없으니 amount=100g로 둠.
    return FoodItemn(
      name: r.title.isNotEmpty ? r.title : '이름 없는 레시피',
      calories: (r.kcal).toDouble(),   // Recipe.kcal이 int → double
      carbohydrates: r.carb,           // g
      protein: r.protein,              // g
      fat: r.fat,                      // g
      amount: 100,                     // 제공량 정보 없으므로 100g 기준
      count: 1.0,                      // 1인분
    );
  }

  Future<void> _fetchRecipes(String keyword) async {
    if (keyword.trim().isEmpty) return;
    setState(() => _isLoading = true);

    final q = Uri.encodeComponent(keyword.trim());
    // 경로형 포맷: /api/keyId/serviceId/dataType/startIdx/endIdx/RCP_NM=검색어
    const startIdx = 1;
    const endIdx = 10;
    final url = Uri.parse('$_base/$_keyId/$_serviceId/$_dataType/$startIdx/$endIdx/RCP_NM=$q');

    try {
      final res = await http.get(url);
      final bodyStr = utf8.decode(res.bodyBytes);

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final root = jsonDecode(bodyStr);
      final rows = root['COOKRCP01']?['row'] as List?;
      if (rows == null || rows.isEmpty) {
        if (mounted) {
          setState(() => recipes = []);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('검색 결과가 없습니다.')),
          );
        }
        return;
      }

      final mapped = <Recipe>[];
      for (final r0 in rows) {
        if (r0 is! Map) continue;
        final r = r0 as Map<String, dynamic>;

        final title = (r['RCP_NM'] ?? '').toString().trim();
        final img = (r['ATT_FILE_NO_MAIN'] ?? '').toString().trim();

        // ✅ kcal: INFO_ENG (문자일 수 있으니 파싱)
        final kcalStr = (r['INFO_ENG'] ?? '').toString().trim();
        final kcalDouble = double.tryParse(kcalStr) ?? 0;
        final kcalVal = kcalDouble.round(); // Recipe.kcal이 int

        // ✅ 탄수화물/단백질/지방: INFO_CAR / INFO_PRO / INFO_FAT
        final carbStr = (r['INFO_CAR'] ?? '').toString().trim();
        final proteinStr = (r['INFO_PRO'] ?? '').toString().trim();
        final fatStr = (r['INFO_FAT'] ?? '').toString().trim();

        final carbVal = double.tryParse(carbStr) ?? 0;
        final proteinVal = double.tryParse(proteinStr) ?? 0;
        final fatVal = double.tryParse(fatStr) ?? 0;

        // ✅ 조리 순서
        final steps = <String>[];
        for (int i = 1; i <= 20; i++) {
          final key = 'MANUAL${i.toString().padLeft(2, '0')}';
          final step = (r[key] ?? '').toString().trim();
          if (step.isNotEmpty) steps.add(step);
        }

        // ✅ 재료(상세 텍스트) 간단 분해
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
            time: 0,              // 명확한 시간 없음
            kcal: kcalVal,        // int
            carb: carbVal,        // double
            protein: proteinVal,  // double
            fat: fatVal,          // double
            ingredients: ing,
            steps: steps,
          ),
        );
      }

      // ✅ 정렬
      if (_sortOption == '칼로리 순') {
        mapped.sort((a, b) => a.kcal.compareTo(b.kcal));
      } else {
        mapped.sort((a, b) => a.title.compareTo(b.title));
      }

      if (mounted) setState(() => recipes = mapped);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('호출 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ 뒤로가기(AppBar) 활성화
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003508)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '레시피',
          style: TextStyle(
            fontFamily: 'Pretendard Variable',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF003508),
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

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
                      PopupMenuItem<String>(
                        value: '유통기한 임박 순',
                        child: Text('유통기한 임박 순'),
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
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return GestureDetector(
                    // ✅ 탭하면 즉시 FoodItemn으로 변환해서 이전 화면(SearchFoodScreen)으로 반환
                    onTap: () {
                      final food = _toFoodItemn(recipe);
                      Navigator.pop<FoodItemn>(context, food);
                    },
                    child: RecipeCard(
                      imagePath: recipe.imagePath,
                      title: recipe.title,
                      subtitle: recipe.description,
                      ingredients: recipe.ingredients.keys.join(', '),
                      timeMinutes: recipe.time,
                      kcal: recipe.kcal.toDouble(), // 카드 표시에 double 사용
                      // ⚠️ 상세 보기는 카드 내부의 아이콘 버튼 등으로 별도 진입 권장
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
  final int timeMinutes;
  final double kcal;

  const RecipeCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.ingredients,
    required this.timeMinutes,
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
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Color(0xFF003508)),
                    const SizedBox(width: 4),
                    Text(
                      timeMinutes > 0 ? '${timeMinutes}분' : '-',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF003508)),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.local_fire_department, size: 16, color: Color(0xFF003508)),
                    const SizedBox(width: 4),
                    Text(
                      '${kcal.toStringAsFixed(0)}kcal',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF003508)),
                    ),
                    const Spacer(),
                    // 👇 상세보기(선택)로 들어가고 싶을 때 사용하는 아이콘 (반영은 탭으로 이미 처리)
                    IconButton(
                      tooltip: '상세 보기',
                      icon: const Icon(Icons.info_outline, size: 18, color: Color(0xFF003508)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailPage(
                              recipe: Recipe(
                                title: title,
                                description: subtitle,
                                imagePath: imagePath,
                                time: timeMinutes,
                                kcal: kcal.round(),
                                carb: 0,       // 상세 페이지에서 필요 시 채워도 됨
                                protein: 0,
                                fat: 0,
                                ingredients: const {},
                                steps: const [],
                              ),
                            ),
                          ),
                        );
                      },
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
