import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/models.dart';
import '../../services/spoonacular_service.dart';

class RecipeTab extends StatefulWidget {
  const RecipeTab({super.key});

  @override
  State<RecipeTab> createState() => _RecipeTabState();
}

class _RecipeTabState extends State<RecipeTab> {
  bool _isLoading = false;
  List<Recipe>? _recommendations;

  @override
  Widget build(BuildContext context) {
    final items = context.watch<AppState>().items;

    return Scaffold(
      appBar: AppBar(title: const Text("오늘 뭐 먹지?")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text(
                      "현재 보유 재료 (${items.length})",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text("냉장고가 비어있어요! 재료를 추가해주세요.", style: TextStyle(color: Colors.grey)),
                  )
                else
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_getCategoryEmoji(item.category)),
                              const SizedBox(width: 8),
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _getRecommendations,
                    icon: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Icon(Icons.auto_awesome),
                    label: const Text("레시피 추천받기"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: Text("셰프에게 물어보는 중..."))
                : _recommendations == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book, size: 60, color: Colors.grey),
                            Text("버튼을 눌러 추천을 받아보세요!"),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _recommendations!.length,
                        itemBuilder: (context, index) {
                          return _buildRecipeCard(_recommendations![index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _getRecommendations() async {
    setState(() => _isLoading = true);
    final api = context.read<SpoonacularService>(); // Changed to SpoonacularService
    final items = context.read<AppState>().items;
    
    final results = await api.recommendRecipes(items);
    
    setState(() {
      _isLoading = false;
      _recommendations = results;
    });
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[300],
            child: recipe.imageUrl != null 
                ? Image.network(
                    recipe.imageUrl!,
                    fit: BoxFit.cover,
                  )
                : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  recipe.cookingTimeMin > 0 
                      ? "${recipe.cookingTimeMin}분 • ${recipe.difficulty}"
                      : "Spoonacular 레시피",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 12),
                Text(
                  recipe.description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: recipe.ingredients.map((ing) {
                    return Chip(
                      label: Text(ing, style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryEmoji(FoodCategory c) {
    switch (c) {
      case FoodCategory.meat: return "🥩";
      case FoodCategory.veggie: return "🥦";
      case FoodCategory.dairy: return "🥛";
      case FoodCategory.fruit: return "🍎";
      case FoodCategory.beverage: return "🥤";
      case FoodCategory.sauce: return "🥫";
      case FoodCategory.other: return "📦";
    }
  }
}
