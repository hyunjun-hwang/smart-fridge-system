import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TemperatureProvider with ChangeNotifier {
  final DocumentReference _docRef =
  FirebaseFirestore.instance.collection('fridge_status').doc('current_state');
  late StreamSubscription<DocumentSnapshot> _docSubscription;

  // 상태 변수를 '현재(current)'와 '목표(target)'로 분리
  // 냉동고
  double _freezerCurrentTemp = -20.0;
  double _freezerTargetTemp = -20.0;
  double _freezerCurrentHumidity = 50.0;
  String _freezerCurrentGasStatus = '로딩중...';

  // 냉장고
  double _fridgeCurrentTemp = 3.0;
  double _fridgeTargetTemp = 3.0;
  double _fridgeCurrentHumidity = 60.0;
  String _fridgeCurrentGasStatus = '로딩중...';

  bool _isLoading = true;

  // Getter도 현재/목표 값에 맞게 분리
  // 냉동고 Getter
  double get freezerCurrentTemp => _freezerCurrentTemp;
  double get freezerTargetTemp => _freezerTargetTemp;
  double get freezerCurrentHumidity => _freezerCurrentHumidity;
  String get freezerCurrentGasStatus => _freezerCurrentGasStatus;

  // 냉장고 Getter
  double get fridgeCurrentTemp => _fridgeCurrentTemp;
  double get fridgeTargetTemp => _fridgeTargetTemp;
  double get fridgeCurrentHumidity => _fridgeCurrentHumidity;
  String get fridgeCurrentGasStatus => _fridgeCurrentGasStatus;

  bool get isLoading => _isLoading;

  TemperatureProvider() {
    _listenToDbChanges();
  }

  /// Firestore 문서 변경 실시간 감지
  void _listenToDbChanges() {
    if (kDebugMode) {
      print("🔎 Firestore 데이터 감지를 시작합니다... 경로: ${_docRef.path}");
    }

    _docSubscription = _docRef.snapshots().listen((snapshot) {
      if (kDebugMode) {
        print("✅ Firestore로부터 응답을 받았습니다!");
      }

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;

        // 냉동고 데이터 파싱
        if (data['freezer'] != null) {
          final freezerData = data['freezer'] as Map<String, dynamic>;
          _freezerCurrentTemp = (freezerData['current_temperature'] as num?)?.toDouble() ?? -20.0;
          _freezerTargetTemp = (freezerData['target_temperature'] as num?)?.toDouble() ?? -20.0;
          _freezerCurrentHumidity = (freezerData['current_humidity'] as num?)?.toDouble() ?? 50.0;
          _freezerCurrentGasStatus = freezerData['current_gasstatus'] ?? '정보 없음';
        }

        // 냉장고 데이터 파싱
        if (data['fridge'] != null) {
          final fridgeData = data['fridge'] as Map<String, dynamic>;
          _fridgeCurrentTemp = (fridgeData['current_temperature'] as num?)?.toDouble() ?? 3.0;
          _fridgeTargetTemp = (fridgeData['target_temperature'] as num?)?.toDouble() ?? 3.0;
          _fridgeCurrentHumidity = (fridgeData['current_humidity'] as num?)?.toDouble() ?? 60.0;
          _fridgeCurrentGasStatus = fridgeData['current_gasstatus'] ?? '정보 없음';
        }

        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        _freezerCurrentGasStatus = '데이터 없음';
        _fridgeCurrentGasStatus = '데이터 없음';
        notifyListeners();
      }
    }, onError: (error) {
      if (kDebugMode) {
        print("🚨🚨🚨 Firestore 에러 발생!: $error");
      }
      _isLoading = false;
      _freezerCurrentGasStatus = '에러';
      _fridgeCurrentGasStatus = '에러';
      notifyListeners();
    });
  }

  // 업데이트 함수는 'target' 필드만 수정
  Future<void> updateFreezerTargetTemp(double temp) async {
    await _docRef.update({'freezer.target_temperature': temp});
  }

  Future<void> updateFridgeTargetTemp(double temp) async {
    await _docRef.update({'fridge.target_temperature': temp});
  }

  @override
  void dispose() {
    _docSubscription.cancel();
    super.dispose();
  }
}