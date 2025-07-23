import 'package:flutter/material.dart';
import 'package:smart_fridge_system/widgets/bottom_nav.dart';

// StatelessWidget으로 변경해도 무방합니다.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 이제 MainScreen은 BottomNav를 호출하기만 합니다.
    return const BottomNav();
  }
}