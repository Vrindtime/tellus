import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/services/accountant/emw_controller.dart';
import 'package:tellus/services/accountant/party_controller.dart';
import 'package:tellus/services/auth/auth_service.dart';
import 'package:tellus/services/vehicle/vehicle_controller.dart';
import 'package:tellus/views/screens/accountant/party_details_page.dart';
import 'package:tellus/views/screens/admin/vehicle_managment_page.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/extras/date_picker_widget.dart';
import 'package:tellus/views/widgets/search_text_field_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';

class CreateFinishedTaskPage extends StatefulWidget {
  final EMWBooking? booking;
  const CreateFinishedTaskPage({super.key, this.booking});

  @override
  State<CreateFinishedTaskPage> createState() => _CreateFinishedTaskPageState();
}

class _CreateFinishedTaskPageState extends State<CreateFinishedTaskPage> {
  final AuthService _authService = Get.find<AuthService>();
  final PartyController _partyController = Get.put(PartyController());
  final VehicleController _vehicleController = Get.put(VehicleController());
  final EMWBookingController bookingController = Get.put(
    EMWBookingController(),
  );

  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startMeterController = TextEditingController();
  final TextEditingController _endMeterController = TextEditingController();
  final TextEditingController _operatorBataController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _shiftingChargeController =
      TextEditingController();
  final TextEditingController _accessoriesRateController =
      TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _additionalNotesController =
      TextEditingController();
  final TextEditingController _workTypeController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();
  final TextEditingController _partyIdController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _shiftingVehicleController =
      TextEditingController();
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  String? rentType;
  String discountType = '%';
  String? accessories;
  bool get isEdit => widget.booking != null;

  @override
  void initState() {
    super.initState();
    _partyController.fetchParties();
    _vehicleController.fetchVehicles();
    if (isEdit) {
      final b = widget.booking!;
      _clientNameController.text = b.partyId;
      _vehicleNameController.text = b.vehicleId;
      selectedStartDate = b.startDate;
      selectedEndDate = b.endDate;
      _additionalNotesController.text = b.notes ?? '';
      rentType = b.rentType.isNotEmpty ? b.rentType : 'Per Hour';
      _hoursController.text = b.quantity;
      _rateController.text = b.rate.toString();
      _startMeterController.text = b.startMeter.toString();
      _endMeterController.text = b.endMeter.toString();
      _operatorBataController.text = b.operatorBata.toString();
      _shiftingVehicleController.text = b.shiftingVehicle;
      _shiftingChargeController.text = b.shiftingVehicleCharge.toString();
      _taxController.text = b.tax.toString();
      _discountController.text = b.discount.toString();
      discountType = b.discountType.isNotEmpty ? b.discountType : '%';
      _depositController.text = b.amountDeposited.toString();
      _amountPaidController.text = b.amountPaid.toString();
      _locationController.text = b.workLocation ?? '';
    } else {
      rentType = 'Per Hour'; // Default rent type
      discountType = '%';
    }
  }

  Widget _buildSearchField({
    required String label,
    required TextEditingController controller,
    required dynamic suggestionsCallback,
    required dynamic onSuggestionSelected,
    IconData? icon,
    VoidCallback? onIconPressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: SearchTextField(
            label: label,
            controller: controller,
            suggestionsCallback: suggestionsCallback,
            onSuggestionSelected: onSuggestionSelected,
          ),
        ),
        if (icon != null && onIconPressed != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(icon, color: Theme.of(context).colorScheme.secondary),
            onPressed: onIconPressed,
          ),
        ],
      ],
    );
  }

  Widget _buildDatePickerRow() {
    return Row(
      children: [
        Expanded(
          child: VehicleDatePickerTextField(
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
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Expanded(
          child: VehicleDatePickerTextField(
            label: 'End Date',
            initialDate: selectedEndDate,
            onDateSelected: (date) {
              setState(() {
                selectedEndDate = date;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a date';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMeterRow() {
    return Row(
      children: [
        Expanded(
          child: CustomTextInput(
            label: 'Start Meter',
            controller: _startMeterController,
            icon: Icons.gas_meter,
            keyboardType: TextInputType.number,
            onChanged: (newValue) {
              _calculateHours(
                _startMeterController.text,
                _endMeterController.text,
              );
              setState(() {});
            },
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Expanded(
          child: CustomTextInput(
            label: 'End Meter',
            controller: _endMeterController,
            icon: Icons.gas_meter,
            keyboardType: TextInputType.number,
            onChanged: (newValue) {
              _calculateHours(
                _startMeterController.text,
                _endMeterController.text,
              );
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
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
            onChanged:
                (newValue) => setState(() {
                  _calculateNetAmount();
                }),
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
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
    );
  }

  void _calculateHours(String startMeter, String endMeter) {
    double start = double.tryParse(startMeter) ?? 0;
    double end = double.tryParse(endMeter) ?? 0;
    double totalMinutes = (end - start) * 60; // 1 point = 60 minutes

    int hours = totalMinutes ~/ 60;
    int minutes = (totalMinutes % 60).toInt();

    _hoursController.text =
        "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}"; // Format as HH:MM
  }

  double _calculateNetAmount() {
    double ratePerHour = double.tryParse(_rateController.text) ?? 0;
    double totalHours =
        double.tryParse(_hoursController.text.replaceAll(':', '.')) ?? 1;
    double shiftingCharge =
        double.tryParse(_shiftingChargeController.text) ?? 0;
    double operatorBata = double.tryParse(_operatorBataController.text) ?? 0;
    double tax = double.tryParse(_taxController.text) ?? 0;
    double accessoriesRate =
        double.tryParse(_accessoriesRateController.text) ?? 0;
    double discount = double.tryParse(_discountController.text) ?? 0;
    double amountPaid = double.tryParse(_amountPaidController.text) ?? 0;
    double deposit = double.tryParse(_depositController.text) ?? 0;

    double total =
        (ratePerHour * totalHours) +
        shiftingCharge +
        operatorBata +
        accessoriesRate;

    // Apply tax as a percentage
    total += (total * (tax / 100));

    // Apply discount based on type
    if (discountType == '%') {
      total -= (total * (discount / 100));
    } else {
      total -= discount;
    }

    total -= (amountPaid + deposit);

    return double.parse(total.toStringAsFixed(3));
  }

  void _saveBooking() async {
    debugPrint('Saving booking...');
    // Print all values before sending
    debugPrint('Client Name: \'${_clientNameController.text}\'');
    debugPrint('Vehicle Name: \'${_vehicleNameController.text}\'');
    debugPrint('Start Date: $selectedStartDate');
    debugPrint('End Date: $selectedEndDate');
    debugPrint('Notes: \'${_additionalNotesController.text}\'');
    debugPrint('Work Location: \'${_locationController.text}\'');
    debugPrint('Rent Type: $rentType');
    debugPrint('Quantity: \'${_hoursController.text}\'');
    debugPrint('Rate: \'${_rateController.text}\'');
    debugPrint('Start Meter: \'${_startMeterController.text}\'');
    debugPrint('End Meter: \'${_endMeterController.text}\'');
    debugPrint('Operator Bata: \'${_operatorBataController.text}\'');
    debugPrint('Shifting Vehicle: \'${_shiftingVehicleController.text}\'');
    debugPrint('Shifting Vehicle Charge: \'${_shiftingChargeController.text}\'');
    debugPrint('Tax: \'${_taxController.text}\'');
    debugPrint('Discount: \'${_discountController.text}\'');
    debugPrint('Discount Type: $discountType');
    debugPrint('Deposit: \'${_depositController.text}\'');
    debugPrint('Amount Paid: \'${_amountPaidController.text}\'');
    debugPrint('Net Amount: ${_calculateNetAmount()}');
    debugPrint('Created By: ${_authService.userId.value}');
    debugPrint('Organization ID: ${_authService.orgId.value}');

    // Validate required fields
    if (_clientNameController.text.isEmpty) {
      Get.snackbar('Error', 'Please select a valid client.');
      return;
    }
    if (_vehicleNameController.text.isEmpty) {
      Get.snackbar('Error', 'Please select a valid vehicle.');
      return;
    }

    final booking = EMWBooking(
      //Client Details
      partyId: _clientNameController.text,
      vehicleId: _vehicleNameController.text,
      startDate: selectedStartDate,
      endDate: selectedEndDate,
      notes: _additionalNotesController.text,
      createdBy: _authService.userId.value,
      organizationId: _authService.orgId.value,
      workLocation: _locationController.text,

      //Charges Details
      rentType: rentType ?? 'Per Hour',
      quantity: _hoursController.text,
      rate: double.tryParse(_rateController.text) ?? 0,
      // if rentType == 'Per Hour' then:
      startMeter: double.tryParse(_startMeterController.text) ?? 0,
      endMeter: double.tryParse(_endMeterController.text) ?? 0,

      //Shifting Details
      operatorBata: double.tryParse(_operatorBataController.text) ?? 0,
      shiftingVehicle: _shiftingVehicleController.text,
      shiftingVehicleCharge:
          double.tryParse(_shiftingChargeController.text) ?? 0,

      // Payment Details
      tax: double.tryParse(_taxController.text) ?? 0,
      discount: double.tryParse(_discountController.text) ?? 0,
      discountType: discountType,
      amountDeposited: double.tryParse(_depositController.text) ?? 0,
      netAmount: _calculateNetAmount(),
      amountPaid: double.tryParse(_amountPaidController.text) ?? 0,

      //Status of the invoice
      status: 'finished',
    );

    if (isEdit) {
      // Update logic
      print(widget.booking!.id);
      await bookingController.updateEMWFinishedBooking(
        widget.booking!,
        booking,
      );
      debugPrint('Booking updated successfully!');
    } else {
      await bookingController.createEMWFinishedBooking(booking, true);
      debugPrint('Booking saved successfully!');
    }
  }

  void _deleteBooking() async {
    if (isEdit) {
      await bookingController.deleteEMWFinishedBooking(widget.booking!);
      Get.back();
    }
  }

  void _saveAndNewBooking() {
    _saveBooking();
    _partyIdController.clear();
    _vehicleNameController.clear();
    _startMeterController.clear();
    _endMeterController.clear();
    _operatorBataController.clear();
    _discountController.clear();
    _amountPaidController.clear();
    _taxController.clear();
    _additionalNotesController.clear();
    _workTypeController.clear();
    _equipmentController.clear();
    _hoursController.clear();
    _rateController.clear();
    _totalCostController.clear();
    rentType = null;
    discountType = '%';
    selectedStartDate = DateTime.now();
    selectedEndDate = DateTime.now();
    setState(() {});
  }

  Widget _buildClientSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client Info', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _buildSearchField(
              label: 'Client Name',
              controller: _clientNameController,
              suggestionsCallback: _partyController.getPartySuggestions,
              onSuggestionSelected: (suggestion) {
                _clientNameController.text = suggestion['name']!;
              },
              icon: Icons.person,
              onIconPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const PartyDetailsPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildSearchField(
              label: 'Select Vehicle',
              controller: _vehicleNameController,
              suggestionsCallback: _vehicleController.getVehicleSuggestions,
              onSuggestionSelected: (suggestion) {
                _vehicleNameController.text = suggestion['name']!;
                FocusScope.of(context).unfocus();
              },
              icon: Icons.directions_car,
              onIconPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: VehicleManagementPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildDatePickerRow(),
            const SizedBox(height: 10),
            CustomTextInput(
              label: 'Work Location',
              controller: _locationController,
              icon: Icons.location_on,
            ),
            const SizedBox(height: 10),
            CustomTextInput(
              label: 'Notes',
              controller: _additionalNotesController,
              icon: Icons.notes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargesSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Charges',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            CustomDropdown(
              label: 'Rent Type',
              items: [
                'Fixed',
                'Per Hour',
                'Per Day',
                'Per Week',
                'Per Km',
                'Per Trip',
              ],
              onChanged: (newValue) {
                setState(() {
                  rentType = newValue;
                });
              },
              selectedValue: rentType,
              validator: (value) {
                if (value == null) {
                  return 'Please select a rent type';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            if (rentType == 'Per Hour') ...[
              _buildMeterRow(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextInput(
                      label: 'Rate per Hour',
                      controller: _rateController,
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextInput(
                      label: 'Total Hours',
                      controller: _hoursController,
                      icon: Icons.timer,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ] else if (rentType != 'Fixed' && rentType != null) ...[
              Row(
                children: [
                  Expanded(
                    child: CustomTextInput(
                      label: 'Rate',
                      controller: _rateController,
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      onChanged:
                          (newValue) => setState(() {
                            _calculateNetAmount();
                          }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextInput(
                      label: 'Quantity',
                      controller: _hoursController,
                      icon: Icons.format_list_numbered,
                      keyboardType: TextInputType.number,
                      onChanged:
                          (newValue) => setState(() {
                            _calculateNetAmount();
                          }),
                    ),
                  ),
                ],
              ),
            ] else if (rentType == 'Fixed') ...[
              CustomTextInput(
                label: 'Rate',
                controller: _rateController,
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                onChanged:
                    (newValue) => setState(() {
                      _calculateNetAmount();
                    }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShiftingSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shifting Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSearchField(
                    label: 'Shifting Vehicle',
                    controller: _shiftingVehicleController,
                    suggestionsCallback:
                        _vehicleController.getVehicleSuggestions,
                    onSuggestionSelected: (suggestion) {
                      _shiftingVehicleController.text = suggestion['name']!;
                      FocusScope.of(context).unfocus();
                    },
                    icon: Icons.local_shipping,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextInput(
                    label: 'Vehicle Charge',
                    controller: _shiftingChargeController,
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    onChanged:
                        (newValue) => setState(() {
                          _calculateNetAmount();
                        }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomTextInput(
              label: 'Operator Bata Charge',
              controller: _operatorBataController,
              icon: Icons.person,
              keyboardType: TextInputType.number,
              onChanged:
                  (newValue) => setState(() {
                    _calculateNetAmount();
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            CustomTextInput(
              label: 'Amount Deposited',
              controller: _depositController,
              icon: Icons.account_balance_wallet,
              keyboardType: TextInputType.number,
              readOnly: true,
              onChanged:
                  (newValue) => setState(() {
                    _calculateNetAmount();
                  }),
            ),
            const SizedBox(height: 10),
            CustomTextInput(
              label: 'Tax',
              controller: _taxController,
              icon: Icons.percent,
              keyboardType: TextInputType.number,
              onChanged:
                  (newValue) => setState(() {
                    _calculateNetAmount();
                  }),
            ),
            const SizedBox(height: 10),
            _buildDiscountRow(),
            const SizedBox(height: 10),
            Text(
              'Net Amount: ${_calculateNetAmount()} Rs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            CustomTextInput(
              label: 'Amount Paid',
              controller: _amountPaidController,
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              onChanged:
                  (newValue) => setState(() {
                    _calculateNetAmount();
                  }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          isEdit ? 'Edit Finished Work' : 'Finished Work',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 19),
        ),
        centerTitle: true,
        actions: [
          if (isEdit)
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: _deleteBooking,
            ),
          IconButton(
            icon: Icon(
              Icons.share,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {
              // Handle share action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildClientSection(),
              _buildChargesSection(),
              _buildShiftingSection(),
              _buildPaymentSection(),
              SizedBox(height: height * 0.02),
              if (!isEdit)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomSubmitButton(
                      text: 'Save & New',
                      isLoading: false,
                      onTap: _saveAndNewBooking,
                      width: width * 0.38,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    CustomSubmitButton(
                      text: 'Save',
                      isLoading: false,
                      onTap: _saveBooking,
                      width: width * 0.2,
                    ),
                  ],
                ),
              if (isEdit)
                CustomSubmitButton(
                  text: 'Update',
                  isLoading: false,
                  onTap: _saveBooking,
                  width: width * 0.8,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
