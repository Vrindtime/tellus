import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/services/accountant/consumer_controller.dart';
import 'package:tellus/services/accountant/general_controller.dart';
import 'package:tellus/services/accountant/party_controller.dart';
import 'package:tellus/services/auth/auth_service.dart';
import 'package:tellus/services/vehicle/vehicle_controller.dart';
import 'package:tellus/views/screens/accountant/add_party_details_page.dart';
import 'package:tellus/views/widgets/add_item_widget.dart';
import 'package:intl/intl.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';
import 'package:tellus/views/widgets/extras/date_picker_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/search_text_field_widget.dart';
import 'package:get/get.dart';

class ConsumerTaskPage extends StatefulWidget {
  final ConsumerModel? consumerModel;

  const ConsumerTaskPage({super.key, this.consumerModel});

  @override
  State<ConsumerTaskPage> createState() => _ConsumerTaskPageState();
}

class _ConsumerTaskPageState extends State<ConsumerTaskPage> {
  final GeneralController _generalController = Get.put(GeneralController());
  final PartyController _partyController = Get.put(PartyController());
  final VehicleController _vehicleController = Get.put(VehicleController());
  final ConsumerController _consumerController = Get.put(ConsumerController());
  final AuthService authService = Get.find<AuthService>();

  final TextEditingController _vehicleChargeController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerNameIdController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _shiftingVehicleController =
      TextEditingController();
  final TextEditingController _shiftingVehicleIdController =
      TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();

  double totalAmount = 0.0;
  String discountType = '%';
  DateTime selectedStartDate = DateTime.now();
  List<Map<String, dynamic>> _addedItems = [];

  @override
  void initState() {
    super.initState();

    if (widget.consumerModel != null) {
      _customerNameController.text = widget.consumerModel!.partyName;
      _customerNameIdController.text = widget.consumerModel!.partyId;
      _locationController.text = widget.consumerModel!.workLocation;
      _shiftingVehicleController.text =
          widget.consumerModel!.shiftingVehicle ?? '';
      _shiftingVehicleIdController.text =
          widget.consumerModel!.shiftingVehicleId ?? '';
      _vehicleChargeController.text =
          widget.consumerModel!.shiftingVehicleCharge?.toString() ?? '';
      _discountController.text =
          widget.consumerModel!.discount?.toString() ?? '';
      _amountPaidController.text =
          widget.consumerModel!.amountPaid?.toString() ?? '';
      _addedItems = widget.consumerModel!.items;
      discountType = widget.consumerModel!.discountType ?? '%';
      selectedStartDate = widget.consumerModel!.workDate;
      _calculateTotalAmount();
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _calculateTotalAmount();
    }
  }

  void _calculateTotalAmount() {
    double vehicleCharge = double.tryParse(_vehicleChargeController.text) ?? 0;
    double discount = double.tryParse(_discountController.text) ?? 0;
    double amountPaid = double.tryParse(_amountPaidController.text) ?? 0;
    double subtotal =
        _addedItems.fold(0.0, (sum, item) {
          return sum + (item['quantity'] * item['sellPrice'] as double);
        }) +
        vehicleCharge;

    if (discountType == '%') {
      totalAmount = subtotal - (subtotal * discount / 100);
    } else {
      totalAmount = subtotal - discount;
    }
    totalAmount -= amountPaid;
    setState(() {});
  }

  void _addItem() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const AddItemWidget(),
    );
    if (result != null) {
      setState(() {
        _addedItems.add({...result});
        _calculateTotalAmount();
        _generalController.refreshData();
      });
    }
  }

  void _editItem(int index) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddItemWidget(initialData: _addedItems[index]),
    );
    if (result != null) {
      setState(() {
        _addedItems[index] = {...result};
        _calculateTotalAmount();
        _generalController.refreshData();
      });
    }
  }

  void _deleteItem(int index) {
    setState(() {
      _addedItems.removeAt(index);
      _calculateTotalAmount();
      _generalController.refreshData();
    });
  }

  Widget _buildActionButtons(int index) {
    final double scaleFactor = MediaQuery.of(context).size.width / 360;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 8 * scaleFactor),
        GestureDetector(
          onTap: () => _editItem(index),
          child: Icon(
            Icons.edit,
            color: Colors.blue.shade700,
            size: 14 * scaleFactor,
          ),
        ),
        SizedBox(width: 8 * scaleFactor),
        GestureDetector(
          onTap: () => _deleteItem(index),
          child: Icon(
            Icons.delete,
            color: Colors.red.shade700,
            size: 14 * scaleFactor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final double scaleFactor = width / 360;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Consumer Work',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontSize: 18 * scaleFactor),
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
        actions: [
          if (widget.consumerModel != null)
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
                          'Are you sure you want to delete this booking?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _consumerController.deleteBooking(
                                widget.consumerModel!.id!,
                              );
                              // Optionally, you can show a success message here
                              Navigator.of(context).pop(true);
                              Get.snackbar(
                                'Success',
                                'The booking has been deleted successfully',
                              );
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
                  await _consumerController.deleteBooking(
                    widget.consumerModel!.id!,
                  );
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0 * scaleFactor,
            right: 16.0 * scaleFactor,
            top: 8.0 * scaleFactor,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + 8.0 * scaleFactor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomDatePicker(
                label: 'Start Date',
                initialDate: selectedStartDate,
                onDateSelected: (date) {
                  setState(() {
                    selectedStartDate = date;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8 * scaleFactor),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: SearchTextField(
                      label: 'Customer Name',
                      controller: _customerNameController,
                      suggestionsCallback: _partyController.getPartySuggestions,
                      onSuggestionSelected: (suggestion) {
                        _customerNameController.text = suggestion['name']!;
                        _customerNameIdController.text = suggestion['id']!;
                        print('DEBUG: ${_customerNameIdController.text}');
                      },
                    ),
                  ),
                  SizedBox(width: 8 * scaleFactor),
                  Expanded(
                    flex: 1,
                    child: CustomSubmitButton(
                      text: '+',
                      isLoading: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.bottomToTop,
                            child: const AddPartyDetailsPage(),
                          ),
                        );
                      },
                      width: width * 0.15,
                      height: height * 0.06,
                      padding: 0,
                    ),
                  ),
                ],
              ),
              CustomTextInput(
                label: 'Work Location',
                icon: Icons.location_on,
                controller: _locationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 4 * scaleFactor),
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0 * scaleFactor),
                ),
                color: Theme.of(context).cardColor,
                child: Container(
                  height: 220 * scaleFactor,
                  width: double.infinity,
                  padding: EdgeInsets.all(8.0 * scaleFactor),
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 10.0 * scaleFactor,
                      headingRowHeight: 32 * scaleFactor,
                      dataRowHeight: 32 * scaleFactor,
                      headingRowColor: WidgetStateProperty.all(
                        Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      dataRowColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.08);
                        }
                        return null;
                      }),
                      dividerThickness: 0.5,
                      columns: [
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Name',
                              style: TextStyle(
                                fontSize: 12 * scaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Qtn',
                              style: TextStyle(
                                fontSize: 12 * scaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Cost',
                              style: TextStyle(
                                fontSize: 12 * scaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Sell',
                              style: TextStyle(
                                fontSize: 12 * scaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: 12 * scaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Actions',
                              style: TextStyle(
                                fontSize: 12 * scaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows:
                          _addedItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final amount = item['quantity'] * item['sellPrice'];

                            return DataRow(
                              cells: [
                                DataCell(
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      item['name'],
                                      style: TextStyle(
                                        fontSize: 10 * scaleFactor,
                                        color:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    item['quantity'].toString(),
                                    style: TextStyle(
                                      fontSize: 10 * scaleFactor,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    item['costPrice'].toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 10 * scaleFactor,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    item['sellPrice'].toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 10 * scaleFactor,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    amount.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 10 * scaleFactor,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 8.0 * scaleFactor,
                                    ),
                                    child: _buildActionButtons(index),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10 * scaleFactor),
              CustomSubmitButton(
                text: 'Add Item',
                isLoading: false,
                onTap: _addItem,
                width: width * 0.3,
                height: 42 * scaleFactor,
              ),
              SizedBox(height: 8 * scaleFactor),
              Row(
                children: [
                  Expanded(
                    child: SearchTextField(
                      label: 'Shifting Vehicle',
                      controller: _shiftingVehicleController,
                      suggestionsCallback:
                          _vehicleController.getVehicleSuggestions,
                      onSuggestionSelected: (suggestion) {
                        _shiftingVehicleController.text = suggestion['name']!;
                        setState(() {
                          _shiftingVehicleIdController.text = suggestion['id']!;
                        });
                        print('DEBUG: ${_shiftingVehicleIdController.text}');
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                  SizedBox(width: 8 * scaleFactor),
                  Expanded(
                    child: CustomTextInput(
                      label: 'Charge',
                      controller: _vehicleChargeController,
                      icon: Icons.car_rental,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _calculateTotalAmount();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * scaleFactor),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomTextInput(
                      label: 'Discount',
                      controller: _discountController,
                      icon: Icons.percent,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _calculateTotalAmount();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Discount is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8 * scaleFactor),
                  Expanded(
                    flex: 2,
                    child: CustomDropdown(
                      label: 'Discount Type',
                      selectedValue: discountType,
                      items: const ['%', 'Rs'],
                      onChanged: (value) {
                        setState(() {
                          discountType = value!;
                          _calculateTotalAmount();
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * scaleFactor),
              Text(
                'Total Amount: Rs ${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16 * scaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8 * scaleFactor),
              CustomTextInput(
                label: 'Amount Paid',
                controller: _amountPaidController,
                icon: Icons.payment,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _calculateTotalAmount();
                },
              ),
              SizedBox(height: 8 * scaleFactor),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomSubmitButton(
                    text: widget.consumerModel == null ? 'Create' : 'Update',
                    isLoading: false,
                    onTap: () async {
                      try {
                        final booking = ConsumerModel(
                          id: widget.consumerModel?.id,
                          organizationId: authService.orgId.value,
                          partyId: _customerNameIdController.text,
                          partyName: _customerNameController.text,
                          workDate: selectedStartDate,
                          workLocation: _locationController.text,
                          shiftingVehicle:
                              _shiftingVehicleController.text.isEmpty
                                  ? null
                                  : _shiftingVehicleController.text,
                          shiftingVehicleId:
                              _shiftingVehicleIdController.text.isEmpty
                                  ? null
                                  : _shiftingVehicleIdController.text,
                          shiftingVehicleCharge: double.tryParse(
                            _vehicleChargeController.text,
                          ),
                          items: _addedItems,
                          discount: double.tryParse(_discountController.text),
                          discountType: discountType,
                          netAmount: totalAmount,
                          amountPaid: double.tryParse(
                            _amountPaidController.text,
                          ),
                        );

                        if (widget.consumerModel == null) {
                          await _consumerController.createBooking(booking);
                          Get.snackbar(
                            'Success',
                            'Booking created successfully',
                          );
                        } else {
                          await _consumerController.editBooking(
                            booking,
                            widget.consumerModel!.id!,
                          );
                          Get.snackbar(
                            'Success',
                            'Booking updated successfully',
                          );
                        }
                      } catch (e) {
                        Get.snackbar('Error', 'Failed to create booking: $e');
                        return;
                      }
                      Navigator.pop(context);
                    },
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 40 * MediaQuery.of(context).size.width / 360,
                    backgroundColor: Theme.of(context).primaryColor,
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
