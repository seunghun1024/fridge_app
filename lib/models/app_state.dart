import 'package:flutter/material.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  List<Fridge> _fridges = [];
  List<FoodItem> _items = [];
  List<Recipe> _recipes = [];

  List<Fridge> get fridges => _fridges;
  List<FoodItem> get items => _items;
  List<Recipe> get recipes => _recipes;

  AppState() {
    _seedData();
  }

  void _seedData() {
    final mainFridge = Fridge(
      name: "Main Kitchen Fridge",
      modelName: "Samsung Bespoke",
      compartments: [
        Compartment(
          name: "Top Shelf",
          type: StorageType.fridge,
          slots: [Slot(name: "Left"), Slot(name: "Right")],
        ),
         Compartment(
          name: "Vegetable Drawer",
          type: StorageType.fridge,
          slots: [Slot(name: "Bin")],
        ),
         Compartment(
          name: "Freezer",
          type: StorageType.freezer,
          slots: [Slot(name: "Top Drawer"), Slot(name: "Bottom Drawer")],
        ),
      ],
    );
    _fridges = [mainFridge];

    final vegSlotId = mainFridge.compartments[1].slots[0].id;
    _items = [
      FoodItem(
        slotId: vegSlotId,
        name: "Carrots",
        category: FoodCategory.veggie,
        quantity: 3,
        unit: "pcs",
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        purchaseDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      FoodItem(
        slotId: vegSlotId,
        name: "Milk",
        category: FoodCategory.dairy,
        quantity: 1,
        unit: "L",
        expiryDate: DateTime.now().add(const Duration(days: 2)),
        purchaseDate: DateTime.now(),
      ),
       FoodItem(
        slotId: vegSlotId,
        name: "Chicken Breast",
        category: FoodCategory.meat,
        quantity: 500,
        unit: "g",
        expiryDate: DateTime.now().add(const Duration(days: 1)), // EXPIRING SOON
        purchaseDate: DateTime.now(),
      ),
    ];
    notifyListeners();
  }

  void addFridge(Fridge fridge) {
    _fridges.add(fridge);
    notifyListeners();
  }

  void addItem(FoodItem item) {
    _items.add(item);
    notifyListeners();
  }

  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
