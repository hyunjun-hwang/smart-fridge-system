import 'package:flutter/material.dart';
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

  final List<Recipe> recipes = [
    Recipe(
      title: '아보카도 샐러드',
      description: '아보카도로 만든 샐러드',
      imagePath: 'assets/images/avocado_salad.jpg',
      time: 25,
      kcal: 350,
      carb: 183.5,
      protein: 154,
      fat: 50,
      ingredients: {
        '아보카도 3개': true,
        '바나나 1개': true,
        '골드키위': false,
        '로메인': false,
        '발사믹 글레이즈': true,
        '후춧가루': true,
      },
      steps: [
        '블루베리를 제외한 모든 과일과 로메인은 비슷한 크기로 썰어준다',
        '접시에 로메인을 먼저 깔아준다',
        '아보카도와 과일을 골고루 뿌리듯 올려준다',
        '리코타치즈를 떠서 올려주고 올리브오일을 골고루 뿌린 후 소금과 후춧가루를 뿌려준다',
        '마지막에 발사믹소스를 뿌려준다',
      ],
    ),
    Recipe(
      title: '바나나 팬케이크',
      description: '아이들이 좋아하는 팬케이크',
      imagePath: 'assets/images/banana_pancake.jpg',
      time: 20,
      kcal: 320,
      carb: 90,
      protein: 60,
      fat: 40,
      ingredients: {'바나나 2개': true, '핫케이크 믹스': true},
      steps: ['재료를 섞고 굽는다'],
    ),
    Recipe(
      title: '샐러드',
      description: '다이어트용',
      imagePath: 'assets/images/salad_diet.jpg',
      time: 15,
      kcal: 200,
      carb: 60,
      protein: 30,
      fat: 10,
      ingredients: {'상추': true, '파스타': false},
      steps: ['재료를 섞는다'],
    ),
  ];

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      setState(() {
                        _sortOption = value;
                      });
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: '추천 레시피 순',
                        child: Text('추천 레시피 순'),
                      ),
                      const PopupMenuItem<String>(
                        value: '칼로리 순',
                        child: Text('칼로리 순'),
                      ),
                      const PopupMenuItem<String>(
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
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
                    ),
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

  const RecipeCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Image.asset(
              imagePath,
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
                  ingredients,
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
                  children: const [
                    Icon(Icons.access_time, size: 16, color: Color(0xFF003508)),
                    SizedBox(width: 4),
                    Text('25분', style: TextStyle(fontSize: 13, color: Color(0xFF003508))),
                    SizedBox(width: 16),
                    Icon(Icons.local_fire_department, size: 16, color: Color(0xFF003508)),
                    SizedBox(width: 4),
                    Text('350kcal', style: TextStyle(fontSize: 13, color: Color(0xFF003508))),
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
