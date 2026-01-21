import '../models/models.dart';

class MockApiService {
  Future<List<Recipe>> recommendRecipes(List<FoodItem> availableItems) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple mock logic
    return [
      Recipe(
        title: "Creamy Carrot Soup",
        description: "A warm and delicious soup made from fresh carrots.",
        cookingTimeMin: 30,
        difficulty: "Easy",
        ingredients: ["Carrots", "Milk", "Onion", "Butter"],
        instructions: ["Chop carrots", "Boil with milk", "Blend until smooth"],
      ),
       Recipe(
        title: "Vegetable Stir Fry",
        description: "Quick and healthy mix of vegetables.",
        cookingTimeMin: 15,
        difficulty: "Medium",
        ingredients: ["Carrots", "Cabbage", "Soy Sauce"],
        instructions: ["Slice veggies", "Stir fry in pan", "Add sauce"],
      ),
    ];
  }
}
