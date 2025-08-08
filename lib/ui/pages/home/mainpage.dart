// FILE: lib/ui/pages/home/mainpage.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_fridge_system/constants/app_constants.dart';
import 'package:smart_fridge_system/ui/pages/home/temperature_control_modal.dart';
import 'package:smart_fridge_system/ui/pages/home/notification_modal.dart';
import 'package:smart_fridge_system/ui/pages/home/shopping_list_modal.dart';
import 'package:smart_fridge_system/ui/widgets/bottom_nav.dart';
import 'package:smart_fridge_system/data/repositories/food_repository.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- 상태 변수 ---
  double _freezerTemp = -18.0;
  double _freezerHumidity = 75.0;
  String _freezerGasStatus = "점검 필요";
  double _fridgeTemp = 3.0;
  double _fridgeHumidity = 60.0;
  String _fridgeGasStatus = "정상";
  final Uuid _uuid = Uuid();

  // `_foodItems` 리스트를 `late` 키워드를 사용하여 나중에 초기화
  late List<FoodItem> _foodItems;

  bool _isLoading = true;

  // 장보기 목록 상태 변수 추가
  List<ShoppingItem> _shoppingItems = [
    ShoppingItem(id: 0, name: '복숭아', isChecked: true),
    ShoppingItem(id: 1, name: '옥수수', isChecked: false),
    ShoppingItem(id: 2, name: '수박', isChecked: false),
  ];

  @override
  void initState() {
    super.initState();
    // `initState` 메서드에서 `_foodItems`를 초기화합니다.
    _foodItems = [
      FoodItem(
        id: _uuid.v4(),
        name: '소고기',
        imageUrl: 'assets/images/beef.png',
        quantity: 500,
        unit: Unit.grams,
        expiryDate: DateTime.now().add(const Duration(days: 11)),
        stockedDate: DateTime.now().subtract(const Duration(days: 3)),
        storage: StorageType.fridge,
        category: FoodCategory.meat,
      ),
      FoodItem(
        id: _uuid.v4(),
        name: '아보카도',
        imageUrl: 'assets/images/avocado.png',
        quantity: 2,
        unit: Unit.count,
        expiryDate: DateTime.now().add(const Duration(days: 6)),
        stockedDate: DateTime.now().subtract(const Duration(days: 1)),
        storage: StorageType.fridge,
        category: FoodCategory.fruit,
      ),
    ];
    _fetchFoodItems();
  }

  Future<void> _fetchFoodItems() async {
    final foodRepository = FoodRepository();
    final items = await foodRepository.getFoodItems();
    setState(() {
      _foodItems = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(kPagePadding, 0, kPagePadding, kSectionSpacing),
              child: _buildTopBar(context),
            ),
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(kPagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFridgeStatusRow(context),
                      const SizedBox(height: kSectionSpacing),
                      _buildExpiringAndShoppingList(context),
                      const SizedBox(height: kSectionSpacing),
                      _buildNutritionSummary(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 상단 바 위젯 ---
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('안녕하세요! 좋은 아침이에요.', style: kTitleTextStyle),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: kTextColor),
          onPressed: () => _showAppModal(context, const NotificationModal()),
        ),
      ],
    );
  }

  // --- 냉장고 상태 섹션 위젯 ---
  Widget _buildFridgeStatusRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showAppModal(
              context,
              TemperatureControlModal(
                title: '냉동고',
                initialTemp: _freezerTemp,
                minTemp: -25,
                maxTemp: -15,
                initialHumidity: _freezerHumidity,
                gasStatus: _freezerGasStatus,
                iceMakerMinutes: 15,
                onTempChanged: (val) => setState(() => _freezerTemp = val),
                onHumidityChanged: (val) => setState(() => _freezerHumidity = val),
              ),
            ),
            child: _buildFridgeCard(
              title: '냉동고',
              temp: '${_freezerTemp.toStringAsFixed(1)}°C',
              humidity: '${_freezerHumidity.toStringAsFixed(0)}%',
              gas: _freezerGasStatus,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _showAppModal(
              context,
              TemperatureControlModal(
                title: '냉장고',
                initialTemp: _fridgeTemp,
                minTemp: 0,
                maxTemp: 6,
                initialHumidity: _fridgeHumidity,
                gasStatus: _fridgeGasStatus,
                onTempChanged: (val) => setState(() => _fridgeTemp = val),
                onHumidityChanged: (val) => setState(() => _fridgeHumidity = val),
              ),
            ),
            child: _buildFridgeCard(
              title: '냉장고',
              temp: '${_fridgeTemp.toStringAsFixed(1)}°C',
              humidity: '${_fridgeHumidity.toStringAsFixed(0)}%',
              gas: _fridgeGasStatus,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFridgeCard({required String title, required String temp, required String humidity, required String gas}) {
    final isWarning = gas != '정상';
    return Container(
      padding: const EdgeInsets.all(kCardPadding),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: kBorderRadius),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(8)),
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(title, style: kCardTitleTextStyle),
          ),
          const SizedBox(height: 15),
          _buildStatusItem('온도', temp),
          _buildStatusItem('습도', humidity),
          _buildStatusItem('가스', gas, isWarning: isWarning),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kItemSpacing),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(label, style: kBodyTextStyle)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: isWarning ? kWarningColor : kNormalColor,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: isWarning ? kWarningColor : kTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringAndShoppingList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kCardPadding),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: kBorderRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: kAccentColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const Text('유통기한 임박 식품', style: kCardTitleTextStyle),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 70,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _foodItems.isEmpty
                      ? const Text('식품 목록이 없습니다.')
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildExpiringFoodItems(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        (bottomNavKey.currentState as dynamic)?.onItemTapped(1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5D6A3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('냉장고 확인', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        (bottomNavKey.currentState as dynamic)?.onItemTapped(2);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5D6A3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('추천요리', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: kAccentColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const Text('장보기 목록', style: kCardTitleTextStyle),
                ),
                const SizedBox(height: 10),
                ...List.generate(2, (index) {
                  if (index < _shoppingItems.length) {
                    final item = _shoppingItems[index];
                    return _shoppingItem(item.name, checked: item.isChecked);
                  } else {
                    return _shoppingItem('―', checked: false);
                  }
                }),
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        value: false,
                        onChanged: (val) {
                          _showAppModal(
                            context,
                            ShoppingListModal(initialItems: _shoppingItems),
                            isScrollControlled: true,
                          );
                        },
                        activeColor: Colors.blue[100],
                        side: MaterialStateBorderSide.resolveWith(
                              (states) => BorderSide(width: 1.0, color: Colors.grey[400]!),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 0),
                    TextButton(
                      onPressed: () {
                        _showAppModal(
                          context,
                          ShoppingListModal(initialItems: _shoppingItems),
                          isScrollControlled: true,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      child: const Text('전체보기', style: TextStyle(color: kGreyColor)),
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

  List<Widget> _buildExpiringFoodItems() {
    final sortedItems = [..._foodItems];

    if (sortedItems.isEmpty) {
      return [
        const SizedBox(height: 50),
      ];
    }

    sortedItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    return sortedItems
        .take(2)
        .map((item) {
      final diff = item.expiryDate.difference(DateTime.now()).inDays;
      final dDayText = diff < 0 ? 'D+${diff.abs()}' : (diff == 0 ? 'D-Day' : 'D-$diff');
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: _expiringFoodItem(dDayText, item.name),
      );
    }).toList();
  }

  Widget _expiringFoodItem(String dDay, String name) {
    return Row(
      children: [
        Container(
          width: 55, // D-day 텍스트 너비를 고정하여 정렬을 맞춥니다.
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Text(dDay, style: const TextStyle(color: kWarningColor)),
        ),
        const SizedBox(width: 8),
        Text(name, style: kBodyTextStyle),
      ],
    );
  }

  Widget _shoppingItem(String name, {bool checked = false}) {
    return Row(
      children: [
        Transform.scale(
          scale: 0.8,
          child: Checkbox(
            value: checked,
            onChanged: (val) {},
            activeColor: Colors.blue[100],
            side: MaterialStateBorderSide.resolveWith(
                  (states) => BorderSide(width: 1.0, color: Colors.grey[400]!),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 0),
        Text(name, style: kBodyTextStyle),
      ],
    );
  }

  Widget _buildNutritionSummary() {
    return Container(
      padding: const EdgeInsets.all(kCardPadding),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: kBorderRadius,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('나의 섭취 내역', style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 17)),
                SizedBox(height: 15),
                Text('총 섭취 칼로리', style: TextStyle(color: kTextColor, fontSize: 15)),
                SizedBox(height: 3),
                Text('1,000kcal / 1,800kcal', style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    value: 1000 / 1800,
                    color: Colors.blue[100],
                    backgroundColor: Colors.grey[300],
                    strokeWidth: 15,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    (bottomNavKey.currentState as dynamic)?.onItemTapped(3);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5D6A3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(100, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('자세히 보기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 모달을 호출하고 결과를 받는 함수
  void _showAppModal(BuildContext context, Widget modalContent, {bool isScrollControlled = false}) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (_) => modalContent,
    );

    if (result != null && result is List<ShoppingItem>) {
      setState(() {
        _shoppingItems = result;
      });
    }
  }
}