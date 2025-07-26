import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:smart_fridge_system/ui/pages/auth/WelcomePage.dart';
import 'package:smart_fridge_system/ui/pages/home/mainpage.dart';

import 'package:smart_fridge_system/ui/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
    );
  }
}