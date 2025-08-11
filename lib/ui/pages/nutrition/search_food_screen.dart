import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:smart_fridge_system/data/models/recipe_model.dart';
import 'package:smart_fridge_system/ui/pages/recipe/recipe_detail_page.dart';

class SearchFoodScreen extends StatefulWidget {
  final String mealType;      // ✅ RecordEntryScreen에서 넘겨줌
  final DateTime date;        // ✅ RecordEntryScreen에서 넘겨줌

  const SearchFoodScreen({
    super.key,
    required this.mealType,
    required this.date,
  });

  @override
  State<SearchFoodScreen> createState() => _SearchFoodScreenState();
}

class _SearchFoodScreenState extends State<SearchFoodScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Recipe> recipes = [];

  // ✅ 식품안전나라 레시피 API 기본 설정
  static const String _keyId = 'ff4910709e05408eba7c'; // API 인증키
  static const String _base = 'https://openapi.foodsafetykorea.go.kr/api';
  static const String _serviceId = 'COOKRCP01';
  static const String _dataType = 'json';

  Future<void> _fetchRecipes(String keyword) async {
    final kw = keyword.trim();
    if (kw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('검색어를 입력하세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String q = Uri.encodeComponent(kw);
    const startIdx = 1;
    const endIdx = 20;
    final Uri url = Uri.parse(
      '$_base/$_keyId/$_serviceId/$_dataType/$startIdx/$endIdx/RCP_NM=$q',
    );

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonBody =
        json.decode(utf8.decode(res.bodyBytes));
        final List<dynamic>? rows = jsonBody['COOKRCP01']?['row'];

        if (rows == null || rows.isEmpty) {
          setState(() => recipes = []);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('검색 결과가 없습니다.')),
          );
        } else {
          setState(() {
            recipes = rows.map((r) {
              return Recipe(
                title: (r['RCP_NM'] ?? '').toString(),
                description: (r['RCP_PAT2'] ?? '').toString(),
                imagePath: (r['ATT_FILE_NO_MAIN'] ?? '').toString(),
                time: 0,
                kcal: double.tryParse((r['INFO_ENG'] ?? '0').toString())
                    ?.round() ??
                    0,
                carb: double.tryParse((r['INFO_CAR'] ?? '0').toString()) ?? 0,
                protein:
                double.tryParse((r['INFO_PRO'] ?? '0').toString()) ?? 0,
                fat: double.tryParse((r['INFO_FAT'] ?? '0').toString()) ?? 0,
                ingredients: {},
                steps: [],
              );
            }).toList();
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('호출 실패: ${res.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003508)),
          onPressed: () => Navigator.pop(context), // result 없음 → null 반환됨(OK)
        ),
        title: const Text(
          '레시피',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF003508),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                hintText: '레시피명을 검색하세요. (예: 김치볶음밥, 된장찌개)',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF003508)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide:
                  const BorderSide(color: Color(0xFF7BAA7F), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide:
                  const BorderSide(color: Color(0xFF003508), width: 2),
                ),
              ),
              onSubmitted: _fetchRecipes,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF003508)),
            )
                : recipes.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다.'))
                : ListView.builder(
              itemCount: recipes.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RecipeDetailPage(recipe: recipe),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFD5E8C6), width: 2),
                    ),
                    child: Row(
                      children: [
                        recipe.imagePath.startsWith('http')
                            ? ClipRRect(
                          borderRadius:
                          BorderRadius.circular(8),
                          child: Image.network(
                            recipe.imagePath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image,
                                size: 40),
                          ),
                        )
                            : const Icon(Icons.image, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                recipe.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${recipe.kcal} kcal',
                                style: const TextStyle(
                                    color: Color(0xFF003508),
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
