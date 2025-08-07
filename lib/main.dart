// FILE: lib/main.dart

import 'package:flutter/material.dart';
import 'package:smart_fridge_system/ui/widgets/bottom_nav.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Fridge System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BottomNav(key: bottomNavKey),
    );
  }
}