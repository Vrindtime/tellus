import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tellus/helper/consumer_invoice.dart';
import 'package:tellus/services/accountant/party_controller.dart';
import 'package:tellus/services/accountant/payment_in_controller.dart';
import 'package:tellus/services/admin/organization_controller.dart';
import 'package:tellus/services/auth/auth_service.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';
import 'package:tellus/views/widgets/date_picker_widget.dart';
import 'package:tellus/views/widgets/extras/date_picker_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/search_text_field_widget.dart';

class PaymentInPage extends StatefulWidget {
  final PaymentInModel? paymentInModel; // Add parameter for editing
  const PaymentInPage({super.key, this.paymentInModel});

  @override
  State<PaymentInPage> createState() => _PaymentInPageState();
}

class _PaymentInPageState extends State<PaymentInPage> {
  final PartyController _partyController = PartyController();
  final AuthService authService = Get.find<AuthService>();
  final PaymentInController _paymentInController = PaymentInController();

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerNameIdController =
      TextEditingController();
  final TextEditingController _receivedAmountController =
      TextEditingController();

  String paymentType = 'Cash';
  DateTime selectedDate = DateTime.now();

  final List<String> _paymentTypes = ['Cash', 'Cheque', 'UPI', 'Bank'];
  

  @override
  void initState() {
    super.initState();
    // Pre-fill form if paymentInModel is provided
    if (widget.paymentInModel != null) {
      final model = widget.paymentInModel!;
      _customerNameController.text = model.customerName;
      _customerNameIdController.text = model.customerId;
      _receivedAmountController.text = model.receivedAmount.toString();
      paymentType = model.paymentType;
      selectedDate = DateFormat(
        'yyyy-MM-dd',
      ).parse(model.date.toIso8601String());
    }
  }

  void _clearForm() {
    _customerNameController.clear();
    _customerNameIdController.clear();
    _receivedAmountController.clear();
    setState(() {
      paymentType = 'Cash';
      selectedDate = DateTime.now();
    });
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
        actions: [
          if (widget.paymentInModel != null)
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () async {
                final confirmDelete = await showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text('Confirm Delete'),
                        content: Text(
                          'Are you sure you want to delete this payment?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                );

                if (confirmDelete == true) {
                  await _paymentInController.deletePaymentIn(
                    widget.paymentInModel!.id!,
                  );
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            CustomDatePicker(
              label: 'Date',
              initialDate: DateTime.now(),
              onDateSelected: (date) {
                selectedDate = date;
              },
            ),
            const SizedBox(height: 16),
            SearchTextField(
              label: 'Search Client Name',
              controller: _customerNameController,
              suggestionsCallback: _partyController.getPartySuggestions,
              onSuggestionSelected: (suggestion) {
                _customerNameController.text = suggestion['name']!;
                _customerNameIdController.text = suggestion['id']!;
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
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    widget.paymentInModel != null
                        ? [
                          CustomSubmitButton(
                            text: 'Update',
                            isLoading: _paymentInController.isLoading.value,
                            onTap: () async {
                              final updatedModel = PaymentInModel(
                                id: widget.paymentInModel!.id,
                                organizationId: authService.orgId.value,
                                customerId: _customerNameIdController.text,
                                customerName: _customerNameController.text,
                                receivedAmount:
                                    double.tryParse(
                                      _receivedAmountController.text,
                                    ) ??
                                    0.0,
                                paymentType: paymentType,
                                date: selectedDate,
                              );

                              await _paymentInController.updatePaymentIn(
                                updatedModel,
                                widget.paymentInModel!.id!,
                              );
                              Navigator.pop(context);
                            },
                            width: MediaQuery.of(context).size.width * 0.6,
                          ),
                        ]
                        : [
                          CustomSubmitButton(
                            text: 'Save & New',
                            isLoading: _paymentInController.isLoading.value,
                            onTap: () async {
                              final newModel = PaymentInModel(
                                organizationId: authService.orgId.value,
                                customerId: _customerNameIdController.text,
                                customerName: _customerNameController.text,
                                receivedAmount:
                                    double.tryParse(
                                      _receivedAmountController.text,
                                    ) ??
                                    0.0,
                                paymentType: paymentType,
                                date: selectedDate,
                              );

                              await _paymentInController.addPaymentIn(newModel);
                              _clearForm();
                            },
                            width: MediaQuery.of(context).size.width * 0.4,
                          ),
                          const SizedBox(width: 16),
                          CustomSubmitButton(
                            text: 'Save',
                            isLoading: _paymentInController.isLoading.value,
                            onTap: () async {
                              final newModel = PaymentInModel(
                                organizationId: authService.orgId.value,
                                customerId: _customerNameIdController.text,
                                customerName: _customerNameController.text,
                                receivedAmount:
                                    double.tryParse(
                                      _receivedAmountController.text,
                                    ) ??
                                    0.0,
                                paymentType: paymentType,
                                date: selectedDate,
                              );

                              await _paymentInController.addPaymentIn(newModel);
                              Navigator.pop(context);
                            },
                            width: MediaQuery.of(context).size.width * 0.4,
                          ),
                        ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
