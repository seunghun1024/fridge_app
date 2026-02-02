import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/models.dart';
import '../widgets/visual_fridge_editor.dart';

class AddFridgeScreen extends StatefulWidget {
  const AddFridgeScreen({super.key});

  @override
  State<AddFridgeScreen> createState() => _AddFridgeScreenState();
}

class _AddFridgeScreenState extends State<AddFridgeScreen> {
  final _nameController = TextEditingController();
  
  // State for the builder
  List<Compartment> _compartments = [];

  @override
  void initState() {
    super.initState();
    // Initialize with default template (Jumbo / 4-Door)
    _compartments = [
          // Left Door
          Compartment(name: "상단 포켓", type: StorageType.fridge, location: CompartmentLocation.doorLeft, slots: [Slot(name: "소스")]),
          Compartment(name: "중단 포켓", type: StorageType.fridge, location: CompartmentLocation.doorLeft, slots: [Slot(name: "음료")]),
          Compartment(name: "하단 포켓", type: StorageType.fridge, location: CompartmentLocation.doorLeft, slots: [Slot(name: "물")]),
          
          // Left Body (Main Fridge)
          Compartment(name: "냉장실 상단", type: StorageType.fridge, location: CompartmentLocation.bodyLeft, slots: [Slot(name: "반찬")]),
          Compartment(name: "냉장실 하단", type: StorageType.fridge, location: CompartmentLocation.bodyLeft, slots: [Slot(name: "식재료")]),
          Compartment(name: "야채실", type: StorageType.fridge, location: CompartmentLocation.bodyLeft, slots: [Slot(name: "야채/과일")]),

          // Right Body (Freezer)
          Compartment(name: "냉동실 상단", type: StorageType.freezer, location: CompartmentLocation.bodyRight, slots: [Slot(name: "얼음")]),
          Compartment(name: "냉동실 중단", type: StorageType.freezer, location: CompartmentLocation.bodyRight, slots: [Slot(name: "육류/생선")]),
          Compartment(name: "냉동실 하단", type: StorageType.freezer, location: CompartmentLocation.bodyRight, slots: [Slot(name: "냉동식품")]),
          
          // Right Door
          Compartment(name: "상단 포켓", type: StorageType.freezer, location: CompartmentLocation.doorRight, slots: [Slot(name: "아이스")]),
          Compartment(name: "하단 포켓", type: StorageType.freezer, location: CompartmentLocation.doorRight, slots: [Slot(name: "기타")]),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("냉장고 추가")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Name Input
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "냉장고 이름 (예: 집 냉장고)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Structure Editor
                  Text("내부 구조 상세 설정", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  
                  // Visual Builder Integration
                  VisualFridgeEditor(
                    compartments: _compartments,
                    onUpdate: (updated) {
                      setState(() {
                        _compartments = updated;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // 3. Save Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveFridge,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("저장하기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveFridge() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("냉장고 이름을 입력해주세요.")));
      return;
    }
    if (_compartments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("적어도 하나의 칸이 필요합니다.")));
      return;
    }

    final newFridge = Fridge(
      name: _nameController.text,
      modelName: "Custom Fridge", // Simplified model name
      compartments: _compartments,
    );

    context.read<AppState>().addFridge(newFridge);
    Navigator.pop(context);
  }
}
