import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';
import 'package:tellus/views/widgets/date_picker_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/search_text_field_widget.dart';

class PaymentInPage extends StatefulWidget {
  const PaymentInPage({super.key});

  @override
  State<PaymentInPage> createState() => _PaymentInPageState();
}

class _PaymentInPageState extends State<PaymentInPage> {
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _receivedAmountController = TextEditingController();
  String paymentType = 'Cash';

  final List<String> _paymentTypes = ['Cash', 'Cheque', 'UPI', 'Bank'];

  @override
  void initState() {
    super.initState();
    _referenceController.text =
        'PAY-${DateFormat('yyyy-MM').format(DateTime.now())}-0001';
  }

  Future<List<Map<String, String>>> _getCustomerSuggestions(String query) async {
    // Replace with actual customer name suggestions logic
    return [
      {'name': 'John Doe', 'category': 'Regular Customer'},
      {'name': 'Jane Smith', 'category': 'Premium Customer'},
      {'name': 'Alice Johnson', 'category': 'New Customer'},
    ].where((customer) => customer['name']!.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment In',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            DatePickerTextField(),
            const SizedBox(height: 16),
            SearchTextField(
              label: 'Customer Name',
              controller: _customerNameController,
              suggestionsCallback: _getCustomerSuggestions,
              onSuggestionSelected: (suggestion) {
                _customerNameController.text = suggestion['name']!;
              },
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              label: 'Payment Type',
              selectedValue: paymentType,
              items: _paymentTypes,
              onChanged: (value) {
                setState(() {
                  paymentType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomTextInput(
              label: 'Received Amount',
              controller: _receivedAmountController,
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Received amount is required';
                }
                return null;
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomSubmitButton(
                  text: 'Save & New',
                  isLoading: false,
                  onTap: () {
                    // Handle Save & New logic
                  },
                  width: width * 0.38,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                CustomSubmitButton(
                  text: 'Save',
                  isLoading: false,
                  onTap: () {
                    // Handle Save logic
                  },
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
