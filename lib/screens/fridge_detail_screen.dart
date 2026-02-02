import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/models.dart';
import '../widgets/visual_fridge_viewer.dart';
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
          children: [
            // Tips or Summary (Optional)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "원하는 구역을 터치하여 식재료를 확인하고 관리하세요.",
                      style: TextStyle(color: Colors.blue[900], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            
            // Visual Fridge
            VisualFridgeViewer(
              fridge: fridge,
              items: allItems,
              onSlotTap: (slot) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SlotDetailScreen(slot: slot),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
