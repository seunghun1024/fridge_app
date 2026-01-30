import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/v1';
    return 'http://localhost:8080/api/v1';
  }

  // --- Fridge API ---

  Future<List<Fridge>> getFridges() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/fridges'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Fridge.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load fridges: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching fridges: $e');
      throw e;
    }
  }

  Future<Fridge> createFridge(String name, String type) async {
    final response = await http.post(
      Uri.parse('$baseUrl/fridges'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'type': type}),
    );

    if (response.statusCode == 200) {
      return Fridge.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create fridge');
    }
  }

  Future<void> deleteFridge(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/fridges/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete fridge');
    }
  }

  // --- Item API ---

  Future<List<FoodItem>> getItems(String fridgeId) async {
    final response = await http.get(Uri.parse('$baseUrl/items?fridgeId=$fridgeId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => FoodItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<FoodItem> addItem(FoodItem item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/items'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );

    if (response.statusCode == 200) {
      return FoodItem.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add item');
    }
  }

  Future<void> deleteItem(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/items/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete item');
    }
  }

  // --- Recipe API ---
  
  Future<List<Recipe>> recommendRecipes(List<FoodItem> items) async {
    if (items.isEmpty) return [];
    
    final ingredients = items.map((e) => e.name).join(',');
    final response = await http.get(
      Uri.parse('$baseUrl/recipes/recommend?ingredients=$ingredients'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to recommend recipes');
    }
  }
}
