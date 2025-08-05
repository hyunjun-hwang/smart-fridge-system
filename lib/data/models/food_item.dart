// lib/data/models/food_item.dart

import 'package:hive/hive.dart';

part 'food_item.g.dart';

@HiveType(typeId: 1)
enum FoodCategory {
  @HiveField(0)
  fruit('과일'),
  @HiveField(1)
  meat('고기'),
  @HiveField(2)
  vegetable('채소'),
  @HiveField(3)
  dairy('유제품');

  const FoodCategory(this.displayName);
  final String displayName;
}

@HiveType(typeId: 2)
enum StorageType {
  @HiveField(0)
  fridge('냉장실'),
  @HiveField(1)
  freezer('냉동고');

  const StorageType(this.displayName);
  final String displayName;
}

@HiveType(typeId: 3)
enum Unit {
  @HiveField(0)
  count('개'),
  @HiveField(1)
  grams('g');

  const Unit(this.displayName);
  final String displayName;
}


@HiveType(typeId: 0)
class FoodItem extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final Unit unit;

  @HiveField(5)
  final DateTime expiryDate;

  @HiveField(6)
  final DateTime stockedDate;

  @HiveField(7)
  final StorageType storage;

  @HiveField(8)
  final FoodCategory category;

  FoodItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    required this.stockedDate,
    required this.storage,
    required this.category,
  });

  int get dDay {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final expiryDateOnly = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final difference = expiryDateOnly.difference(todayDate).inDays;
    return difference;
  }
}