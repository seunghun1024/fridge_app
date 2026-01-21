import 'package:flutter/material.dart';
import '../models/models.dart';
import 'slot_detail_screen.dart';

class FridgeDetailScreen extends StatelessWidget {
  final Fridge fridge;

  const FridgeDetailScreen({super.key, required this.fridge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fridge.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: fridge.compartments.map((compartment) {
            return _buildCompartment(context, compartment);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCompartment(BuildContext context, Compartment compartment) {
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueGrey[50], // Cool tone for fridge
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueGrey[100]!),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: compartment.slots.map((slot) {
              return _buildSlot(context, slot);
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSlot(BuildContext context, Slot slot) {
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
        width: 100, // Fixed width for consistent look
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shelves, color: Colors.blueGrey),
            const SizedBox(height: 4),
            Text(
              slot.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
