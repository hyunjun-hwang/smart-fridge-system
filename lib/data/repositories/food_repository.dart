// lib/data/repositories/food_repository.dart

import 'dart:async';
import '../models/food_item.dart'; // FoodItem 모델의 위치

class FoodRepository {
  // 이 함수가 나중에 Firebase에서 데이터를 가져오는 코드로 채워집니다.
  // 지금은 시뮬레이션을 위해 1초 뒤에 기존 데이터를 반환하도록 만듭니다.
  Future<List<FoodItem>> getFoodItems() async {
    // 가짜 딜레이 (네트워크 통신을 흉내)
    await Future.delayed(const Duration(seconds: 1));

    // 나중에는 이 부분이 Firebase Firestore를 호출하는 코드가 됩니다.
    // 예: final snapshot = await FirebaseFirestore.instance.collection('foods').get();
    //     return snapshot.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();

    // 현재는 기존 샘플 데이터를 그대로 반환
    return [
      FoodItem(name: '사과', quantity: '6개', imageUrl: 'https://images.unsplash.com/photo-1579613832125-5d34a13ffe2a?q=80&w=2940&auto=format&fit=crop', expiryDate: '2025. 08. 22', dDay: 30),
      FoodItem(name: '아보카도', quantity: '2개', imageUrl: 'https://images.unsplash.com/photo-1579613832125-5d34a13ffe2a?q=80&w=2940&auto=format&fit=crop', expiryDate: '2025. 08. 02', dDay: 10),
      FoodItem(name: '소고기', quantity: '350g', imageUrl: 'https://images.unsplash.com/photo-1579613832125-5d34a13ffe2a?q=80&w=2940&auto=format&fit=crop', expiryDate: '2025. 07. 24', dDay: 1),
      FoodItem(name: '우유', quantity: '1개', imageUrl: 'https://plus.unsplash.com/premium_photo-1663852297267-827c73e7529e?q=80&w=2940&auto=format&fit=crop', expiryDate: '2025. 07. 28', dDay: 5),
      FoodItem(name: '사과', quantity: '6개', imageUrl: 'https://images.unsplash.com/photo-1579613832125-5d34a13ffe2a?q=80&w=2940&auto=format&fit=crop', expiryDate: '2025. 08. 22', dDay: 30),
      FoodItem(name: '아보카도', quantity: '2개', imageUrl: 'https://images.unsplash.com/photo-1579613832125-5d34a13ffe2a?q=80&w=2940&auto=format&fit=crop', expiryDate: '2025. 08. 02', dDay: 10),
      FoodItem(name: '소고기', quantity: '350g', imageUrl: 'https://images.unsplash.com/photo-1579613832125-5d34a13ffe2a?q=80&w=2940&auto=format&fit=crop', expiryDate: '2025. 07. 24', dDay: 1),
      FoodItem(name: '우유', quantity: '1개', imageUrl: 'https://plus.unsplash.com/premium_photo-1663852297267-827c73e7529e?q=80&w=2940&auto=format&fit=crop', expiryDate: '2025. 07. 28', dDay: 5),
    ];
  }
}