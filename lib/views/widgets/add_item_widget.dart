import 'package:flutter/material.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/search_text_field_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';

class AddItemWidget extends StatefulWidget {
  final Map<String, dynamic>? initialData; // Add optional initialData parameter

  const AddItemWidget({super.key, this.initialData});

  @override
  State<AddItemWidget> createState() => _AddItemWidgetState();
}

class _AddItemWidgetState extends State<AddItemWidget> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  String unit = 'Cubic Meter';
  String taxOption = 'With Tax';

  final List<String> _units = ['Cubic Meter', 'Ton', 'Kilogram'];
  final List<String> _taxOptions = ['With Tax', 'Without Tax'];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      // Pre-fill fields with initial data
      _itemController.text = widget.initialData!['name'] ?? '';
      _quantityController.text = widget.initialData!['quantity']?.toString() ?? '';
      _rateController.text = widget.initialData!['rate']?.toString() ?? '';
      unit = widget.initialData!['unit'] ?? 'Cubic Meter';
      taxOption = widget.initialData!['taxOption'] ?? 'With Tax';
    }
  }

  Future<List<Map<String, String>>> _getItemSuggestions(String query) async {
    final materials = [
      {'name': 'Sand', 'category': 'Raw Material'},
      {'name': 'Gravel', 'category': 'Raw Material'},
      {'name': 'Clay', 'category': 'Soil'},
      {'name': 'Topsoil', 'category': 'Soil'},
    ];
    return materials
        .where((material) =>
            material['name']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SearchTextField(
              label: 'Item Name',
              controller: _itemController,
              suggestionsCallback: _getItemSuggestions,
              onSuggestionSelected: (suggestion) {
                _itemController.text = suggestion['name']!;
              },
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.32,
                  child: CustomTextInput(
                    label: 'Quantity',
                    controller: _quantityController,
                    icon: Icons.percent,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Quantity is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: CustomDropdown(
                    label: 'Unit',
                    selectedValue: unit,
                    items: _units,
                    onChanged: (value) {
                      setState(() {
                        unit = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: CustomTextInput(
                    label: 'Rate',
                    controller: _rateController,
                    icon: Icons.percent,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Rate is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: CustomDropdown(
                    label: 'Tax Option',
                    selectedValue: taxOption,
                    items: _taxOptions,
                    onChanged: (value) {
                      setState(() {
                        taxOption = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final quantity = double.tryParse(_quantityController.text) ?? 0.0;
            final rate = double.tryParse(_rateController.text) ?? 0.0;
            if (_itemController.text.isNotEmpty) {
              Navigator.pop(context, {
                'name': _itemController.text,
                'quantity': quantity,
                'rate': rate,
                'unit': unit, // Include the unit
                'taxOption': taxOption, // Include the tax option
              });
            } else {
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

