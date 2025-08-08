// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/providers/daily_nutrition_provider.dart';
import 'package:smart_fridge_system/ui/widgets/bottom_nav.dart';
import 'package:smart_fridge_system/ui/pages/auth/WelcomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DailyNutritionProvider()),
      ],
      // ✅ MaterialApp을 StreamBuilder로 감싸서 인증 상태를 확인합니다.
      child: MaterialApp(
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