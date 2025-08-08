// FILE: lib/ui/pages/home/temperature_control_modal.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:smart_fridge_system/constants/app_constants.dart';

class TemperatureControlModal extends StatefulWidget {
  final String title;
  final double initialTemp;
  final double minTemp;
  final double maxTemp;
  final double initialHumidity;
  final String gasStatus;
  final int? iceMakerMinutes;
  final ValueChanged<double> onTempChanged;
  final ValueChanged<double> onHumidityChanged;

  const TemperatureControlModal({
    super.key,
    required this.title,
    required this.initialTemp,
    this.minTemp = -25,
    this.maxTemp = -15,
    required this.initialHumidity,
    required this.gasStatus,
    this.iceMakerMinutes,
    required this.onTempChanged,
    required this.onHumidityChanged,
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
    _currentTemp = widget.initialTemp;
    _currentHumidity = widget.initialHumidity;
  }

  @override
  Widget build(BuildContext context) {
    bool isWarning = widget.gasStatus != '정상';

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
            // 제목
            Container(
              width: double.infinity, // 가로를 꽉 채우도록 수정
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.title,
                style: kCardTitleTextStyle.copyWith(color: const Color(0xFF003508)),
              ),
            ),
            const SizedBox(height: 30),

            // 컨트롤러 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildSliderWithLabels(
                    label: '온도',
                    value: _currentTemp,
                    displayValue: '${_currentTemp.round()}°C',
                    min: widget.minTemp,
                    max: widget.maxTemp,
                    onChanged: (val) {
                      setState(() => _currentTemp = val);
                      widget.onTempChanged(val);
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
                      widget.onHumidityChanged(val);
                    },
                  ),
                ),
                Expanded(
                  child: _buildStatusIndicator(
                    label: '가스',
                    status: widget.gasStatus,
                    isWarning: isWarning,
                  ),
                ),
                if (widget.iceMakerMinutes != null)
                  Expanded(
                    child: _buildIceMakerStatus(widget.iceMakerMinutes!),
                  ),
              ],
            ),
            const SizedBox(height: 30),

            // 닫기 버튼
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '닫기',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 온도/습도 슬라이더 위젯
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
          height: 150, // 막대 높이를 조정하여 위치 맞춤
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 8.0,
                trackShape: const RoundedRectSliderTrackShape(),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
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

  // 가스 상태 표시 위젯
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
          height: 110, // 막대 높이 조정
          child: Stack(
            children: [
              Container(
                width: 8,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isWarning ? kWarningColor : kNormalColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
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

  // 얼음 상태 표시 위젯
  Widget _buildIceMakerStatus(int minutes) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${minutes}분',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Container(
            width: 60,
            height: 110, // 막대 높이 조정
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