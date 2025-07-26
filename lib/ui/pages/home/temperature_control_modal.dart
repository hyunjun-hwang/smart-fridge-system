// FILE: temperature_control_modal.dart

import 'package:flutter/material.dart';
import 'package:smart_fridge_system/constants/app_colors.dart';

// 온도/습도 조절을 위한 공용 모달 위젯
class TemperatureControlModal extends StatefulWidget {
  // 위젯 생성 시 부모 위젯(HomePage)으로부터 전달받는 값들
  final String title;                 // 모달 제목 (e.g., "냉장고", "냉동고")
  final double initialTemp;           // 초기 온도 값
  final double minTemp;               // 최소 온도 값
  final double maxTemp;               // 최대 온도 값
  final double initialHumidity;       // 초기 습도 값
  final ValueChanged<double> onTempChanged; // 온도 변경 시 호출될 콜백 함수
  final ValueChanged<double> onHumidityChanged; // 습도 변경 시 호출될 콜백 함수
  final Widget? extraContent;         // 추가적으로 표시할 위젯 (e.g., 가스 상태)

  const TemperatureControlModal({
    super.key,
    required this.title,
    required this.initialTemp,
    required this.minTemp,
    required this.maxTemp,
    required this.initialHumidity,
    required this.onTempChanged,
    required this.onHumidityChanged,
    this.extraContent,
  });

  @override
  State<TemperatureControlModal> createState() => _TemperatureControlModalState();
}

class _TemperatureControlModalState extends State<TemperatureControlModal> {
  // 모달 내부에서 사용할 상태 변수
  late double _temp;
  late double _humidity;

  // 위젯이 처음 생성될 때 호출되는 메소드
  @override
  void initState() {
    super.initState();
    // 부모로부터 받은 초기 값으로 내부 상태를 설정
    _temp = widget.initialTemp;
    _humidity = widget.initialHumidity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: AppColors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 컨텐츠 크기에 맞게 높이 조절
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          // 온도 조절 슬라이더
          _buildSlider("온도", _temp, widget.minTemp, widget.maxTemp, (val) {
            setState(() => _temp = val);     // 1. 모달 내부 UI 업데이트
            widget.onTempChanged(val);      // 2. 부모 위젯(HomePage)에 변경된 값 전달
          }),
          // 습도 조절 슬라이더
          _buildSlider("습도", _humidity, 0, 100, (val) {
            setState(() => _humidity = val);  // 1. 모달 내부 UI 업데이트
            widget.onHumidityChanged(val);   // 2. 부모 위젯(HomePage)에 변경된 값 전달
          }),
          const SizedBox(height: 10),
          // 추가 컨텐츠가 있으면 표시
          if (widget.extraContent != null) ...[
            widget.extraContent!,
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  // 슬라이더 UI를 만드는 재사용 메소드
  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toStringAsFixed(1)}"),
        Slider(
          value: value,
          onChanged: onChanged,
          min: min,
          max: max,
        ),
      ],
    );
  }
}