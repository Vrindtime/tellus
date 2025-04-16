import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/views/screens/accountant/add_party_details_page.dart';
import 'package:tellus/views/widgets/add_item_widget.dart';
import 'package:intl/intl.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';
import 'package:tellus/views/widgets/date_picker_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/search_text_field_widget.dart';

class SalesInvoicePage extends StatefulWidget {
  const SalesInvoicePage({super.key});

  @override
  State<SalesInvoicePage> createState() => _SalesInvoicePageState();
}

class _SalesInvoicePageState extends State<SalesInvoicePage> {
  
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();

  double totalAmount = 0.0;
  String discountType = '%';
  List<Map<String, dynamic>> _addedItems = [
    // Initial added items
    {
      'name': 'Item 1',
      'quantity': 1,
      'rate': 100.0,
    },
    {
      'name': 'Item 2',
      'quantity': 2,
      'rate': 200.0,
    },
  ]; // Store added items
  final List<Map<String, dynamic>> _tableHeader = [
    {'title': 'Name', 'key': 'name'},
    {'title': 'Quantity', 'key': 'quantity'},
    {'title': 'Rate', 'key': 'rate'},
    {'title': 'Amount', 'key': 'amount'},
    {'title': 'Actions', 'key': 'actions', 'editable': false}, // Corrected type
  ];

  @override
  void initState() {
    super.initState();
    _referenceController.text =
        'INV-${DateFormat('yyyy-MM').format(DateTime.now())}-0001';
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _calculateTotalAmount();
  }

  void _calculateTotalAmount() {
    totalAmount = _addedItems.fold(0, (sum, item) {
      return sum + (item['quantity'] * item['rate']);
    });
  }

  Future<List<Map<String, String>>> _getCustomerSuggestions(
      String query,
      ) async {
    // Replace with actual customer name suggestions logic
    return [
      {'name': 'John Doe', 'category': 'Regular Customer'},
      {'name': 'Jane Smith', 'category': 'Premium Customer'},
      {'name': 'Alice Johnson', 'category': 'New Customer'},
    ]
        .where(
          (customer) =>
          customer['name']!.toLowerCase().contains(query.toLowerCase()),
    )
        .toList();
  }

  Future<List<Map<String, String>>> _getPhoneSuggestions(String query) async {
    // Replace with actual customer phone number suggestions logic
    return [
      {'name': '1234567890', 'category': 'John Doe'},
      {'name': '9876543210', 'category': 'Jane Smith'},
      {'name': '5555555555', 'category': 'Alice Johnson'},
    ].where((phone) => phone['name']!.contains(query)).toList();
  }

  void _addItem() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const AddItemWidget(),
    );
    if (result != null) {
      setState(() {
        _addedItems.add(result); // Add to the list
        _calculateTotalAmount();
      });
    }
  }

  void _editItem(int index) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddItemWidget(
        initialData: _addedItems[index],
      ),
    );
    if (result != null) {
      setState(() {
        _addedItems[index] = result;
        _calculateTotalAmount();
      });
    }
  }

  void _deleteItem(int index) {
    setState(() {
      _addedItems.removeAt(index);
      _calculateTotalAmount();
    });
  }

  List<Map<String, dynamic>> _generateTableRows() {
    return _addedItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final amount = item['quantity'] * item['rate'];
      return {
        'name': item['name'],
        'quantity': item['quantity'].toString(),
        'rate': item['rate'].toString(),
        'amount': amount.toStringAsFixed(2),
        'actions': _buildActionButtons(index),
      };
    }).toList();
  }

  Widget _buildActionButtons(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => _editItem(index),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteItem(index),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invoice',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Reduced padding
        child: Column(
          children: [
            Expanded( // Use Expanded to constrain the height of the scrollable content
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8), // Reduced spacing
                    CustomTextInput(
                      label: 'Reference Number',
                      controller: _referenceController,
                      icon: Icons.numbers,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Reference number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8), // Reduced spacing
                    DatePickerTextField(),
                    const SizedBox(height: 8), // Reduced spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SearchTextField(
                            label: 'Customer Name',
                            controller: _customerNameController,
                            suggestionsCallback: _getCustomerSuggestions,
                            onSuggestionSelected: (suggestion) {
                              _customerNameController.text = suggestion['name']!;
                            },
                          ),
                        ),
                        const SizedBox(width: 8), // Reduced spacing
                        CustomSubmitButton(
                          text: '+',
                          isLoading: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: AddPartyDetailsPage(),
                              ),
                            );
                          },
                          width: width * 0.15, // Adjusted width
                          height: height * 0.066, // Adjusted height
                          padding: 0,
                        ),
                      ],
                    ),
                    if (_addedItems.isNotEmpty) ...[
                      const SizedBox(height: 8), // Reduced spacing
                      SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columnSpacing: 12.0, // Reduced column spacing
                          headingRowHeight: 28, // Reduced header row height
                          dataRowHeight: 28, // Reduced data row height
                          columns: const [
                            DataColumn(
                              label: Center(child: Text('Name', style: TextStyle(fontSize: 16))), // Center-aligned header
                            ),
                            DataColumn(
                              label: Center(child: Text('Qtn', style: TextStyle(fontSize: 16))), // Center-aligned header
                              numeric: true,
                            ),
                            DataColumn(
                              label: Center(child: Text('Rate', style: TextStyle(fontSize: 16))), // Center-aligned header
                              numeric: true,
                            ),
                            DataColumn(
                              label: Center(child: Text('Amount', style: TextStyle(fontSize: 16))), // Center-aligned header
                              numeric: true,
                            ),
                            DataColumn(
                              label: Center(child: Text('Actions', style: TextStyle(fontSize: 16))), // Center-aligned header
                            ),
                          ],
                          rows: _addedItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final amount = item['quantity'] * item['rate']; // Calculate amount
                        
                            return DataRow(
                              cells: [
                                DataCell(
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(item['name'], style: const TextStyle(fontSize: 12)), // Scrollable Name column
                                  ),
                                ),
                                DataCell(
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(item['quantity'].toString(), style: const TextStyle(fontSize: 12)),
                                  ),
                                ),
                                DataCell(
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(item['rate'].toString(), style: const TextStyle(fontSize: 12)),
                                  ),
                                ),
                                DataCell(
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(amount.toStringAsFixed(2), style: const TextStyle(fontSize: 12)), // Scrollable Amount column
                                  ),
                                ),
                                DataCell(
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue, size: 16), // Smaller icon
                                          onPressed: () => _editItem(index),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red, size: 16), // Smaller icon
                                          onPressed: () => _deleteItem(index),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8), // Reduced spacing
                    CustomSubmitButton(
                      text: 'Add Item',
                      isLoading: false,
                      onTap: _addItem,
                      width: width * 0.3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8), // Reduced spacing
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6, // Adjusted width
                  child: CustomTextInput(
                    label: 'Discount',
                    controller: _discountController,
                    icon: Icons.percent,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Discount is required';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  width: width * 0.2,
                  height: height * 0.06, // Adjusted height
                  child: CustomDropdown(
                    label: 'Discount Type',
                    selectedValue: discountType,
                    items: const ['%', 'Rs'],
                    onChanged: (value) {
                      setState(() {
                        discountType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Reduced spacing
            Text('Total Amount: Rs ${totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 8), // Reduced spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomSubmitButton(
                  text: 'Save & New',
                  isLoading: false,
                  onTap: () {},
                  width: width * 0.35, // Adjusted width
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                CustomSubmitButton(
                  text: 'Save',
                  isLoading: false,
                  onTap: () {},
                  width: width * 0.2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

