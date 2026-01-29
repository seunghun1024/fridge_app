import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../models/app_state.dart';

class AddItemScreen extends StatefulWidget {
  final Slot slot;

  const AddItemScreen({super.key, required this.slot});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _unitController = TextEditingController(text: '개');
  
  FoodCategory _selectedCategory = FoodCategory.other;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("식재료 추가")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "이름",
                  hintText: "예: 체다 치즈",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.abc),
                ),
                validator: (val) => val == null || val.isEmpty ? "필수 입력" : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<FoodCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "카테고리",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: FoodCategory.values.map((c) {
                  return DropdownMenuItem(value: c, child: Text(_getCategoryName(c)));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "수량",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val!.isEmpty ? "필수 입력" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: "단위",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (picked != null) setState(() => _expiryDate = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                     labelText: "유통기한",
                     border: OutlineInputBorder(),
                     prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('yyyy-MM-dd').format(_expiryDate)),
                ),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("저장하기"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryName(FoodCategory c) {
    switch (c) {
      case FoodCategory.meat: return "육류";
      case FoodCategory.veggie: return "채소";
      case FoodCategory.dairy: return "유제품";
      case FoodCategory.fruit: return "과일";
      case FoodCategory.beverage: return "음료";
      case FoodCategory.sauce: return "소스/양념";
      case FoodCategory.other: return "기타";
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final item = FoodItem(
        slotId: widget.slot.id,
        name: _nameController.text,
        category: _selectedCategory,
        quantity: double.tryParse(_qtyController.text) ?? 1,
        unit: _unitController.text,
        expiryDate: _expiryDate,
        purchaseDate: DateTime.now(),
      );
      
      context.read<AppState>().addItem(item);
      Navigator.pop(context);
    }
  }
}
