import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class SpoonacularService {
  static const String _apiKey = '8f0e1e4b31c94af19adcf2438d27094b';
  static const String _baseUrl = 'https://api.spoonacular.com/recipes';

  Future<List<Recipe>> recommendRecipes(List<FoodItem> availableItems) async {
    if (availableItems.isEmpty) return [];

    // Extract ingredient names
    final ingredients = availableItems.map((item) => item.name).join(',');

    try {
      final uri = Uri.parse('$_baseUrl/findByIngredients').replace(queryParameters: {
        'apiKey': _apiKey,
        'ingredients': ingredients,
        'number': '5', // Limit to 5 recipes
        'ranking': '1', // Minimize missing ingredients
        'ignorePantry': 'true',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Map to Recipe objects
        // Note: findByIngredients returns limited info. 
        // For a full app, we would fetch details for each ID.
        // For this MVP, we map what we have and fill defaults.
        return data.map((json) {
          final usedIngredients = (json['usedIngredients'] as List)
              .map((i) => i['original'] as String)
              .toList();
          final missedIngredients = (json['missedIngredients'] as List)
              .map((i) => i['original'] as String)
              .toList();
          
          return Recipe(
            id: json['id'].toString(),
            title: json['title'],
            description: "Spoonacular에서 가져온 레시피입니다.", // Placeholder
            extraIngredients: missedIngredients, // New field for missed ingredients
            cookingTimeMin: 0, // Not provided in this endpoint
            difficulty: "보통", // Not provided
            ingredients: [...usedIngredients, ...missedIngredients],
            instructions: [], // Not provided in this endpoint
            imageUrl: json['image'], // API provides image URL
          );
        }).toList();
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
      return []; // Return empty list on error
    }
  }
}
