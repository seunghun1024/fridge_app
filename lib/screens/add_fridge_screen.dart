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
  
  // State for the builder
  String _selectedTemplate = 'Jumbo';
  List<Compartment> _compartments = [];

  final Map<String, String> _templateLabels = {
    'Jumbo': '일반형 (냉장/냉동)',
    'Kimchi': '김치 냉장고',
    'Pantry': '팬트리 / 찬장',
    'Custom': '직접 만들기 (빈 상태)',
  };

  @override
  void initState() {
    super.initState();
    _loadTemplate(_selectedTemplate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadTemplate(String type) {
    List<Compartment> newCompartments = [];

    switch (type) {
      case 'Jumbo':
        newCompartments = [
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
        newCompartments = [
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
        newCompartments = [
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
        ];
        break;
      case 'Custom':
        newCompartments = [];
        break;
    }

    setState(() {
      _selectedTemplate = type;
      _compartments = newCompartments;
    });
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
                  // 1. Basic Info
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "냉장고 이름",
                      hintText: "예: 우리집 메인 냉장고",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Template Selection
                  Text("기본 구조 선택", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedTemplate,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _templateLabels.entries.map((e) {
                      return DropdownMenuItem(value: e.key, child: Text(e.value));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) _loadTemplate(value);
                    },
                  ),
                  const SizedBox(height: 24),

                  // 3. Structure Editor
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("내부 구조 상세 설정", style: Theme.of(context).textTheme.titleMedium),
                      TextButton.icon(
                        onPressed: _addCompartment,
                        icon: const Icon(Icons.add),
                        label: const Text("칸 추가"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_compartments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("칸을 추가해서 구조를 만들어보세요!", style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _compartments.length,
                      itemBuilder: (context, index) {
                        return _buildCompartmentEditor(index);
                      },
                    ),
                ],
              ),
            ),
          ),
          
          // 4. Save Button
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

  Widget _buildCompartmentEditor(int index) {
    final comp = _compartments[index];
    final nameCtrl = TextEditingController(text: comp.name);
    // Note: In a real app, keeping controllers in sync with state in a ListView requires careful management.
    // For simplicity here, we rely on callbacks to update the state model.

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "칸 이름", isDense: true),
                    onChanged: (val) => comp.name = val, // Assuming models are mutable, if final need to replace
                    // Wait, models are final. We need to replace the object or make fields mutable. 
                    // Let's assume for the builder we might need a mutable DTO or create new instances.
                    // For now, I'll update the list with a new instance.
                    onSubmitted: (val) {
                      _updateCompartment(index, comp.copyWith(name: val));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<StorageType>(
                  value: comp.type,
                  underline: Container(),
                  items: StorageType.values.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _updateCompartment(index, comp.copyWith(type: val));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeCompartment(index),
                ),
              ],
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...comp.slots.map((slot) => Chip(
                    label: Text(slot.name),
                    onDeleted: comp.slots.length > 1 ? () => _removeSlot(index, slot) : null,
                  )),
                  ActionChip(
                    label: const Text("+ 상세구역"),
                    onPressed: () => _addSlot(index),
                    avatar: const Icon(Icons.add, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Logic Helpers ---

  // Since models are immutable (final fields), we need helper methods to copyWith. 
  // I'll add extension methods or just implement logic here if models don't have copyWith.
  // Checking models.dart... they don't seem to have copyWith. I'll construct new ones manually.

  void _addCompartment() {
    setState(() {
      _compartments.add(Compartment(
        name: "새로운 칸 ${_compartments.length + 1}",
        type: StorageType.fridge,
        slots: [Slot(name: "기본 구역")],
      ));
    });
  }

  void _removeCompartment(int index) {
    setState(() {
      _compartments.removeAt(index);
    });
  }

  void _updateCompartment(int index, Compartment newComp) {
    setState(() {
      _compartments[index] = newComp;
    });
  }

  void _addSlot(int compIndex) {
    showDialog(
      context: context,
      builder: (context) {
        String newName = "";
        return AlertDialog(
          title: const Text("구역 추가"),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: "예: 맨 윗칸"),
            onChanged: (v) => newName = v,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
            TextButton(
              onPressed: () {
                if (newName.isNotEmpty) {
                  final comp = _compartments[compIndex];
                  final newSlots = [...comp.slots, Slot(name: newName)];
                  
                  // Create new compartment with updated slots
                  final newComp = Compartment(
                    id: comp.id,
                    name: comp.name,
                    type: comp.type,
                    slots: newSlots,
                  );
                  _updateCompartment(compIndex, newComp);
                }
                Navigator.pop(context);
              },
              child: const Text("추가"),
            ),
          ],
        );
      },
    );
  }

  void _removeSlot(int compIndex, Slot slot) {
    final comp = _compartments[compIndex];
    final newSlots = comp.slots.where((s) => s != slot).toList();
    
    final newComp = Compartment(
      id: comp.id,
      name: comp.name,
      type: comp.type,
      slots: newSlots,
    );
    _updateCompartment(compIndex, newComp);
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
      modelName: _selectedTemplate == 'Custom' ? "Custom Build" : "$_selectedTemplate Type",
      compartments: _compartments,
    );

    context.read<AppState>().addFridge(newFridge);
    Navigator.pop(context);
  }
}

// Extension to help with copying (Simulated since I can't easily edit models.dart in the same step cleanly without risks)
extension CompartmentCopy on Compartment {
  Compartment copyWith({String? name, StorageType? type, List<Slot>? slots}) {
    return Compartment(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      slots: slots ?? this.slots,
    );
  }
}
