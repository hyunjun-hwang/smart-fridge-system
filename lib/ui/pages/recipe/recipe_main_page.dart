import 'package:flutter/material.dart';
import 'package:smart_fridge_system/ui/pages/recipe/recipe_card.dart';
import 'saved_meals_page.dart';

class RecipeMainPage extends StatefulWidget {
  const RecipeMainPage({super.key});

  @override
  State<RecipeMainPage> createState() => _RecipeMainPageState();
}

class _RecipeMainPageState extends State<RecipeMainPage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = '추천 순';

  final List<String> ownedIngredients = ['아보카도', '방울토마토', '바나나'];

  List<Map<String, String>> allRecipes = [
    {
      'title': '아보카도 샐러드',
      'subtitle': '아보카도로 만든 샐러드',
      'image': 'assets/avocado.png',
      'ingredients': '아보카도 1개, 바나나 1개, 방울토마토',
      'time': '25분',
      'kcal': '350kcal',
    },
    {
      'title': '바나나 팬케이크',
      'subtitle': '아이들이 좋아하는 팬케이크',
      'image': 'assets/pancake.png',
      'ingredients': '바나나 2~4개, 핫케이크 믹스',
      'time': '15분',
      'kcal': '280kcal',
    },
  ];

  List<Map<String, String>> filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    filteredRecipes = List.from(allRecipes);
    _searchController.addListener(_filterRecipes);
  }

  void _filterRecipes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredRecipes = allRecipes.where((recipe) {
        return recipe['title']!.toLowerCase().contains(query) ||
            recipe['ingredients']!.toLowerCase().contains(query);
      }).toList();
      _applySorting();
    });
  }

  void _applySorting() {
    if (_sortOption == '칼로리 낮은 순') {
      filteredRecipes.sort((a, b) {
        final aKcal = int.tryParse(a['kcal']!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bKcal = int.tryParse(b['kcal']!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return aKcal.compareTo(bKcal);
      });
    } else if (_sortOption == '시간 짧은 순') {
      filteredRecipes.sort((a, b) {
        final aMin = int.tryParse(a['time']!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bMin = int.tryParse(b['time']!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return aMin.compareTo(bMin);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _currentIndex = 1;

  void _onTabTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SavedMealsPage()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("레시피"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '여기에 검색하세요.',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('정렬 기준:', style: TextStyle(fontSize: 16)),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _sortOption = value;
                      _applySorting();
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: '추천 순', child: Text('추천 순')),
                    const PopupMenuItem(value: '칼로리 낮은 순', child: Text('칼로리 낮은 순')),
                    const PopupMenuItem(value: '시간 짧은 순', child: Text('조리 시간 짧은 순')),
                  ],
                  child: Row(
                    children: [
                      Text(_sortOption),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: filteredRecipes.map((recipe) {
                return RecipeCard(
                  title: recipe['title']!,
                  subtitle: recipe['subtitle']!,
                  imagePath: recipe['image']!,
                  ingredients: recipe['ingredients']!,
                  time: recipe['time']!,
                  kcal: recipe['kcal']!,
                  ownedIngredients: ownedIngredients,
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: '냉장고'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '레시피'),
          BottomNavigationBarItem(icon: Icon(Icons.local_dining), label: '영양소'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}
