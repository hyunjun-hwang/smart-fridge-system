import 'package:flutter/material.dart';
import 'package:smart_fridge_system/data/models/shopping_item.dart';

class ShoppingListProvider with ChangeNotifier {
  // 장보기 목록 데이터
  List<ShoppingItem> _shoppingItems = [
    ShoppingItem(id: 0, name: '복숭아', isChecked: true),
    ShoppingItem(id: 1, name: '옥수수', isChecked: false),
    ShoppingItem(id: 2, name: '수박', isChecked: false),
  ];

  // Getter
  List<ShoppingItem> get shoppingItems => _shoppingItems;

  // Setter: 목록을 업데이트하고 변경사항을 알림
  void updateShoppingList(List<ShoppingItem> newItems) {
    _shoppingItems = newItems;
    notifyListeners();
  }
}