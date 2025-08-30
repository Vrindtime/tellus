import 'package:flutter/material.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/search_text_field_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';

class AddItemWidget extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const AddItemWidget({super.key, this.initialData});

  @override
  State<AddItemWidget> createState() => _AddItemWidgetState();
}

class _AddItemWidgetState extends State<AddItemWidget> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _sellPriceController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _fromLocationController = TextEditingController();
  String unit = 'Cubic Meter';
  String taxOption = 'With Tax';

  final List<String> _units = ['Cubic Meter', 'Ton', 'Kilogram', 'Litre'];
  final List<String> _taxOptions = ['With Tax (18%)', 'Without Tax'];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _itemController.text = widget.initialData!['name'] ?? '';
      _quantityController.text =
          widget.initialData!['quantity']?.toString() ?? '';
      _costPriceController.text =
          widget.initialData!['costPrice']?.toString() ?? '';
      _sellPriceController.text =
          widget.initialData!['sellPrice']?.toString() ?? '';
      unit = widget.initialData!['unit'] ?? 'Cubic Meter';
      taxOption = widget.initialData!['taxOption'] ?? 'With Tax';
      _fromLocationController.text =
          widget.initialData!['fromLocation'] ?? 'From Location';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).size.width / 360;

    return AlertDialog(
      title: const Text('Add Item'),
      content: Container(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextInput(
                label: 'Item Name',
                controller: _itemController,
                icon: Icons.shopping_cart,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Item Name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10 * scaleFactor),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomTextInput(
                      label: 'Quantity',
                      controller: _quantityController,
                      icon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Quantity is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10 * scaleFactor),
                  Expanded(
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
              SizedBox(height: 10 * scaleFactor),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomTextInput(
                      label: 'Cost Price',
                      controller: _costPriceController,
                      icon: Icons.money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Cost Price is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8 * scaleFactor),
                  Expanded(
                    child: CustomTextInput(
                      label: 'Sell Price',
                      controller: _sellPriceController,
                      icon: Icons.price_check,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Sell Price is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10 * scaleFactor),
              CustomTextInput(
                label: 'From Location',
                controller: _fromLocationController,
                icon: Icons.location_pin,
                keyboardType: TextInputType.streetAddress,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10 * scaleFactor),
              CustomDropdown(
                label: 'Tax Option',
                selectedValue: taxOption,
                items: _taxOptions,
                onChanged: (value) {
                  setState(() {
                    taxOption = value!;
                  });
                },
              ),
            ],
          ),
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
            final costPrice = double.tryParse(_costPriceController.text) ?? 0.0;
            final sellPrice = double.tryParse(_sellPriceController.text) ?? 0.0;
            String location = _fromLocationController.text.trim();
            print('ADD ITEM LOCAITON: $location');
            if (_itemController.text.isNotEmpty &&
                quantity > 0 &&
                costPrice >= 0 &&
                sellPrice >= 0) {
              Navigator.pop(context, {
                'name': _itemController.text,
                'quantity': quantity,
                'costPrice': costPrice,
                'sellPrice': sellPrice,
                'unit': unit,
                'fromLocation': location,
                'taxOption': taxOption,
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all required fields correctly'),
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
