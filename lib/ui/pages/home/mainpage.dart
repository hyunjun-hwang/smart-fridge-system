// FILE: mainpage.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_fridge_system/constants/app_constants.dart';
import 'temperature_control_modal.dart';
import 'notification_modal.dart';
import 'shopping_list_modal.dart';

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
          icon: const Icon(Icons.notifications_none, color: kPrimaryColor),
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
                onTempChanged: (val) => setState(() => _freezerTemp = val),
                onHumidityChanged: (val) => setState(() => _freezerHumidity = val),
                extraContent: Column(
                  children: const [
                    Text("가스 상태: 점검 필요", style: TextStyle(color: kWarningColor)),
                    SizedBox(height: kItemSpacing),
                    Text("얼음 완성까지 15분", style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
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
                onTempChanged: (val) => setState(() => _fridgeTemp = val),
                onHumidityChanged: (val) => setState(() => _fridgeHumidity = val),
                extraContent: const Text("가스 상태: 정상", style: TextStyle(color: Colors.green)),
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
              border: Border.all(color: isWarning ? kWarningColor : kNormalColor),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(value, style: TextStyle(color: isWarning ? kWarningColor : kTextColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- 기타 섹션 (유통기한 임박 식품, 장보기 목록, 영양 요약) ---
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
                const SizedBox(height: kItemSpacing),
                _expiringFoodItem('마늘', 'D-100'),
                const SizedBox(height: 8),
                _expiringFoodItem('상추', 'D-3'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen[100],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(100, 36),
                  ),
                  child: const Text('냉장고 확인하기'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
                  child: const Text('장보기 목록', style: kCardTitleTextStyle),
                ),
                const SizedBox(height: 4),
                _shoppingItem('복숭아', checked: true),
                _shoppingItem('옥수수'),
                _shoppingItem('...'),
                TextButton(
                  onPressed: () => _showAppModal(context, const ShoppingListModal(initialItems: ['복숭아', '옥수수', '수박']), isScrollControlled: true),
                  child: const Text('전체보기', style: TextStyle(color: kGreyColor)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _expiringFoodItem(String name, String dDay) {
    return Row(
      children: [
        Text(name, style: kBodyTextStyle),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: kWarningColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('D-3', style: TextStyle(color: kWarningColor)),
        ),
      ],
    );
  }

  Widget _shoppingItem(String name, {bool checked = false}) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(name, style: kBodyTextStyle),
      value: checked,
      onChanged: (val) {},
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
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
                Text('나의 섭취 내역', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 12),
                Text('총 섭취 칼로리'),
                SizedBox(height: 4),
                Text('1,000kcal / 1,800kcal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    color: Colors.lightBlue,
                    backgroundColor: Colors.grey[300],
                    strokeWidth: 6,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: kAccentColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: const Text('자세히 보기', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 모달 바텀 시트 표시 헬퍼 함수 ---
  void _showAppModal(BuildContext context, Widget modalContent, {bool isScrollControlled = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(borderRadius: kModalBorderRadius),
      builder: (_) => modalContent,
    );
  }
}