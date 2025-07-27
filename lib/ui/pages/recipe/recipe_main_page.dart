import 'package:flutter/material.dart';

class RecipeMainPage extends StatefulWidget {
  const RecipeMainPage({super.key});

  @override
  State<RecipeMainPage> createState() => _RecipeMainPageState();
}

class _RecipeMainPageState extends State<RecipeMainPage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = '추천 레시피 순';
  int _currentIndex = 2;

  void _showMealPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddMealPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '레시피',
                    style: TextStyle(
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Color(0xFF003508),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Color(0xFF003508)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationPage()),
                      );
                    },
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  hintText: '여기에 검색하세요.',
                  hintStyle: const TextStyle(
                    fontFamily: 'Pretendard Variable',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF003508)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF003508)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '추천 레시피 순',
                    style: TextStyle(
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF003508),
                    ),
                  ),
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
                            fontSize: 14,
                            color: Color(0xFF003508),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Color(0xFF003508))
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
                children: const [
                  RecipeCard(
                    imagePath: 'assets/avocado_salad.jpg',
                    title: '아보카도 샐러드',
                    subtitle: '아보카도로 만든 샐러드',
                    ingredients: '아보카도 1개, 바나나 1개, 방울토마토 5개, 젓가락, 피망 1개, 양상추...',
                  ),
                  RecipeCard(
                    imagePath: 'assets/banana_pancake.jpg',
                    title: '바나나 팬케이크',
                    subtitle: '아이들이 좋아하는 팬케이크',
                    ingredients: '바나나 2~4개, 핫케이크 믹스 300g, 블루베리 50g, 설탕, 시럽...',
                  ),
                  RecipeCard(
                    imagePath: 'assets/salad_diet.jpg',
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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFD1DFA6),
          selectedItemColor: const Color(0xFF003508),
          unselectedItemColor: Colors.white,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: '냉장고'),
            BottomNavigationBarItem(icon: Icon(Icons.rice_bowl), label: '레시피'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '영양소'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00BBA3),
        onPressed: _showMealPopup,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF003508),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '재료',
                    style: TextStyle(
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF003508),
                    ),
                  ),
                  Text(
                    ingredients,
                    style: const TextStyle(
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF003508),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        backgroundColor: const Color(0xFF003508),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          '알림이 없습니다.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class AddMealPopup extends StatelessWidget {
  const AddMealPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> kcalMap = {
      '아침': 100,
      '점심': 0,
      '저녁': 0,
      '아침 간식': 0,
      '점심 간식': 0,
      '저녁 간식': 0,
    };
    String selectedMeal = '아침';

    return StatefulBuilder(
      builder: (context, setState) => Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('식단 추가', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003508))),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: kcalMap.keys.map((meal) {
                final selected = selectedMeal == meal;
                return GestureDetector(
                  onTap: () => setState(() => selectedMeal = meal),
                  child: Container(
                    width: 100,
                    height: 70,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? const Color(0xFFB7D09D) : const Color(0xFFD9E4C2),
                        width: 1.2,
                      ),
                      color: selected ? const Color(0xFFD9E4C2) : Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(meal, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF003508))),
                        const SizedBox(height: 6),
                        Text('${kcalMap[meal]}kcal', style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 16, color: selected ? const Color(0xFF003508) : Colors.grey[700])),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, selectedMeal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1DFA6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('추가하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
