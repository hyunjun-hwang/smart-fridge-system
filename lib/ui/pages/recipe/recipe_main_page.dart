import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ 완전 흰 배경
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RecipeDetailPage()),
                      );
                    },
                    child: const RecipeCard(
                      imagePath: 'assets/images/avocado_salad.jpg',
                      title: '아보카도 샐러드',
                      subtitle: '아보카도로 만든 샐러드',
                      ingredients: '아보카도 1개, 바나나 1개, 방울토마토 5개, 젓가락, 피망 1개, 양상추...',
                    ),
                  ),
                  const RecipeCard(
                    imagePath: 'assets/images/banana_pancake.jpg',
                    title: '바나나 팬케이크',
                    subtitle: '아이들이 좋아하는 팬케이크',
                    ingredients: '바나나 2~4개, 핫케이크 믹스 300g, 블루베리 50g, 설탕, 시럽...',
                  ),
                  const RecipeCard(
                    imagePath: 'assets/images/salad_diet.jpg',
                    title: '샐러드',
                    subtitle: '다이어트용',
                    ingredients: '방울토마토 4개, 파스타, 상추, 배추, 양배추',
                  ),
                ],
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
            color: Colors.black.withOpacity(0.05),
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
