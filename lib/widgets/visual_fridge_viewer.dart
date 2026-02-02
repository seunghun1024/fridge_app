import 'package:flutter/material.dart';
import '../models/models.dart';

class VisualFridgeViewer extends StatelessWidget {
  final Fridge fridge;
  final List<FoodItem> items;
  final Function(Slot) onSlotTap;

  const VisualFridgeViewer({
    super.key,
    required this.fridge,
    required this.items,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Analyze existing locations to determine layout
    final hasDoorLeft = fridge.compartments.any((c) => _mapLocation(c.location) == CompartmentLocation.doorLeft);
    final hasDoorRight = fridge.compartments.any((c) => _mapLocation(c.location) == CompartmentLocation.doorRight);
    final hasBodyRight = fridge.compartments.any((c) => _mapLocation(c.location) == CompartmentLocation.bodyRight);
    // Always assume bodyLeft is present or at least the main body
    
    // 2. Determine Column Flex values based on layout type
    /*
     Scenarios:
     - Pantry (BodyLeft only): Flex 1 (Full)
     - One Door (DoorLeft + BodyLeft): Door 1 : Body 2
     - Kimchi (BodyLeft + BodyRight): Body 1 : Body 1
     - Jumbo (All): Door 1 : Body 2 : Body 2 : Door 1
    */
    
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 400),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey[400]!, width: 4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Left Door
          if (hasDoorLeft) ...[
            Expanded(flex: 1, child: _buildColumn(context, CompartmentLocation.doorLeft)),
            const SizedBox(width: 4),
          ],
          
          // 2. Left Body (Always visible, expands if others are missing)
          Expanded(
            flex: (hasBodyRight) ? 2 : (hasDoorLeft ? 2 : 1), 
            child: _buildColumn(context, CompartmentLocation.bodyLeft)
          ),
          
          // 3. Right Body
          if (hasBodyRight) ...[
            const SizedBox(width: 2),
            Expanded(flex: 2, child: _buildColumn(context, CompartmentLocation.bodyRight)),
          ],
          
          // 4. Right Door
          if (hasDoorRight) ...[
            const SizedBox(width: 4),
            Expanded(flex: 1, child: _buildColumn(context, CompartmentLocation.doorRight)),
          ],
        ],
      ),
    );
  }

  Widget _buildColumn(BuildContext context, CompartmentLocation loc) {
    final comps = fridge.compartments
        .where((c) => _mapLocation(c.location) == loc)
        .toList();

    if (comps.isEmpty) {
      // Return a spacer if needed, or nothing. 
      // If the logic above decided to show this column, we should show empty state if comps are missing but column is forced.
      // But our logic above only shows column if comps exist (hasDoorLeft etc). 
      // EXCEPT bodyLeft, which is always shown.
      return Container(
        constraints: const BoxConstraints(minHeight: 100),
        decoration: BoxDecoration(
          color: Colors.grey[300]!.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    return Column(
      children: comps.map((comp) => _buildCompartment(context, comp)).toList(),
    );
  }
  
  CompartmentLocation _mapLocation(CompartmentLocation loc) {
    if (loc == CompartmentLocation.body) return CompartmentLocation.bodyLeft;
    return loc;
  }

  Widget _buildCompartment(BuildContext context, Compartment comp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: _getColorByType(comp.type),
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Background Label
          Positioned(
            top: 2,
            left: 4,
            child: Text(
              comp.name,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: _getTextColorByType(comp.type).withOpacity(0.5),
              ),
            ),
          ),
          
          // Slots Container
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 16, 2, 2),
            child: Column(
              children: [
                 Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: comp.slots.map((slot) {
                      final slotItems = items.where((i) => i.slotId == slot.id).toList();
                      return _buildSlot(context, slot, slotItems, comp.type);
                    }).toList(),
                 )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(BuildContext context, Slot slot, List<FoodItem> slotItems, StorageType type) {
    return GestureDetector(
      onTap: () => onSlotTap(slot),
      child: Container(
        width: 48, 
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             if (slotItems.isNotEmpty)
               Text(
                 _getCategoryEmoji(slotItems.first.category),
                 style: const TextStyle(fontSize: 16),
               )
             else 
               Icon(Icons.add, size: 12, color: Colors.grey),
             
             if (slotItems.length > 1)
                Text(
                  "+${slotItems.length - 1}",
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                )
             else 
                Text(
                  slot.name.isEmpty ? "?" : slot.name.substring(0, 1),
                  style: const TextStyle(fontSize: 8, color: Colors.black54),
                  overflow: TextOverflow.clip,
                )
          ],
        ),
      ),
    );
  }

  // --- Helpers ---
  Color _getColorByType(StorageType type) {
    switch (type) {
      case StorageType.fridge: return Colors.lightBlue[50]!;
      case StorageType.freezer: return Colors.blueGrey[50]!;
      case StorageType.pantry: return Colors.orange[50]!;
      default: return Colors.grey[200]!;
    }
  }
  
  Color _getTextColorByType(StorageType type) {
     switch (type) {
      case StorageType.fridge: return Colors.blue[900]!;
      case StorageType.freezer: return Colors.blueGrey[900]!;
      case StorageType.pantry: return Colors.brown[900]!;
      default: return Colors.black;
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
