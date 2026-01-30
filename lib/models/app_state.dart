import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Fridge> _fridges = [];
  List<FoodItem> _items = [];
  bool _isLoading = false;

  List<Fridge> get fridges => _fridges;
  List<FoodItem> get items => _items;
  bool get isLoading => _isLoading;

  AppState() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Try fetching from API
      // If API fails (e.g. backend not running), keep list empty or handle error
      _fridges = await _apiService.getFridges();
      
      // For items, we might need to fetch all items for all fridges
      // Simplification: Fetch items for the first fridge if exists
      if (_fridges.isNotEmpty) {
        _items = await _apiService.getItems(_fridges.first.id); // Or fetch all
      }
    } catch (e) {
      print("Failed to load data from API: $e");
      // Fallback or empty state
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFridge(Fridge fridge) async {
    try {
      final newFridge = await _apiService.createFridge(fridge.name, "JUMBO"); // Simplification
      _fridges.add(newFridge);
      notifyListeners();
    } catch (e) {
      print("Failed to add fridge: $e");
      // For Demo/Dev without backend: Add locally
      _fridges.add(fridge);
      notifyListeners();
    }
  }

  Future<void> addItem(FoodItem item) async {
    try {
      final newItem = await _apiService.addItem(item);
      _items.add(newItem);
      notifyListeners();
    } catch (e) {
      print("Failed to add item: $e");
      // For Demo/Dev: Add locally
      _items.add(item);
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _apiService.deleteItem(id);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      print("Failed to delete item: $e");
       // For Demo/Dev: Remove locally
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    }
  }
}
