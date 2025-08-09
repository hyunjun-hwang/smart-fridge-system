import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_fridge_system/data/models/recipe_model.dart';
import 'recipe_detail_page.dart';

class RecipeMainPage extends StatefulWidget {
  const RecipeMainPage({super.key});

  @override
  State<RecipeMainPage> createState() => _RecipeMainPageState();
}

class _RecipeMainPageState extends State<RecipeMainPage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = '추천 레시피 순';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Firestore 문서를 기존 Recipe 모델로 변환
  Recipe _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();

    final title = (d['name'] ?? '').toString();
    final description = (d['description'] ?? d['category'] ?? '').toString();
    final imagePath = (d['imageUrl'] ?? d['image'] ?? '').toString();

    final timeStr = d['cookTime']?.toString() ?? '';
    final time = int.tryParse(RegExp(r'\d+').firstMatch(timeStr)?.group(0) ?? '') ?? 0;

    // ✅ kcal은 int로 파싱 (double/문자열이 와도 안전하게 처리)
    final kcalAny = d['calorie'] ?? d['kcal'];
    final int kcal = switch (kcalAny) {
      int v => v,
      double v => v.round(),
      String v => int.tryParse(v) ?? 0,
      _ => 0,
    };

    // 영양소 값에서 숫자만 추출 (예: "183.5g")
    double parseGram(dynamic v) {
      if (v == null) return 0;
      final s = v.toString();
      return double.tryParse(s.replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0;
    }

    final carb = parseGram(d['carbs'] ?? d['INFO_CAR']);
    final protein = parseGram(d['protein'] ?? d['INFO_PRO']);
    final fat = parseGram(d['fat'] ?? d['INFO_FAT']);

    // "아보카도 3개, 바나나 1개" -> Map<String,bool>
    final ingredientsText = (d['ingredientsText'] ?? '').toString();
    final Map<String, bool> ingredients = {
      for (final e in ingredientsText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty))
        e: false
    };

    // steps: List<String> 또는 \n로 구분된 String
    List<String> steps = const [];
    final rawSteps = d['steps'];
    if (rawSteps is List) {
      steps = rawSteps.whereType<String>().where((s) => s.trim().isNotEmpty).toList();
    } else if (rawSteps is String) {
      steps = rawSteps.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    return Recipe(
      title: title,
      description: description,
      imagePath: imagePath,
      time: time,   // int
      kcal: kcal,   // ✅ int
      carb: carb,   // double
      protein: protein,
      fat: fat,
      ingredients: ingredients.isEmpty
          ? {'재료 정보가 없습니다': false}
          : ingredients,
      steps: steps.isEmpty ? ['조리순서 정보가 없습니다'] : steps,
    );
  }

  List<Recipe> _applySearchAndSort(List<Recipe> list) {
    final keyword = _searchController.text.trim();
    var filtered = list;

    if (keyword.isNotEmpty) {
      filtered = filtered
          .where((r) =>
      r.title.contains(keyword) ||
          r.description.contains(keyword) ||
          r.ingredients.keys.any((k) => k.contains(keyword)))
          .toList();
    }

    switch (_sortOption) {
      case '칼로리 순':
        filtered.sort((a, b) => b.kcal.compareTo(a.kcal)); // int 비교
        break;
      case '유통기한 임박 순':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case '추천 레시피 순':
      default:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('recipes')
        .orderBy('name');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // 상단 타이틀
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
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  hintText: '여기에 검색하세요.',
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
              ),
            ),
            const SizedBox(height: 12),

            // 정렬
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  PopupMenuButton<String>(
                    onSelected: (String value) => setState(() => _sortOption = value),
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
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Firestore 연결
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: query.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('오류가 발생했습니다.'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('레시피가 없습니다.'));
                  }

                  final allRecipes = docs.map(_fromDoc).toList();
                  final view = _applySearchAndSort(allRecipes);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: view.length,
                    itemBuilder: (context, index) {
                      final recipe = view[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailPage(recipe: recipe),
                            ),
                          );
                        },
                        child: RecipeCard(
                          imagePath: recipe.imagePath,
                          title: recipe.title,
                          subtitle: recipe.description,
                          ingredients: recipe.ingredients.keys.join(', '),
                          timeText: recipe.time > 0 ? '${recipe.time}분' : '—',
                          // ✅ int → 문자열 그대로 사용
                          kcalText: recipe.kcal > 0 ? '${recipe.kcal}kcal' : '—',
                        ),
                      );
                    },
                  );
                },
              ),
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
  final String timeText;
  final String kcalText;

  const RecipeCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.ingredients,
    required this.timeText,
    required this.kcalText,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = imagePath.startsWith('http');

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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: isNetwork
                ? Image.network(
              imagePath,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            )
                : Image.asset(
              imagePath.isEmpty ? 'assets/images/placeholder.png' : imagePath,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? '(제목 없음)' : title,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Pretendard Variable',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '재료',
                  style: TextStyle(
                    fontFamily: 'Pretendard Variable',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF003508),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ingredients.isEmpty ? '—' : ingredients,
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
                    Text(timeText, style: const TextStyle(fontSize: 13, color: Color(0xFF003508))),
                    const SizedBox(width: 16),
                    const Icon(Icons.local_fire_department, size: 16, color: Color(0xFF003508)),
                    const SizedBox(width: 4),
                    Text(kcalText, style: const TextStyle(fontSize: 13, color: Color(0xFF003508))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
