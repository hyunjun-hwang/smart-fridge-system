import 'package:flutter/material.dart';

class FridgeModal extends StatefulWidget {
  const FridgeModal({super.key});

  @override
  State<FridgeModal> createState() => _FridgeModalState();
}

class _FridgeModalState extends State<FridgeModal> {
  double _temp = 2;
  double _humidity = 60;

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
          const Text("냉장고", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSlider("온도", _temp, -5, 10, (val) => setState(() => _temp = val)),
          _buildSlider("습도", _humidity, 0, 100, (val) => setState(() => _humidity = val)),
          const SizedBox(height: 10),
          const Text("가스 상태: 정상", style: TextStyle(color: Colors.green)),
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
