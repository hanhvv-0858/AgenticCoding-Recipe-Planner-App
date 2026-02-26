import 'package:flutter/material.dart';

/// Dialog for manually adding a grocery item.
class AddGroceryItemDialog extends StatefulWidget {
  final void Function(
      String name, double quantity, String unit, String category) onAdd;

  const AddGroceryItemDialog({super.key, required this.onAdd});

  @override
  State<AddGroceryItemDialog> createState() => _AddGroceryItemDialogState();
}

class _AddGroceryItemDialogState extends State<AddGroceryItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitController = TextEditingController(text: 'piece');
  String _selectedCategory = 'Other';

  static const _categories = [
    'Vegetables',
    'Fruits',
    'Meat/Fish',
    'Dairy',
    'Spices',
    'Grains',
    'Canned',
    'Frozen',
    'Beverages',
    'Other',
  ];

  static const _commonUnits = [
    'piece',
    'kg',
    'g',
    'lb',
    'oz',
    'liter',
    'ml',
    'cup',
    'tablespoon',
    'teaspoon',
    'bunch',
    'can',
    'package',
    'bottle',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Grocery Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g. Chicken breast',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an item name';
                  }
                  if (value.trim().length > 100) {
                    return 'Name must be 100 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quantity and Unit row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quantity
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Qty',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final qty = double.tryParse(value.trim());
                        if (qty == null || qty <= 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Unit dropdown
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _commonUnits.contains(_unitController.text)
                          ? _unitController.text
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                      ),
                      items: _commonUnits
                          .map((u) => DropdownMenuItem(
                                value: u,
                                child: Text(u),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _unitController.text = value;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    final name = _nameController.text.trim();
    final quantity = double.parse(_quantityController.text.trim());
    final unit = _unitController.text.trim();

    widget.onAdd(name, quantity, unit, _selectedCategory);
    Navigator.of(context).pop();
  }
}
