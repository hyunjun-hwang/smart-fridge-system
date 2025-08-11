// lib/ui/pages/nutrition/recipe_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:smart_fridge_system/data/models/recipe_model.dart';
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';
import 'package:smart_fridge_system/ui/pages/nutrition/recipe_picker_detail_page.dart';

class RecipePage extends StatefulWidget {
  /// pickMode = true  → 상세에서 "추가하기" 버튼 노출, 선택 시 FoodItemn을 pop으로 반환
  /// pickMode = false → 그냥 레시피 보기
  final bool pickMode;

  const RecipePage({super.key, this.pickMode = false});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  static const Color _primary = Color(0xFF003508);

  final TextEditingController _searchController = TextEditingController();
  String _sortOption = '추천 레시피 순';

  bool _isLoading = false;
  List<Recipe> _recipes = [];

  // 식품안전나라 레시피 API (경로형)
  static const String _keyId = 'ff4910709e05408eba7c';
  static const String _base = 'http://openapi.foodsafetykorea.go.kr/api';
  static const String _serviceId = 'COOKRCP01';
  static const String _dataType = 'json';

  Future<void> _fetchRecipes(String keyword) async {
    final kw = keyword.trim();
    if (kw.isEmpty) return;

    setState(() => _isLoading = true);
    final q = Uri.encodeComponent(kw);
    const startIdx = 1;
    const endIdx = 10;
    final url = Uri.parse('$_base/$_keyId/$_serviceId/$_dataType/$startIdx/$endIdx/RCP_NM=$q');

    try {
      final res = await http.get(url);
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final root = jsonDecode(utf8.decode(res.bodyBytes));
      final rows = root['COOKRCP01']?['row'] as List?;
      if (rows == null || rows.isEmpty) {
        if (mounted) {
          setState(() => _recipes = []);
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

        final kcal = (double.tryParse((r['INFO_ENG'] ?? '').toString().trim()) ?? 0).round();
        final carb = double.tryParse((r['INFO_CAR'] ?? '').toString().trim()) ?? 0;
        final prot = double.tryParse((r['INFO_PRO'] ?? '').toString().trim()) ?? 0;
        final fat  = double.tryParse((r['INFO_FAT'] ?? '').toString().trim()) ?? 0;

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

        mapped.add(Recipe(
          title: title.isEmpty ? '이름 없음' : title,
          description: (r['RCP_PAT2'] ?? '레시피').toString(),
          imagePath: img.isEmpty ? 'assets/images/placeholder_food.jpg' : img,
          time: 0,
          kcal: kcal,
          carb: carb,
          protein: prot,
          fat: fat,
          ingredients: ing,
          steps: steps,
        ));
      }

      if (_sortOption == '칼로리 순') {
        mapped.sort((a, b) => a.kcal.compareTo(b.kcal));
      } else {
        mapped.sort((a, b) => a.title.compareTo(b.title));
      }

      if (mounted) setState(() => _recipes = mapped);
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

  @override
  Widget build(BuildContext context) {
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
                      color: _primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: _primary),
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
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: _primary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: Color(0xFF7BAA7F), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: _primary, width: 2),
                  ),
                ),
                onSubmitted: _fetchRecipes,
              ),
            ),
            const SizedBox(height: 12),

            // 정렬 + 검색 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        _sortOption = value;
                        if (_sortOption == '칼로리 순') {
                          _recipes.sort((a, b) => a.kcal.compareTo(b.kcal));
                        } else {
                          _recipes.sort((a, b) => a.title.compareTo(b.title));
                        }
                      });
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: '추천 레시피 순', child: Text('추천 레시피 순')),
                      PopupMenuItem(value: '칼로리 순', child: Text('칼로리 순')),
                    ],
                    child: Row(
                      children: [
                        Text(
                          _sortOption,
                          style: const TextStyle(
                            fontFamily: 'Pretendard Variable',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _primary,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: _primary),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _fetchRecipes(_searchController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
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
                  ? const Center(child: CircularProgressIndicator(color: _primary))
                  : (_recipes.isEmpty
                  ? const Center(child: Text('검색 결과가 없습니다.'))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _recipes.length,
                itemBuilder: (context, index) {
                  final recipe = _recipes[index];
                  return GestureDetector(
                    onTap: () async {
                      // 상세로 이동. pickMode면 FoodItemn 결과 받기
                      final FoodItemn? result = await Navigator.push<FoodItemn>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailPage(
                            recipe: recipe,
                            pickMode: widget.pickMode,
                          ),
                        ),
                      );
                      if (widget.pickMode && result != null && context.mounted) {
                        // 상위(SearchFoodScreen)로 그대로 반환
                        Navigator.pop(context, result);
                      }
                    },
                    child: _RecipeCard(recipe: recipe),
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

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF003508);

    Widget img;
    if (recipe.imagePath.startsWith('http')) {
      img = Image.network(
        recipe.imagePath,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ph(),
      );
    } else {
      img = Image.asset(
        recipe.imagePath,
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
                  recipe.title,
                  style: const TextStyle(
                    fontFamily: 'Pretendard Variable',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recipe.description,
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
                    color: primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  recipe.ingredients.keys.join(', ').isEmpty
                      ? '-'
                      : recipe.ingredients.keys.join(', '),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    fontFamily: 'Pretendard Variable',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department, size: 16, color: primary),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.kcal.toStringAsFixed(0)}kcal',
                      style: const TextStyle(fontSize: 13, color: primary),
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
