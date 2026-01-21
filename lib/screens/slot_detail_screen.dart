import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../models/app_state.dart';
import 'add_item_screen.dart';

class SlotDetailScreen extends StatelessWidget {
  final Slot slot;

  const SlotDetailScreen({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    final allItems = context.watch<AppState>().items;
    final slotItems = allItems.where((i) => i.slotId == slot.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(slot.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemScreen(slot: slot)),
              );
            },
          ),
        ],
      ),
      body: slotItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.kitchen_outlined, size: 64, color: Colors.grey[300]),
                   const SizedBox(height: 16),
                   Text("Empty Slot", style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: slotItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = slotItems[index];
                return _buildItemCard(context, item);
              },
            ),
    );
  }

  Widget _buildItemCard(BuildContext context, FoodItem item) {
    final daysLeft = item.daysUntilExpiry;
    Color statusColor = Colors.green;
    String statusText = "Fresh";

    if (daysLeft < 0) {
      statusColor = Colors.grey;
      statusText = "Expired";
    } else if (daysLeft <= 3) {
      statusColor = Colors.red;
      statusText = "D-$daysLeft";
    } else if (daysLeft <= 7) {
      statusColor = Colors.orange;
      statusText = "D-$daysLeft";
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Text(
            _getCategoryEmoji(item.category),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${item.quantity} ${item.unit} • Expires ${DateFormat('MM/dd').format(item.expiryDate)}"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
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
