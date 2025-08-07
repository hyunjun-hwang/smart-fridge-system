// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodItemAdapter extends TypeAdapter<FoodItem> {
  @override
  final int typeId = 0;

  @override
  FoodItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodItem(
      id: fields[0] as String,
      name: fields[1] as String,
      imageUrl: fields[2] as String,
      quantity: fields[3] as int,
      unit: fields[4] as Unit,
      expiryDate: fields[5] as DateTime,
      stockedDate: fields[6] as DateTime,
      storage: fields[7] as StorageType,
      category: fields[8] as FoodCategory,
    );
  }

  @override
  void write(BinaryWriter writer, FoodItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.expiryDate)
      ..writeByte(6)
      ..write(obj.stockedDate)
      ..writeByte(7)
      ..write(obj.storage)
      ..writeByte(8)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodCategoryAdapter extends TypeAdapter<FoodCategory> {
  @override
  final int typeId = 1;

  @override
  FoodCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FoodCategory.fruit;
      case 1:
        return FoodCategory.meat;
      case 2:
        return FoodCategory.vegetable;
      case 3:
        return FoodCategory.dairy;
      default:
        return FoodCategory.fruit;
    }
  }

  @override
  void write(BinaryWriter writer, FoodCategory obj) {
    switch (obj) {
      case FoodCategory.fruit:
        writer.writeByte(0);
        break;
      case FoodCategory.meat:
        writer.writeByte(1);
        break;
      case FoodCategory.vegetable:
        writer.writeByte(2);
        break;
      case FoodCategory.dairy:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StorageTypeAdapter extends TypeAdapter<StorageType> {
  @override
  final int typeId = 2;

  @override
  StorageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StorageType.fridge;
      case 1:
        return StorageType.freezer;
      default:
        return StorageType.fridge;
    }
  }

  @override
  void write(BinaryWriter writer, StorageType obj) {
    switch (obj) {
      case StorageType.fridge:
        writer.writeByte(0);
        break;
      case StorageType.freezer:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UnitAdapter extends TypeAdapter<Unit> {
  @override
  final int typeId = 3;

  @override
  Unit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Unit.count;
      case 1:
        return Unit.grams;
      default:
        return Unit.count;
    }
  }

  @override
  void write(BinaryWriter writer, Unit obj) {
    switch (obj) {
      case Unit.count:
        writer.writeByte(0);
        break;
      case Unit.grams:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
