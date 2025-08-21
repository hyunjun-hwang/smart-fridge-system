import 'package:flutter/material.dart';

class TemperatureProvider with ChangeNotifier {
  // 냉동고 상태
  double _freezerTemp = -18.0;
  double _freezerHumidity = 75.0;
  String _freezerGasStatus = "점검 필요";

  // 냉장고 상태
  double _fridgeTemp = 3.0;
  double _fridgeHumidity = 60.0;
  String _fridgeGasStatus = "정상";

  // Getters
  double get freezerTemp => _freezerTemp;
  double get freezerHumidity => _freezerHumidity;
  String get freezerGasStatus => _freezerGasStatus;
  double get fridgeTemp => _fridgeTemp;
  double get fridgeHumidity => _fridgeHumidity;
  String get fridgeGasStatus => _fridgeGasStatus;

  // Setters
  void updateFreezerTemp(double temp) {
    _freezerTemp = temp;
    notifyListeners();
  }

  void updateFreezerHumidity(double humidity) {
    _freezerHumidity = humidity;
    notifyListeners();
  }

  void updateFridgeTemp(double temp) {
    _fridgeTemp = temp;
    notifyListeners();
  }

  void updateFridgeHumidity(double humidity) {
    _fridgeHumidity = humidity;
    notifyListeners();
  }
}