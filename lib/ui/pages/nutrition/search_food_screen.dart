import 'package:flutter/material.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';

class SearchFoodScreen extends StatefulWidget {
  final String mealType;
  final DateTime date;

  const SearchFoodScreen({super.key, required this.mealType, required this.date});

  @override
  State<SearchFoodScreen> createState() => _SearchFoodScreenState();
}

class _SearchFoodScreenState extends State<SearchFoodScreen> {
  int selectedIndex = 0;
  final List<String> filters = ['검색', '즐겨찾기', '내 음식', '냉장고'];
  final TextEditingController _searchController = TextEditingController();

  final List<FoodItem> fridgeItems = [
    FoodItem(
      name: '토마토',
      quantity: 2,
      unit: Unit.count,
      expiryDate: DateTime(2025, 8, 15),
      stockedDate: DateTime(2025, 7, 24),
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/590/590685.png',
      category: '채소',
      storage: StorageType.fridge,
    ),
    FoodItem(
      name: '우유',
      quantity: 1,
      unit: Unit.count,
      expiryDate: DateTime(2025, 8, 2),
      stockedDate: DateTime(2025, 7, 25),
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/1046/1046870.png',
      category: '유제품',
      storage: StorageType.fridge,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003508)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '영양소',
          style: TextStyle(
            color: Color(0xFF003508),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Color(0xFF003508)),
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터 버튼들
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(filters.length, (index) {
                final isSelected = selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filters[index]),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedIndex = index),
                    selectedColor: const Color(0xFFD5E8C6),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF003508) : Colors.black54,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFFD5E8C6) : Colors.grey.shade300,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // 검색창
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
                decoration: const InputDecoration(
                  hintText: '여기에 검색하세요.',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 새 음식 추가 / 레시피에서 추가 버튼 (선택 인덱스 2일 때만 표시)
          if (selectedIndex == 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD5E8C6),
                        foregroundColor: const Color(0xFF003508),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // TODO: 새 음식 추가 화면으로 이동
                      },
                      child: const Text('새 음식 추가'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD5E8C6),
                        foregroundColor: const Color(0xFF003508),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // TODO: 레시피에서 추가 화면으로 이동
                      },
                      child: const Text('레시피에서 추가'),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // 본문
          Expanded(
            child: selectedIndex == 3
                ? _buildRefrigeratorList()
                : const Center(
              child: Text(
                '최근에 추가한 항목이 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefrigeratorList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: fridgeItems.length,
      itemBuilder: (context, index) {
        final item = fridgeItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Image.network(item.imageUrl, width: 48, height: 48),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('수량: ${item.quantity}${item.unit == Unit.count ? '개' : 'g'}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 상세 수정 다이얼로그 띄우려면 여기에 EditFoodItemDialog 호출
            },
          ),
        );
      },
    );
  }
}
