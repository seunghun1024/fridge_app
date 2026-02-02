import 'package:uuid/uuid.dart';

const uuid = Uuid();

enum StorageType { fridge, freezer, pantry, manual }
enum CompartmentLocation { body, doorLeft, doorRight, bodyLeft, bodyRight } // Expanded for side-by-side
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

  factory Fridge.fromJson(Map<String, dynamic> json) {
    return Fridge(
      id: json['id'],
      name: json['name'],
      modelName: json['modelName'] ?? '',
      compartments: (json['compartments'] as List)
          .map((i) => Compartment.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'modelName': modelName,
      'compartments': compartments.map((e) => e.toJson()).toList(),
    };
  }
}

class Compartment {
  final String id;
  final String name;
  final StorageType type;
  final CompartmentLocation location; // New field
  final List<Slot> slots;

  Compartment({
    String? id,
    required this.name,
    required this.type,
    this.location = CompartmentLocation.body, // Default to body
    required this.slots,
  }) : id = id ?? uuid.v4();

  factory Compartment.fromJson(Map<String, dynamic> json) {
    return Compartment(
      id: json['id'],
      name: json['name'],
      type: StorageType.values.firstWhere((e) => e.name.toUpperCase() == json['type'], orElse: () => StorageType.fridge),
      location: CompartmentLocation.values.firstWhere(
        (e) => e.name == (json['location'] ?? 'body'), 
        orElse: () => CompartmentLocation.body
      ),
      slots: (json['slots'] as List).map((i) => Slot.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name.toUpperCase(),
      'location': location.name,
      'slots': slots.map((e) => e.toJson()).toList(),
    };
  }
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

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['id'],
      name: json['name'],
      gridX: json['gridX'] ?? 1,
      gridY: json['gridY'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gridX': gridX,
      'gridY': gridY,
    };
  }
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

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      slotId: json['slotId'] ?? '', // Handle potential missing slotId in flat list
      name: json['name'],
      category: FoodCategory.values.firstWhere((e) => e.name.toUpperCase() == json['category'], orElse: () => FoodCategory.other),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
      expiryDate: DateTime.parse(json['expiryDate']),
      purchaseDate: DateTime.parse(json['purchaseDate']),
      memo: json['memo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slotId': slotId,
      'name': name,
      'category': category.name.toUpperCase(),
      'quantity': quantity,
      'unit': unit,
      'expiryDate': expiryDate.toIso8601String(),
      'purchaseDate': purchaseDate.toIso8601String(),
      'memo': memo,
    };
  }

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
  final List<String> extraIngredients;
  final List<String> instructions;
  final String? imageUrl;

  Recipe({
    String? id,
    required this.title,
    required this.description,
    required this.cookingTimeMin,
    required this.difficulty,
    required this.ingredients,
    this.extraIngredients = const [],
    required this.instructions,
    this.imageUrl,
  }) : id = id ?? uuid.v4();
  
  factory Recipe.fromJson(Map<String, dynamic> json) {
     return Recipe(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'] ?? '',
      cookingTimeMin: json['cookingTimeMin'] ?? 0,
      difficulty: json['difficulty'] ?? 'Unknown',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      extraIngredients: List<String>.from(json['extraIngredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      imageUrl: json['imageUrl'],
    );
  }
}
