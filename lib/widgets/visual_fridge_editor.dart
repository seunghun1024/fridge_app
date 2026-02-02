import 'package:flutter/material.dart';
import '../models/models.dart';

enum FridgeStructure {
  pantry,   // BodyLeft only (Wide)
  oneDoor,  // DoorLeft + BodyLeft
  twoDoor,  // BodyLeft + BodyRight
  fourDoor, // DoorLeft + BodyLeft + BodyRight + DoorRight
}

class VisualFridgeEditor extends StatefulWidget {
  final List<Compartment> compartments;
  final Function(List<Compartment>) onUpdate;

  const VisualFridgeEditor({
    super.key,
    required this.compartments,
    required this.onUpdate,
  });

  @override
  State<VisualFridgeEditor> createState() => _VisualFridgeEditorState();
}

class _VisualFridgeEditorState extends State<VisualFridgeEditor> {
  int? _selectedCompIndex;
  FridgeStructure _structure = FridgeStructure.fourDoor; // Default
  
  // Cache for independent layouts
  final Map<FridgeStructure, List<Compartment>> _cachedLayouts = {};

  @override
  void initState() {
    super.initState();
    _inferStructure();
    // Cache the initial state
    _cachedLayouts[_structure] = widget.compartments;
  }

  void _inferStructure() {
    // Basic inference based on existing compartments
    final hasDoorLeft = widget.compartments.any((c) => _mapLocation(c.location) == CompartmentLocation.doorLeft);
    final hasDoorRight = widget.compartments.any((c) => _mapLocation(c.location) == CompartmentLocation.doorRight);
    final hasBodyRight = widget.compartments.any((c) => _mapLocation(c.location) == CompartmentLocation.bodyRight);

    // Only infer if we don't have a user-selected structure history yet 
    // (In this case, it's just init, so simple inference is fine)
    if (hasDoorLeft && hasDoorRight && hasBodyRight) {
      _structure = FridgeStructure.fourDoor;
    } else if (!hasDoorLeft && !hasDoorRight && hasBodyRight) {
      _structure = FridgeStructure.twoDoor;
    } else if (hasDoorLeft && !hasBodyRight) {
      _structure = FridgeStructure.oneDoor;
    } else if (!hasDoorLeft && !hasBodyRight && !hasDoorRight) {
      _structure = FridgeStructure.pantry;
    } else {
      _structure = FridgeStructure.fourDoor; // Fallback
    }
  }

  List<Compartment> _generateTemplate(FridgeStructure type) {
    switch (type) {
      case FridgeStructure.pantry:
        return [
          Compartment(name: "상단 선반", type: StorageType.pantry, location: CompartmentLocation.bodyLeft, slots: [Slot(name: "전체")]),
          Compartment(name: "중단 선반", type: StorageType.pantry, location: CompartmentLocation.bodyLeft, slots: [Slot(name: "전체")]),
          Compartment(name: "하단 서랍", type: StorageType.pantry, location: CompartmentLocation.bodyLeft, slots: [Slot(name: "잡곡/건어물")]),
        ];
      case FridgeStructure.oneDoor:
        return [
          Compartment(name: "상단 포켓", type: StorageType.fridge, location: CompartmentLocation.doorLeft, slots: [Slot(name: "음료")]),
          Compartment(name: "하단 포켓", type: StorageType.fridge, location: CompartmentLocation.doorLeft, slots: [Slot(name: "물")]),
          Compartment(name: "냉장실", type: StorageType.fridge, location: CompartmentLocation.bodyLeft, slots: [Slot(name: "신선식품")]),
          Compartment(name: "냉동칸", type: StorageType.freezer, location: CompartmentLocation.bodyLeft, slots: [Slot(name: "얼음")]),
        ];
      case FridgeStructure.twoDoor:
        return [
          Compartment(name: "좌측 냉장", type: StorageType.fridge, location: CompartmentLocation.bodyLeft, slots: [Slot(name: "김치")]),
          Compartment(name: "우측 냉장", type: StorageType.fridge, location: CompartmentLocation.bodyRight, slots: [Slot(name: "반찬")]),
          Compartment(name: "하단 서랍", type: StorageType.fridge, location: CompartmentLocation.bodyLeft, slots: [Slot(name: "야채")]),
        ];
      case FridgeStructure.fourDoor:
        return [
          // Left Door
          Compartment(name: "상단 포켓", type: StorageType.fridge, location: CompartmentLocation.doorLeft, slots: [Slot(name: "소스")]),
          Compartment(name: "하단 포켓", type: StorageType.fridge, location: CompartmentLocation.doorLeft, slots: [Slot(name: "물")]),
          // Left Body
          Compartment(name: "냉장실", type: StorageType.fridge, location: CompartmentLocation.bodyLeft, slots: [Slot(name: "반찬")]),
          Compartment(name: "야채실", type: StorageType.fridge, location: CompartmentLocation.bodyLeft, slots: [Slot(name: "야채")]),
          // Right Body
          Compartment(name: "냉동실", type: StorageType.freezer, location: CompartmentLocation.bodyRight, slots: [Slot(name: "냉동식품")]),
          // Right Door
          Compartment(name: "도어 포켓", type: StorageType.freezer, location: CompartmentLocation.doorRight, slots: [Slot(name: "아이스")]),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Structure Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SegmentedButton<FridgeStructure>(
              segments: const [
                ButtonSegment(value: FridgeStructure.pantry, label: Text('서랍/팬트리')),
                ButtonSegment(value: FridgeStructure.oneDoor, label: Text('1도어')),
                ButtonSegment(value: FridgeStructure.twoDoor, label: Text('2도어(좌우)')),
                ButtonSegment(value: FridgeStructure.fourDoor, label: Text('4도어')),
              ],
              selected: {_structure},
              onSelectionChanged: (Set<FridgeStructure> newSelection) {
                final newStruct = newSelection.first;
                if (newStruct == _structure) return;

                // 1. Save current state to cache
                _cachedLayouts[_structure] = widget.compartments;

                // 2. Load next state from cache or generate default
                List<Compartment> nextCompartments = _cachedLayouts[newStruct] ?? [];
                if (nextCompartments.isEmpty) {
                   nextCompartments = _generateTemplate(newStruct);
                   _cachedLayouts[newStruct] = nextCompartments;
                }
                
                // 3. Update parent and local state
                widget.onUpdate(nextCompartments);
                
                setState(() {
                  _structure = newStruct;
                  _selectedCompIndex = null; // Clear selection
                });
              },
            ),
          ),
        ),

        // Fridge Visualizer
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 400),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[400]!, width: 4),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildStructureColumns(),
          ),
        ),
        
        // Toolbar (Contextual Actions)
        const SizedBox(height: 16),
        if (_selectedCompIndex != null) _buildToolbar(),
        
        // Help Text
        if (_selectedCompIndex == null)
           const Padding(
             padding: EdgeInsets.all(8.0),
             child: Text(
               "위의 버튼으로 냉장고 형태를 변경하고,\n+ 버튼을 눌러 각 구역에 칸을 추가하세요.",
               style: TextStyle(color: Colors.grey, fontSize: 12),
               textAlign: TextAlign.center,
             ),
           ),
      ],
    );
  }

  List<Widget> _buildStructureColumns() {
    // Common Spacers
    const spacer = SizedBox(width: 4);
    const divider = SizedBox(width: 2);

    switch (_structure) {
      case FridgeStructure.pantry:
        return [
          Expanded(flex: 1, child: _buildColumn(CompartmentLocation.bodyLeft)),
        ];
      case FridgeStructure.oneDoor:
        return [
          Expanded(flex: 1, child: _buildColumn(CompartmentLocation.doorLeft)),
          spacer,
          Expanded(flex: 2, child: _buildColumn(CompartmentLocation.bodyLeft)),
        ];
      case FridgeStructure.twoDoor:
        return [
          Expanded(flex: 1, child: _buildColumn(CompartmentLocation.bodyLeft)),
          divider,
          Expanded(flex: 1, child: _buildColumn(CompartmentLocation.bodyRight)),
        ];
      case FridgeStructure.fourDoor:
        return [
          Expanded(flex: 1, child: _buildColumn(CompartmentLocation.doorLeft)),
          spacer,
          Expanded(flex: 2, child: _buildColumn(CompartmentLocation.bodyLeft)),
          divider,
          Expanded(flex: 2, child: _buildColumn(CompartmentLocation.bodyRight)),
          spacer,
          Expanded(flex: 1, child: _buildColumn(CompartmentLocation.doorRight)),
        ];
    }
  }

  List<CompartmentLocation> get _validLocations {
    switch (_structure) {
      case FridgeStructure.pantry:
        return [CompartmentLocation.bodyLeft];
      case FridgeStructure.oneDoor:
        return [CompartmentLocation.doorLeft, CompartmentLocation.bodyLeft];
      case FridgeStructure.twoDoor:
        return [CompartmentLocation.bodyLeft, CompartmentLocation.bodyRight];
      case FridgeStructure.fourDoor:
        return [
          CompartmentLocation.doorLeft, 
          CompartmentLocation.bodyLeft, 
          CompartmentLocation.bodyRight, 
          CompartmentLocation.doorRight
        ];
    }
  }

  Widget _buildColumn(CompartmentLocation loc) {
    final comps = widget.compartments
        .asMap()
        .entries
        .where((e) => _mapLocation(e.value.location) == loc)
        .toList();
    
    return Column(
      children: [
        // Column Header
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _getLocationLabel(loc),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        
        // Compartments
        ...comps.map((entry) {
          final index = entry.key;
          final comp = entry.value;
          return _buildCompartment(index, comp);
        }),

        // Add Button for this column
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blue),
            onPressed: () => _addCompartment(loc),
            tooltip: "이 열에 칸 추가",
          ),
        ),
      ],
    );
  }

  CompartmentLocation _mapLocation(CompartmentLocation loc) {
    if (loc == CompartmentLocation.body) return CompartmentLocation.bodyLeft;
    return loc;
  }
  
  String _getLocationLabel(CompartmentLocation loc) {
    if (_structure == FridgeStructure.pantry) {
       if (loc == CompartmentLocation.bodyLeft) return "본체 (전체)";
    } else if (_structure == FridgeStructure.oneDoor) {
       if (loc == CompartmentLocation.doorLeft) return "도어";
       if (loc == CompartmentLocation.bodyLeft) return "본체";
    } else if (_structure == FridgeStructure.twoDoor) {
       if (loc == CompartmentLocation.bodyLeft) return "좌측 본체";
       if (loc == CompartmentLocation.bodyRight) return "우측 본체";
    }
    
    // Default / Four Door
    switch (loc) {
      case CompartmentLocation.doorLeft: return "좌측 도어";
      case CompartmentLocation.bodyLeft: return "좌측 본체";
      case CompartmentLocation.bodyRight: return "우측 본체";
      case CompartmentLocation.doorRight: return "우측 도어";
      default: return "";
    }
  }

  Widget _buildCompartment(int index, Compartment comp) {
    final isSelected = _selectedCompIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCompIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: _getColorByType(comp.type),
          border: isSelected ? Border.all(color: Colors.blueAccent, width: 3) : Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8)] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(
               comp.name,
               style: TextStyle(
                 fontSize: 10,
                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                 color: _getTextColorByType(comp.type),
               ),
               maxLines: 1, 
               overflow: TextOverflow.ellipsis,
             ),
             if (comp.slots.isNotEmpty)
               Text(
                 "${comp.slots.length}구역",
                 style: const TextStyle(fontSize: 8, color: Colors.grey),
               )
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    final comp = widget.compartments[_selectedCompIndex!];
    
    return Card(
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text("선택: ${comp.name}", style: const TextStyle(fontWeight: FontWeight.bold))),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedCompIndex = null),
                ),
              ],
            ),
            const Divider(),
            // Basic Actions
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                   label: const Text("이름 변경"),
                   onPressed: _renameCompartment,
                ),
                ActionChip(
                   label: const Text("상세 구역"), // Renamed from "칸 나누기"
                   tooltip: "칸 내부를 더 작게 나눕니다",
                   onPressed: _manageSlots, 
                ),
                 ActionChip(
                  label: const Text("삭제", style: TextStyle(color: Colors.red)),
                  onPressed: _removeCompartment,
                ),
              ],
            ),
             const SizedBox(height: 8),
             // Properties
             SingleChildScrollView(
               scrollDirection: Axis.horizontal,
               child: Row(
                 children: [
                   const Text("종류: "),
                   DropdownButton<StorageType>(
                      value: comp.type,
                      items: StorageType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                      onChanged: (val) {
                        if(val != null) _updateCompartment(comp.copyWith(type: val));
                      },
                   ),
                   const SizedBox(width: 16),
                   const Text("위치: "),
                   DropdownButton<CompartmentLocation>(
                      value: comp.location == CompartmentLocation.body ? CompartmentLocation.bodyLeft : comp.location,
                      items: _validLocations.map((t) => DropdownMenuItem(value: t, child: Text(_getLocationLabel(t)))).toList(),
                      onChanged: (val) {
                        if(val != null) _updateCompartment(comp.copyWith(location: val));
                      },
                   ),
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }

  // --- Logic ---

  Color _getColorByType(StorageType type) {
    switch (type) {
      case StorageType.fridge: return Colors.lightBlue[100]!;
      case StorageType.freezer: return Colors.blueGrey[100]!;
      case StorageType.pantry: return Colors.orange[100]!;
      default: return Colors.grey[300]!;
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

  void _addCompartment(CompartmentLocation loc) {
    final newList = List<Compartment>.from(widget.compartments);
    newList.add(Compartment(
      name: "새 칸",
      type: StorageType.fridge,
      location: loc,
      slots: [Slot(name: "기본")],
    ));
    widget.onUpdate(newList);
  }

  void _removeCompartment() {
    if (_selectedCompIndex == null) return;
    final newList = List<Compartment>.from(widget.compartments);
    newList.removeAt(_selectedCompIndex!);
    widget.onUpdate(newList);
    setState(() => _selectedCompIndex = null);
  }

  void _updateCompartment(Compartment newComp) {
    if (_selectedCompIndex == null) return;
    final newList = List<Compartment>.from(widget.compartments);
    newList[_selectedCompIndex!] = newComp;
    widget.onUpdate(newList);
  }

  void _renameCompartment() {
    if (_selectedCompIndex == null) return;
    final comp = widget.compartments[_selectedCompIndex!];
    
    showDialog(context: context, builder: (context) {
       String name = comp.name;
       return AlertDialog(
         title: const Text("이름 변경"),
         content: TextField(
           controller: TextEditingController(text: name),
           onChanged: (v) => name = v,
           autofocus: true,
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
           TextButton(onPressed: () {
             _updateCompartment(comp.copyWith(name: name));
             Navigator.pop(context);
           }, child: const Text("확인")),
         ],
       );
    });
  }

  void _manageSlots() {
     if (_selectedCompIndex == null) return;
     final comp = widget.compartments[_selectedCompIndex!];
     
     showDialog(context: context, builder: (context) {
       return StatefulBuilder(
         builder: (context, setDialogState) {
           return AlertDialog(
             title: const Text("구역 관리"),
             content: SingleChildScrollView(
               child: Wrap(
                 spacing: 8,
                 children: [
                   ...comp.slots.asMap().entries.map((e) => Chip(
                     label: Text(e.value.name.isEmpty ? "구역 ${e.key+1}" : e.value.name),
                     onDeleted: comp.slots.length > 1 ? () {
                        final newSlots = List<Slot>.from(comp.slots);
                        newSlots.removeAt(e.key);
                        _updateCompartment(comp.copyWith(slots: newSlots));
                        setDialogState((){}); 
                     } : null,
                   )),
                   ActionChip(
                     avatar: const Icon(Icons.add),
                     label: const Text("추가"),
                     onPressed: () {
                       final newSlots = List<Slot>.from(comp.slots);
                       newSlots.add(Slot(name: "구역 ${newSlots.length + 1}"));
                       _updateCompartment(comp.copyWith(slots: newSlots));
                       setDialogState((){});
                     },
                   )
                 ],
               ),
             ),
             actions: [
               TextButton(onPressed: () => Navigator.pop(context), child: const Text("닫기")),
             ],
           );
         }
       );
     });
  }
}

extension CompartmentCopy on Compartment {
  Compartment copyWith({String? name, StorageType? type, CompartmentLocation? location, List<Slot>? slots}) {
    return Compartment(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      slots: slots ?? this.slots,
    );
  }
}
