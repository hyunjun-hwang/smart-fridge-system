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
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TemperatureProvider>();

    final title = widget.isFreezer ? '냉동고' : '냉장고';
    final minTemp = widget.isFreezer ? -25.0 : 0.0;
    final maxTemp = widget.isFreezer ? -15.0 : 6.0;

    final double targetTemp = widget.isFreezer
        ? provider.freezerTargetTemp
        : provider.fridgeTargetTemp;

    final String gasStatus = widget.isFreezer
        ? provider.freezerCurrentGasStatus
        : provider.fridgeCurrentGasStatus;

    final isWarning = gasStatus != '정상';
    final iceMakerMinutes = widget.isFreezer ? 15 : null;

    final Function(double) onTargetTempChanged = widget.isFreezer
        ? provider.updateFreezerTargetTemp
        : provider.updateFridgeTargetTemp;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildSliderWithLabels(
                    label: '온도 설정',
                    value: targetTemp,
                    displayValue: '${targetTemp.round()}°C',
                    min: minTemp,
                    max: maxTemp,
                    onChanged: (val) {
                      onTargetTempChanged(val);
                    },
                  ),
                ),
                Expanded(
                  child: _buildSliderWithLabels(
                    label: '습도',
                    value: widget.isFreezer
                        ? provider.freezerCurrentHumidity
                        : provider.fridgeCurrentHumidity,
                    displayValue:
                    '${(widget.isFreezer ? provider.freezerCurrentHumidity : provider.fridgeCurrentHumidity).round()}%',
                    min: 0,
                    max: 100,
                    onChanged: null, // 비활성화
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
    required ValueChanged<double>? onChanged,
  }) {
    final activeColor = onChanged != null ? kAccentColor : Colors.grey;

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
                activeTrackColor: activeColor,
                inactiveTrackColor: Colors.grey[300],
                thumbColor: Colors.white,
                disabledThumbColor: Colors.grey[400],
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