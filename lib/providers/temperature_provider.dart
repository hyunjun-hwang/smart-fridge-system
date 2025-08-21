import 'package:flutter/material.dart';
import 'package:smart_fridge_system/data/models/fridge_status.dart';

class TemperatureProvider with ChangeNotifier {
  FridgeSectionStatus _freezerStatus = FridgeSectionStatus(
    temperature: -18.0,
    humidity: 75.0,
    gasStatus: "점검 필요",
  );

  FridgeSectionStatus _fridgeStatus = FridgeSectionStatus(
    temperature: 3.0,
    humidity: 60.0,
    gasStatus: "정상",
  );

  // Getters
  FridgeSectionStatus get freezerStatus => _freezerStatus;
  FridgeSectionStatus get fridgeStatus => _fridgeStatus;

  /// Firestore 등 외부 데이터로 전체 상태를 업데이트하는 메서드
  void updateAllStatus(Map<String, dynamic> data) {
    if (data['freezer'] != null && data['freezer'] is Map<String, dynamic>) {
      _freezerStatus = FridgeSectionStatus.fromMap(data['freezer']);
    }
    if (data['fridge'] != null && data['fridge'] is Map<String, dynamic>) {
      _fridgeStatus = FridgeSectionStatus.fromMap(data['fridge']);
    }
    notifyListeners();
  }

  // --- UI 컨트롤을 위한 개별 업데이트 메서드 ---

  void updateFreezerTemp(double temp) {
    // 기존 값을 유지하면서 온도만 새로 설정한 새 객체를 생성
    _freezerStatus = FridgeSectionStatus(
      temperature: temp,
      humidity: _freezerStatus.humidity,
      gasStatus: _freezerStatus.gasStatus,
    );
    notifyListeners();
  }

  void updateFreezerHumidity(double humidity) {
    _freezerStatus = FridgeSectionStatus(
      temperature: _freezerStatus.temperature,
      humidity: humidity,
      gasStatus: _freezerStatus.gasStatus,
    );
    notifyListeners();
  }

  void updateFridgeTemp(double temp) {
    _fridgeStatus = FridgeSectionStatus(
      temperature: temp,
      humidity: _fridgeStatus.humidity,
      gasStatus: _fridgeStatus.gasStatus,
    );
    notifyListeners();
  }

  void updateFridgeHumidity(double humidity) {
    _fridgeStatus = FridgeSectionStatus(
      temperature: _fridgeStatus.temperature,
      humidity: humidity,
      gasStatus: _fridgeStatus.gasStatus,
    );
    notifyListeners();
  }
}