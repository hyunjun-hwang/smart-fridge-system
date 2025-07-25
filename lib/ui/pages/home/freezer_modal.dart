import 'package:flutter/material.dart';

class FreezerModal extends StatefulWidget {
  const FreezerModal({super.key});

  @override
  State<FreezerModal> createState() => _FreezerModalState();
}

class _FreezerModalState extends State<FreezerModal> {
  double _temp = -5;
  double _humidity = 75;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("냉동고", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSlider("온도", _temp, -20, 5, (val) => setState(() => _temp = val)),
          _buildSlider("습도", _humidity, 0, 100, (val) => setState(() => _humidity = val)),
          const SizedBox(height: 10),
          const Text("가스 상태: 점검 필요", style: TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          const Text("얼음 완성까지 15분", style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

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
