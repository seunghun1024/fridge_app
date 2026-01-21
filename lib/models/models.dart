import 'package:uuid/uuid.dart';

const uuid = Uuid();

enum StorageType { fridge, freezer, pantry, manual }
enum FoodCategory { meat, veggie, dairy, fruit, beverage, sauce, other }

class Fridge {
  final String id;
  final String name;
  final String modelName;
  final List<Compartment> compartments;

  Fridge({
    String? id,
    required this.name,
    required this.modelName,
    required this.compartments,
  }) : id = id ?? uuid.v4();
}

class Compartment {
  final String id;
  final String name;
  final StorageType type;
  final List<Slot> slots;

  Compartment({
    String? id,
    required this.name,
    required this.type,
    required this.slots,
  }) : id = id ?? uuid.v4();
}

class Slot {
  final String id;
  final String name;
  final int gridX;
  final int gridY;

  Slot({
    String? id,
    required this.name,
    this.gridX = 1,
    this.gridY = 1,
  }) : id = id ?? uuid.v4();
}

class FoodItem {
  final String id;
  final String slotId;
  final String name;
  final FoodCategory category;
  final double quantity;
  final String unit;
  final DateTime expiryDate;
  final DateTime purchaseDate;
  final String? memo;

  FoodItem({
    String? id,
    required this.slotId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    required this.purchaseDate,
    this.memo,
  }) : id = id ?? uuid.v4();

  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }
}

class Recipe {
  final String id;
  final String title;
  final String description;
  final int cookingTimeMin;
  final String difficulty;
  final List<String> ingredients;
  final List<String> instructions;

  Recipe({
    String? id,
    required this.title,
    required this.description,
    required this.cookingTimeMin,
    required this.difficulty,
    required this.ingredients,
    required this.instructions,
  }) : id = id ?? uuid.v4();
}
