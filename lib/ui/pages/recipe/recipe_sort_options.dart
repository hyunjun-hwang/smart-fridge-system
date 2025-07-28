import 'package:flutter/material.dart';

class RecipeSortOptions extends StatefulWidget {
  final String selectedOption;
  final ValueChanged<String> onOptionSelected;

  const RecipeSortOptions({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  State<RecipeSortOptions> createState() => _RecipeSortOptionsState();
}

class _RecipeSortOptionsState extends State<RecipeSortOptions> {
  late String _selected;

  final List<String> _options = [
    '추천 레시피 순',
    '칼로리 순',
    '유통기한 임박 순',
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _options.map((option) {
        return ListTile(
          title: Text(
            option,
            style: TextStyle(
              fontFamily: 'Pretendard Variable',
              fontSize: 14,
              fontWeight: _selected == option ? FontWeight.w600 : FontWeight.normal,
              color: const Color(0xFF003508),
            ),
          ),
          trailing: Radio<String>(
            value: option,
            groupValue: _selected,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selected = value;
                });
                widget.onOptionSelected(value); // 외부 콜백 호출
                Navigator.pop(context); // 선택 후 바텀시트 닫기 (선택적)
              }
            },
            activeColor: const Color(0xFFD1DFA6),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        );
      }).toList(),
    );
  }
}
