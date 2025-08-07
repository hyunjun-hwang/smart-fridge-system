// FILE: lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_fridge_system/data/models/food_item.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/ui/widgets/bottom_nav.dart';
import 'package:smart_fridge_system/ui/pages/auth/WelcomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_fridge_system/providers/food_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();

  // Hive 어댑터 등록
  Hive.registerAdapter(FoodItemAdapter());
  Hive.registerAdapter(FoodCategoryAdapter());
  Hive.registerAdapter(StorageTypeAdapter());
  Hive.registerAdapter(UnitAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DailyNutritionProvider()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Fridge System', // Jieun 브랜치의 title 추가
        theme: ThemeData( // Jieun 브랜치의 theme 추가
          primarySwatch: Colors.blue,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // 연결 중일 때는 로딩 화면을 보여줍니다.
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // snapshot.hasData는 사용자가 로그인했음을 의미합니다.
            if (snapshot.hasData) {
              // 로그인 상태이면 BottomNav (메인 페이지)를 보여줍니다.
              return const BottomNav();
            } else {
              // 로그아웃 상태이면 WelcomePage를 보여줍니다.
              return const WelcomePage();
            }
          },
        ),
      ),
    );
  }
}
