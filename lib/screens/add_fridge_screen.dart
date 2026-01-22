import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/models.dart';

class AddFridgeScreen extends StatefulWidget {
  const AddFridgeScreen({super.key});

  @override
  State<AddFridgeScreen> createState() => _AddFridgeScreenState();
}

class _AddFridgeScreenState extends State<AddFridgeScreen> {
  final _nameController = TextEditingController();
  String _selectedType = 'Jumbo'; // Default type

  final Map<String, String> _typeLabels = {
    'Jumbo': '일반형 냉장고 (냉장/냉동)',
    'Kimchi': '김치 냉장고 (3룸)',
    'Pantry': '팬트리 (선반)',
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("냉장고 추가"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "냉장고 이름",
                hintText: "예: 우리집 냉장고",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "냉장고 형태 선택",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._typeLabels.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              );
            }),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveFridge,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text("추가하기"),
            ),
          ],
        ),
      ),
    );
  }

  void _saveFridge() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("냉장고 이름을 입력해주세요.")),
      );
      return;
    }

    final newFridge = _createFridgeFromTemplate(_nameController.text, _selectedType);
    context.read<AppState>().addFridge(newFridge);
    Navigator.pop(context);
  }

  Fridge _createFridgeFromTemplate(String name, String type) {
    List<Compartment> compartments = [];
    String modelName = "";

    switch (type) {
      case 'Jumbo':
        modelName = "Standard Mixed Fridge";
        compartments = [
          Compartment(
            name: "냉장실 - 상칸",
            type: StorageType.fridge,
            slots: [Slot(name: "첫번째 칸"), Slot(name: "두번째 칸")],
          ),
          Compartment(
            name: "신선 야채실",
            type: StorageType.fridge,
            slots: [Slot(name: "야채박스")],
          ),
          Compartment(
            name: "냉동실",
            type: StorageType.freezer,
            slots: [Slot(name: "상단 서랍"), Slot(name: "하단 서랍")],
          ),
        ];
        break;
      case 'Kimchi':
        modelName = "Kimchi Refrigerator";
        compartments = [
          Compartment(
            name: "좌측 칸",
            type: StorageType.fridge,
            slots: [Slot(name: "상세 구역 1"), Slot(name: "상세 구역 2")],
          ),
          Compartment(
            name: "우측 칸",
            type: StorageType.fridge,
            slots: [Slot(name: "상세 구역 1"), Slot(name: "상세 구역 2")],
          ),
          Compartment(
            name: "하부 서랍",
            type: StorageType.fridge,
            slots: [Slot(name: "김치통 1"), Slot(name: "김치통 2")],
          ),
        ];
        break;
      case 'Pantry':
        modelName = "Pantry Shelves";
        compartments = [
          Compartment(
            name: "선반 1",
            type: StorageType.pantry,
            slots: [Slot(name: "전체")],
          ),
          Compartment(
            name: "선반 2",
            type: StorageType.pantry,
            slots: [Slot(name: "전체")],
          ),
          Compartment(
            name: "선반 3",
            type: StorageType.pantry,
            slots: [Slot(name: "전체")],
          ),
        ];
        break;
    }

    return Fridge(
      name: name,
      modelName: modelName,
      compartments: compartments,
    );
  }
}
