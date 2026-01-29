import '../models/models.dart';

class MockApiService {
  Future<List<Recipe>> recommendRecipes(List<FoodItem> availableItems) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple mock logic
    return [
      Recipe(
        title: "크림 당근 스프",
        description: "신선한 당근으로 만든 따뜻하고 맛있는 스프입니다.",
        cookingTimeMin: 30,
        difficulty: "쉬움",
        ingredients: ["당근", "우유", "양파", "버터"],
        instructions: ["당근 썰기", "우유와 함께 끓이기", "부드러워질 때까지 갈기"],
      ),
       Recipe(
        title: "신선한 야채 볶음",
        description: "빠르고 건강한 야채 믹스 볶음 요리입니다.",
        cookingTimeMin: 15,
        difficulty: "보통",
        ingredients: ["당근", "양배추", "간장"],
        instructions: ["채소 썰기", "팬에 볶기", "소스 넣기"],
      ),
    ];
  }
}
