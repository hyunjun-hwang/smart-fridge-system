// FILE: lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Providers
import 'package:smart_fridge_system/providers/food_provider.dart';
import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/providers/shopping_list_provider.dart';
import 'package:smart_fridge_system/providers/temperature_provider.dart';

// UI
import 'package:smart_fridge_system/ui/widgets/bottom_nav.dart';
import 'package:smart_fridge_system/ui/pages/auth/WelcomePage.dart';

// Models & Hive Adapters
import 'package:smart_fridge_system/data/models/food_item.dart';
import 'firebase_options.dart';

void main() async {
  // Flutter 엔진 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive 초기화
  await Hive.initFlutter();

  // Hive 어댑터 등록
  Hive.registerAdapter(FoodItemAdapter());
  Hive.registerAdapter(FoodCategoryAdapter());
  Hive.registerAdapter(StorageTypeAdapter());
  Hive.registerAdapter(UnitAdapter());

  // Hive Box 열기
  await Hive.openBox('nutritionBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider로 앱 전체에 필요한 Provider들을 한 번에 제공합니다.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => DailyNutritionProvider()..restore()),
        ChangeNotifierProvider(create: (_) => TemperatureProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingListProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Fridge System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Pretendard',
        ),
        // 로그인 상태에 따라 다른 화면을 보여주는 로직을 AuthWrapper 위젯으로 분리
        home: const AuthWrapper(),
      ),
    );
  }
}

/// 인증 상태를 확인하고 화면을 전환하는 위젯
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // FirebaseAuth의 인증 상태 변경을 실시간으로 감지
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 연결을 기다리는 중일 때 로딩 인디케이터 표시
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // snapshot.hasData는 사용자가 로그인 상태인지 확인
        if (snapshot.hasData) {
          // 로그인 상태이면 메인 화면(BottomNav)으로 이동
          return BottomNav(key: bottomNavKey);
        } else {
          // 로그아웃 상태이면 시작 화면(WelcomePage)으로 이동
          return const WelcomePage();
        }
      },
    );
  }
}