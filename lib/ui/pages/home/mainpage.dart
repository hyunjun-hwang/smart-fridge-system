

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/constants/app_constants.dart';
import 'package:smart_fridge_system/providers/food_provider.dart';
import 'package:smart_fridge_system/providers/shopping_list_provider.dart';
import 'package:smart_fridge_system/providers/temperature_provider.dart';
import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/ui/pages/home/notification_modal.dart';
import 'package:smart_fridge_system/ui/pages/home/shopping_list_modal.dart';
import 'package:smart_fridge_system/ui/pages/home/temperature_control_modal.dart';
import 'package:smart_fridge_system/ui/widgets/bottom_nav.dart';

/// 홈 화면 메인 페이지
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 위젯 빌드 후 음식 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoodProvider>(context, listen: false).fetchFoodItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: const SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: _HomeContent(),
            ),
          ],
        ),
      ),
    );
  }
}

/// 상단 바 위젯
class _TopBar extends StatelessWidget {
  const _TopBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
          kPagePadding, 0, kPagePadding, kSectionSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('안녕하세요! 좋은 아침이에요.', style: kTitleTextStyle),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: kTextColor),
            onPressed: () => _showAppModal(context, const NotificationModal()),
          ),
        ],
      ),
    );
  }
}

/// 홈 화면 메인 콘텐츠
class _HomeContent extends StatelessWidget {
  const _HomeContent();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const SingleChildScrollView(
        padding: EdgeInsets.all(kPagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FridgeStatusSection(),
            SizedBox(height: kSectionSpacing),
            _ExpiringAndShoppingSection(),
            SizedBox(height: kSectionSpacing),
            _NutritionSummary(),
          ],
        ),
      ),
    );
  }
}

/// 냉장고/냉동고 상태 섹션
class _FridgeStatusSection extends StatelessWidget {
  const _FridgeStatusSection();
  @override
  Widget build(BuildContext context) {
    // TemperatureProvider 변경 감지
    final tempProvider = context.watch<TemperatureProvider>();

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showAppModal(
                context, const TemperatureControlModal(isFreezer: true)),
            child: _FridgeCard(
              title: '냉동고',
              temp: '${tempProvider.freezerTemp.toStringAsFixed(1)}°C',
              humidity: '${tempProvider.freezerHumidity.toStringAsFixed(0)}%',
              gas: tempProvider.freezerGasStatus,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _showAppModal(
                context, const TemperatureControlModal(isFreezer: false)),
            child: _FridgeCard(
              title: '냉장고',
              temp: '${tempProvider.fridgeTemp.toStringAsFixed(1)}°C',
              humidity: '${tempProvider.fridgeHumidity.toStringAsFixed(0)}%',
              gas: tempProvider.fridgeGasStatus,
            ),
          ),
        ),
      ],
    );
  }
}

/// 유통기한 및 장보기 목록 섹션
class _ExpiringAndShoppingSection extends StatelessWidget {
  const _ExpiringAndShoppingSection();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kCardPadding),
      decoration:
      BoxDecoration(color: Colors.grey[50], borderRadius: kBorderRadius),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildExpiringFoodSection(context)),
          const SizedBox(width: 12),
          Expanded(child: _buildShoppingListSection(context)),
        ],
      ),
    );
  }

  /// '유통기한 임박 식품' 목록
  Widget _buildExpiringFoodSection(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final allFoodItems = foodProvider.foodItems;

    // 유통기한 임박 순 정렬 후 상위 2개 필터링
    final sortedItems = [...allFoodItems];
    sortedItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    final expiringSoonItems = sortedItems.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: '유통기한 임박 식품'),
        const SizedBox(height: 20),
        SizedBox(
          height: 70,
          child: foodProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : foodProvider.foodItems.isEmpty
              ? const Center(child: Text('식품 목록이 없습니다.'))
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: expiringSoonItems.map((item) {
              final diff =
                  item.expiryDate.difference(DateTime.now()).inDays;
              final dDayText = diff < 0 ? 'D+${diff.abs()}' : 'D-$diff';
              return _ExpiringFoodItem(
                  dDayText: dDayText, name: item.name, dDayValue: diff);
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _ActionButton(
              text: '냉장고 확인',
              onPressed: () =>
                  (bottomNavKey.currentState as dynamic)?.onItemTapped(1),
            ),
            const SizedBox(width: 10),
            _ActionButton(
              text: '추천요리',
              onPressed: () =>
                  (bottomNavKey.currentState as dynamic)?.onItemTapped(2),
            ),
          ],
        )
      ],
    );
  }

  /// '장보기 목록' 미리보기
  Widget _buildShoppingListSection(BuildContext context) {
    final shoppingListProvider = context.watch<ShoppingListProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SectionTitle(title: '장보기 목록'),
        const SizedBox(height: 10),
        // 상위 2개 아이템만 표시
        ...List.generate(2, (index) {
          if (index < shoppingListProvider.shoppingItems.length) {
            final item = shoppingListProvider.shoppingItems[index];
            return _ShoppingItem(name: item.name, isChecked: item.isChecked);
          } else {
            return const _ShoppingItem(name: '—', isChecked: false);
          }
        }),
        _ViewAllButton(
          onPressed: () => _showAppModal(
            context,
            const ShoppingListModal(),
            isScrollControlled: true,
          ),
        ),
      ],
    );
  }
}

/// 공용 모달 호출 함수
void _showAppModal(BuildContext context, Widget modalContent,
    {bool isScrollControlled = false}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    builder: (_) => modalContent,
  );
}

// --- 하위 위젯들 ---

class _FridgeCard extends StatelessWidget {
  final String title;
  final String temp;
  final String humidity;
  final String gas;

  const _FridgeCard({
    required this.title,
    required this.temp,
    required this.humidity,
    required this.gas,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = gas != '정상';
    return Container(
      padding: const EdgeInsets.all(kCardPadding),
      decoration:
      BoxDecoration(color: Colors.grey[50], borderRadius: kBorderRadius),
      child: Column(
        children: [
          _SectionTitle(title: title, isSub: true),
          const SizedBox(height: 15),
          _StatusItem('온도', temp),
          _StatusItem('습도', humidity),
          _StatusItem('가스', gas, isWarning: isWarning),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isWarning;

  const _StatusItem(this.label, this.value, {this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kItemSpacing),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(label, style: kBodyTextStyle)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border:
              Border.all(color: isWarning ? kWarningColor : kNormalColor),
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
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isSub;
  const _SectionTitle({required this.title, this.isSub = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isSub ? Colors.blue[100] : kAccentColor,
        borderRadius: BorderRadius.circular(8),
      ),
      width: double.infinity,
      alignment: Alignment.center,
      child: Text(title, style: kCardTitleTextStyle),
    );
  }
}

class _ExpiringFoodItem extends StatelessWidget {
  final String dDayText;
  final String name;
  final int dDayValue;

  const _ExpiringFoodItem({
    required this.dDayText,
    required this.name,
    required this.dDayValue,
  });

  @override
  Widget build(BuildContext context) {
    Color dDayColor;
    if (dDayValue <= 3) {
      dDayColor = kWarningColor;
    } else if (dDayValue <= 10) {
      dDayColor = Colors.orange;
    } else {
      dDayColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 55,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(dDayText,
                style: TextStyle(
                    color: dDayColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Text(name, style: kBodyTextStyle),
        ],
      ),
    );
  }
}

class _ShoppingItem extends StatelessWidget {
  final String name;
  final bool isChecked;
  const _ShoppingItem({required this.name, required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.scale(
          scale: 0.8,
          child: Checkbox(
            value: isChecked,
            onChanged: (val) {}, // 미리보기에서 기능 없음
            activeColor: Colors.blue[100],
            side: MaterialStateBorderSide.resolveWith(
                    (states) => BorderSide(width: 1.0, color: Colors.grey[400]!)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 0),
        Text(name, style: kBodyTextStyle),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _ActionButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC5D6A3),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ViewAllButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.scale(
          scale: 0.8,
          child: Checkbox(
            value: false,
            onChanged: (val) => onPressed(),
            activeColor: Colors.blue[100],
            side: MaterialStateBorderSide.resolveWith(
                  (states) => BorderSide(width: 1.0, color: Colors.grey[400]!),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft),
          child: const Text('전체보기', style: TextStyle(color: kGreyColor)),
        ),
      ],
    );
  }
}

/// 나의 섭취 내역 요약
class _NutritionSummary extends StatelessWidget {
  const _NutritionSummary();

  @override
  Widget build(BuildContext context) {
    final nutritionProvider = context.watch<DailyNutritionProvider>();

    // 오늘의 총 섭취 칼로리 계산
    const meals = ['아침', '점심', '저녁', '아침간식', '점심간식', '저녁간식'];
    final today = nutritionProvider.selectedDate;
    double consumedKcal = 0.0;
    for (var meal in meals) {
      final mealNutrition = nutritionProvider.getMealNutrition(meal, today);
      consumedKcal += mealNutrition['calories'] ?? 0.0;
    }

    final targetKcal = nutritionProvider.targetCalories;
    final ratio =
    targetKcal > 0 ? (consumedKcal / targetKcal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(kCardPadding),
      decoration:
      BoxDecoration(color: Colors.grey[50], borderRadius: kBorderRadius),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('나의 섭취 내역',
                    style: TextStyle(
                        color: kTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17)),
                const SizedBox(height: 15),
                const Text('총 섭취 칼로리',
                    style: TextStyle(color: kTextColor, fontSize: 15)),
                const SizedBox(height: 3),
                Text(
                  '${consumedKcal.toInt()}kcal / ${targetKcal.toInt()}kcal',
                  style: const TextStyle(
                      color: kTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
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
                    value: ratio,
                    color: Colors.blue[100],
                    backgroundColor: Colors.grey[300],
                    strokeWidth: 15,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 영양 탭으로 이동
                    (bottomNavKey.currentState as dynamic)?.onItemTapped(3);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5D6A3),
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(100, 36),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('자세히 보기',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
