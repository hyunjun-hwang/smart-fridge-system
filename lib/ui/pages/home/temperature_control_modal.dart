import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/constants/app_constants.dart';
import 'package:smart_fridge_system/providers/temperature_provider.dart';
import 'dart:math' as math;

/// 온도 제어 모달
class TemperatureControlModal extends StatefulWidget {
  final bool isFreezer;

  const TemperatureControlModal({
    super.key,
    required this.isFreezer,
  });

  @override
  State<TemperatureControlModal> createState() =>
      _TemperatureControlModalState();
}

class _TemperatureControlModalState extends State<TemperatureControlModal> {
  late double _currentTemp;
  late double _currentHumidity;

  @override
  void initState() {
    super.initState();
    // initState에서는 context.read를 사용해야 합니다.
    final provider = context.read<TemperatureProvider>();
    if (widget.isFreezer) {
      // ✨ 수정된 부분: status 객체를 통해 값에 접근합니다.
      _currentTemp = provider.freezerStatus.temperature;
      _currentHumidity = provider.freezerStatus.humidity;
    } else {
      // ✨ 수정된 부분: status 객체를 통해 값에 접근합니다.
      _currentTemp = provider.fridgeStatus.temperature;
      _currentHumidity = provider.fridgeStatus.humidity;
    }
  }

  @override
  Widget build(BuildContext context) {
    // build 메서드에서는 context.watch 또는 context.read를 상황에 맞게 사용합니다.
    // 여기서는 상태 변경을 UI에 반영할 필요가 없으므로 read를 사용합니다.
    final provider = context.read<TemperatureProvider>();

    final title = widget.isFreezer ? '냉동고' : '냉장고';
    final minTemp = widget.isFreezer ? -25.0 : 0.0;
    final maxTemp = widget.isFreezer ? -15.0 : 6.0;
    // ✨ 수정된 부분: status 객체를 통해 값에 접근합니다.
    final gasStatus =
    widget.isFreezer ? provider.freezerStatus.gasStatus : provider.fridgeStatus.gasStatus;
    final isWarning = gasStatus != '정상';
    final iceMakerMinutes = widget.isFreezer ? 15 : null;

    // 이 부분은 provider에 개별 업데이트 메서드가 다시 추가되었으므로 정상 동작합니다.
    final Function(double) onTempChanged =
    widget.isFreezer ? provider.updateFreezerTemp : provider.updateFridgeTemp;
    final Function(double) onHumidityChanged = widget.isFreezer
        ? provider.updateFreezerHumidity
        : provider.updateFridgeHumidity;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text(title,
                  style: kCardTitleTextStyle.copyWith(
                      color: const Color(0xFF003508))),
            ),
            const SizedBox(height: 30),
            // 온도, 습도, 가스 등 상태 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildSliderWithLabels(
                    label: '온도',
                    value: _currentTemp,
                    displayValue: '${_currentTemp.round()}°C',
                    min: minTemp,
                    max: maxTemp,
                    onChanged: (val) {
                      setState(() => _currentTemp = val);
                      onTempChanged(val);
                    },
                  ),
                ),
                Expanded(
                  child: _buildSliderWithLabels(
                    label: '습도',
                    value: _currentHumidity,
                    displayValue: '${_currentHumidity.round()}%',
                    min: 0,
                    max: 100,
                    onChanged: (val) {
                      setState(() => _currentHumidity = val);
                      onHumidityChanged(val);
                    },
                  ),
                ),
                Expanded(
                  child: _buildStatusIndicator(
                      label: '가스', status: gasStatus, isWarning: isWarning),
                ),
                if (iceMakerMinutes != null)
                  Expanded(
                    child: _buildIceMakerStatus(iceMakerMinutes),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('닫기',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderWithLabels({
    required String label,
    required double value,
    required String displayValue,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(displayValue,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 8.0,
                trackShape: const RoundedRectSliderTrackShape(),
                thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                overlayShape:
                const RoundSliderOverlayShape(overlayRadius: 20.0),
                activeTrackColor: kAccentColor,
                inactiveTrackColor: Colors.grey[300],
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: (max - min).toInt(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildStatusIndicator(
      {required String label, required String status, bool isWarning = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(status,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isWarning ? kWarningColor : kNormalColor)),
        const SizedBox(height: 34),
        SizedBox(
          height: 110,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 8,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 8,
                height: 40,
                decoration: BoxDecoration(
                  color: isWarning ? kWarningColor : kNormalColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildIceMakerStatus(int minutes) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${minutes}분',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Container(
            width: 60,
            height: 110,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Transform.rotate(
                    angle: -math.pi / 20,
                    child: const Icon(Icons.ac_unit,
                        size: 40, color: Colors.lightBlueAccent)))),
        const SizedBox(height: 30),
        Text('얼음', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      ],
    );
  }
}