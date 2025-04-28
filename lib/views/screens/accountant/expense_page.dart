import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/helper/helper.dart';
import 'package:tellus/services/accountant/expense_controller.dart';
import 'package:tellus/services/auth/auth_service.dart';
import 'package:tellus/services/vehicle/vehicle_controller.dart';
import 'package:tellus/views/screens/admin/vehicle_managment_page.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/extras/date_picker_widget.dart';
import 'package:tellus/views/widgets/search_text_field_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:image_picker/image_picker.dart';

// Expense Page
class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key, this.expense});
  final ExpenseModel? expense;

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final VehicleController _vehicleController = Get.put(VehicleController());
  final ExpenseController _expenseController = Get.put(ExpenseController());
  final AuthService _authService = Get.find<AuthService>();

  final TextEditingController _expenseDateController = TextEditingController();
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _vehicleIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _attachedImageUrl;

  final List<String> _categories = [
    'Fuel',
    'Maintenance',
    'Fine',
    'Service',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _expenseDateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.expense!.date);
      _vehicleNameController.text = widget.expense!.vehicleName;
      _vehicleIdController.text = widget.expense!.vehicleId;
      _amountController.text = widget.expense!.amount.toString();
      _descriptionController.text = widget.expense!.description ?? '';
      _selectedDate = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
    } else {
      _expenseDateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now());
    }
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final url = await saveImageAndGetUrl(
        file: XFile(image.path),
        bucketId: CId.expenseBucketId,
      );
      setState(() {
        _attachedImageUrl = url;
      });

    }
  }

  void _removeImage() {
    setState(() {
      _attachedImageUrl = null;
    });
  }

  void _clearForm() {
    _expenseDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());
    _vehicleNameController.clear();
    _vehicleIdController.clear();
    _amountController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedCategory = null;
      _attachedImageUrl = null;
    });
  }

  Future<void> _saveExpense({required bool saveAndNew}) async {
    if (_vehicleIdController.text.isEmpty ||
        _selectedCategory == null ||
        _amountController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      Get.snackbar('Error', 'Please enter a valid amount');
      return;
    }

    final expense = ExpenseModel(
      organizationId: _authService.orgId.value,
      vehicleId: _vehicleIdController.text,
      vehicleName: _vehicleNameController.text,
      category: _selectedCategory!,
      amount: amount,
      description:
          _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
      date: _selectedDate,
      billImagePath: widget.expense?.billImagePath,
    );

    try {
      if (widget.expense != null) {
        await _expenseController.updateExpense(
          expense,
          _attachedImageUrl,
          widget.expense!.id!,
        );
      } else {
        await _expenseController.addExpense(expense, _attachedImageUrl);
      }
      if (saveAndNew) {
        _clearForm();
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      // Error handling is managed in the controller
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expense != null ? 'Update Expense' : 'Add Expense',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
        actions: [
          if (widget.expense != null)
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed:
                  () => _expenseController.deleteExpense(
                    widget.expense!.id!,
                    widget.expense!.billImagePath,
                  ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              CustomDatePicker(
                label: "Expense Date",
                initialDate: _selectedDate,
                onDateSelected: (selectedDate) {
                  setState(() {
                    _selectedDate = selectedDate;
                    _expenseDateController.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(selectedDate);
                  });
                },
                validator: (value) {
                  if (value == null) {
                    debugPrint('no date');
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SearchTextField(
                      label: 'Vehicle Name',
                      controller: _vehicleNameController,
                      suggestionsCallback:
                          _vehicleController.getVehicleSuggestions,
                      onSuggestionSelected: (suggestion) {
                        _vehicleNameController.text = suggestion['name']!;
                        _vehicleIdController.text = suggestion['id']!;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomSubmitButton(
                    text: '+',
                    isLoading: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: VehicleManagementPage(),
                        ),
                      );
                    },
                    width: width * 0.15,
                    height: height * 0.066,
                    padding: 0,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomDropdown(
                label: 'Category',
                selectedValue: _selectedCategory,
                items: _categories,
                onChanged: (onChanged) {
                  setState(() {
                    _selectedCategory = onChanged;
                  });
                },
              ),
              const SizedBox(height: 12),
              CustomTextInput(
                icon: Icons.monetization_on,
                controller: _amountController,
                label: 'Expense Amount',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextInput(
                controller: _descriptionController,
                label: 'Description (Optional)',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: height * 0.3,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child:
                      _attachedImageUrl != null
                          ? Stack(
                            children: [
                              Image.network(
                                _attachedImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: _removeImage,
                                ),
                              ),
                            ],
                          )
                          : widget.expense?.billImagePath != null
                          ? Stack(
                            children: [
                              //TODO make this work
                              Image.network(
                                widget.expense!.billImagePath!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder:
                                    (context, error, stackTrace) => Center(
                                      child: Text(
                                        'Failed to load image: $error',
                                      ),
                                    ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: _removeImage,
                                ),
                              ),
                            ],
                          )
                          : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 40),
                                Text("Attach Bill Photo (Optional)"),
                              ],
                            ),
                          ),
                ),
              ),
              SizedBox(height: height * 0.06),
              widget.expense != null
                  ? CustomSubmitButton(
                    text: 'Update',
                    isLoading: _expenseController.isLoading.value,
                    onTap: () => _saveExpense(saveAndNew: false),
                    width: width * 0.35,
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomSubmitButton(
                        text: 'Save & New',
                        isLoading: _expenseController.isLoading.value,
                        onTap: () => _saveExpense(saveAndNew: true),
                        width: width * 0.45,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      CustomSubmitButton(
                        text: 'Save',
                        isLoading: _expenseController.isLoading.value,
                        onTap: () => _saveExpense(saveAndNew: false),
                        width: width * 0.35,
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
