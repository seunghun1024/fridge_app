import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/models.dart';
import 'slot_detail_screen.dart';

class FridgeDetailScreen extends StatelessWidget {
  final Fridge fridge;

  const FridgeDetailScreen({super.key, required this.fridge});

  @override
  Widget build(BuildContext context) {
    final allItems = context.watch<AppState>().items;

    return Scaffold(
      appBar: AppBar(
        title: Text(fridge.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: fridge.compartments.map((compartment) {
            return _buildCompartment(context, compartment, allItems);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCompartment(BuildContext context, Compartment compartment, List<FoodItem> allItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            compartment.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueGrey[50], // Cool tone for fridge
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueGrey[100]!),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: compartment.slots.map((slot) {
              final slotItems = allItems.where((i) => i.slotId == slot.id).toList();
              return _buildSlot(context, slot, slotItems);
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSlot(BuildContext context, Slot slot, List<FoodItem> items) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SlotDetailScreen(slot: slot),
          ),
        );
      },
      child: Container(
        width: 100,
        height: 110,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              slot.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 12, thickness: 0.5),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Icon(Icons.add_circle_outline, 
                        color: Colors.grey[300], size: 24),
                    )
                  : Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      children: items.take(4).map((item) {
                        return Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(item.category).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _getCategoryEmoji(item.category),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            if (items.length > 4)
              Text(
                "+${items.length - 4}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(FoodCategory c) {
    switch (c) {
      case FoodCategory.meat: return Colors.red;
      case FoodCategory.veggie: return Colors.green;
      case FoodCategory.dairy: return Colors.blue;
      case FoodCategory.fruit: return Colors.orange;
      case FoodCategory.beverage: return Colors.purple;
      case FoodCategory.sauce: return Colors.brown;
      case FoodCategory.other: return Colors.grey;
    }
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
