import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/services/accountant/emw_controller.dart'; // Provides EMWBooking and EMWBookingController
import 'package:tellus/services/auth/auth_service.dart';
import 'package:tellus/services/vehicle/vehicle_controller.dart';
import 'package:tellus/views/screens/accountant/party_details_page.dart';
import 'package:tellus/views/widgets/search_text_field_widget.dart';
import 'package:tellus/views/widgets/extras/date_picker_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';
import 'package:tellus/views/screens/admin/vehicle_managment_page.dart';
import 'package:get/get.dart';
import 'package:tellus/services/accountant/party_controller.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  // --- Dependencies ---
  final AuthService _authService = Get.find<AuthService>();
  final PartyController _partyController = Get.put(PartyController());
  final VehicleController _vehicleController = Get.put(VehicleController());
  final EMWBookingController _emwBookingController = Get.put(EMWBookingController());

  // --- Text Editing Controllers ---
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _vehicleControllerField = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // --- State Variables ---
  DateTime _selectedDate = DateTime.now();
  String? _selectedPartyId; // To store the actual ID of the selected party
  String? _selectedVehicleId; // To store the actual ID of the selected vehicle
  bool _isSaving = false; // To handle loading state for buttons

  // --- Constants ---
  static const double _paddingValue = 16.0;
  static const double _spacingValue = 16.0;

  @override
  void initState() {
    super.initState();
    // Fetch initial data needed for suggestions
    _partyController.fetchParties();
    _vehicleController.fetchVehicles();
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _clientNameController.dispose();
    _vehicleControllerField.dispose();
    _locationController.dispose();
    _depositController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- Helper Methods ---

  /// Clears all input fields, resets the date, and clears selected IDs.
  void _clearForm() {
    _clientNameController.clear();
    _vehicleControllerField.clear();
    _locationController.clear();
    _depositController.clear();
    _notesController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedPartyId = null;
      _selectedVehicleId = null;
      // Consider resetting the DatePicker widget's visual state if necessary
    });
    // Unfocus to hide keyboard
    FocusScope.of(context).unfocus();
  }

  /// Validates required fields and builds the EMWBooking object.
  /// Returns null if validation fails.
  EMWBooking? _validateAndCreateBookingData() {
    if (_clientNameController.text == null || _clientNameController.text.isEmpty) {
       Get.snackbar('Error', 'Please select a Client Name from the suggestions.', snackPosition: SnackPosition.BOTTOM);
       return null;
    }
    if (_vehicleControllerField.text == null || _vehicleControllerField.text.isEmpty) {
       Get.snackbar('Error', 'Please select a Vehicle from the suggestions.', snackPosition: SnackPosition.BOTTOM);
       return null;
    }
    if (_locationController.text.trim().isEmpty) {
       Get.snackbar('Error', 'Please enter a Work Location.', snackPosition: SnackPosition.BOTTOM);
       return null;
    }
     // Add more validation as needed (e.g., date, deposit format)


    return EMWBooking(
      // IDs from state variables
      partyId: _clientNameController.text,
      vehicleId: _vehicleControllerField.text,

      // Date and basic info from UI
      startDate: _selectedDate,
      endDate: _selectedDate, // Assuming end date is same as start for this simple form
      notes: _notesController.text.trim(),
      workLocation: _locationController.text.trim(),
      amountDeposited: double.tryParse(_depositController.text) ?? 0.0,

      // User and Organization Info
      createdBy: _authService.userId.value,
      organizationId: _authService.orgId.value,

      // Default values for fields not in this simplified form
      rentType: '', // Provide sensible defaults or add fields
      quantity: '0',
      rate: 0.0,
      startMeter: 0.0,
      endMeter: 0.0,
      operatorBata: 0.0,
      shiftingVehicle: '',
      shiftingVehicleCharge: 0.0,
      tax: 0.0,
      discount: 0.0,
      discountType: '',
      netAmount: 0.0, // Should likely be calculated if other fields were present
      amountPaid: 0.0,
      status: 'draft', // Use 'draft' as per original logic for partial booking
    );
  }

  /// Handles the common save logic, calling the controller.
  /// [navigateBack] corresponds to the `isSave` parameter in the controller.
  /// `true` = Save & Navigate Back, `false` = Save & Stay (for Save & New).
  Future<void> _saveBooking(bool navigateBack) async {
    final bookingData = _validateAndCreateBookingData();
    if (bookingData == null) {
      return; // Validation failed
    }

    setState(() => _isSaving = true);

    try {
      // Call the controller method. The controller handles Get.back() if navigateBack is true.
      await _emwBookingController.createEMWFinishedBooking(
        bookingData,
        navigateBack, // Pass the flag directly to the controller
      );

      // If we are NOT navigating back (Save & New), clear the form here.
      // The controller handles the success snackbar.
      if (!navigateBack && mounted) { // Check mounted before calling _clearForm
         _clearForm();
      }
      // If navigateBack is true, the controller's Get.back() will handle navigation.

    } catch (e) {
      // Error snackbar is handled by the controller, but log locally too.
      print("Error caught in UI during save booking: $e");
    } finally {
      // Ensure loading state is reset even if an error occurs or widget is disposed
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // --- Widget Builders ---

  /// Builds the main form input fields.
  Widget _buildFormFields(BuildContext context) {
    return SingleChildScrollView( // Makes the form scrollable if content overflows
      padding: const EdgeInsets.only(
          bottom: _paddingValue), // Add padding at the bottom of scroll area
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Make children fill width
        children: [
          // Client Name Input Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: SearchTextField(
                  label: 'Client Name *',
                  controller: _clientNameController,
                  suggestionsCallback: _partyController.getPartySuggestions,
                  onSuggestionSelected: (suggestion) {
                    // ** CRITICAL: Assumes suggestion Map has 'id' and 'name' **
                    _clientNameController.text = suggestion['name']!;
                    setState(() {
                      _selectedPartyId = suggestion['id'];
                    });
                    FocusScope.of(context).unfocus(); // Hide keyboard
                  },
                  // Add validator if needed in SearchTextField itself
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary),
                tooltip: 'Add New Client',
                onPressed: _isSaving ? null : () { // Disable if saving
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const PartyDetailsPage(),
                    ),
                  ).then((_) {
                     // Refresh party list in case a new one was added
                     _partyController.fetchParties();
                     // Clear selection if user navigated away and came back
                     if (_clientNameController.text.isNotEmpty && _selectedPartyId == null) {
                        _clientNameController.clear();
                     }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: _spacingValue),

          // Vehicle Selection Row
          Row(
             crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: SearchTextField(
                  label: 'Select Vehicle *',
                  controller: _vehicleControllerField,
                  suggestionsCallback: _vehicleController.getVehicleSuggestions,
                  onSuggestionSelected: (suggestion) {
                    // ** CRITICAL: Assumes suggestion Map has 'id' and 'name' **
                    _vehicleControllerField.text = suggestion['name']!;
                    setState(() {
                       _selectedVehicleId = suggestion['id'];
                    });
                    FocusScope.of(context).unfocus();
                  },
                  // Add validator if needed
                ),
              ),
               const SizedBox(width: 8),
               IconButton(
                 icon: Icon(Icons.directions_car_outlined, color: Theme.of(context).colorScheme.primary), // Changed Icon slightly
                 tooltip: 'Manage Vehicles', // Changed tooltip to be more general
                onPressed: _isSaving ? null : () { // Disable if saving
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: VehicleManagementPage(), // Ensure this page exists
                    ),
                  ).then((_) {
                     // Refresh vehicle list in case changes were made
                     _vehicleController.fetchVehicles();
                      // Clear selection if user navigated away and came back
                     if (_vehicleControllerField.text.isNotEmpty && _selectedVehicleId == null) {
                       _vehicleControllerField.clear();
                     }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: _spacingValue),

          // Date Picker
          VehicleDatePickerTextField( // Ensure this widget visually updates on state change
            label: 'Select Date *',
            initialDate: _selectedDate,
            onDateSelected: (date) {
              // Only update state if not currently saving
              if (!_isSaving) {
                 setState(() {
                   _selectedDate = date;
                 });
              }
            },
            validator: (value) { // Validator might be inside the widget, this is illustrative
              if (value == null) {
                return 'Please select a date';
              }
              return null;
            },
          ),
          const SizedBox(height: _spacingValue),

          // Location Input
          CustomTextInput(
            label: 'Work Location *',
            controller: _locationController,
            icon: Icons.location_on_outlined,
            enabled: !_isSaving, // Disable if saving
             // Add validator if needed within CustomTextInput
          ),
          const SizedBox(height: _spacingValue),

          // Deposit Input
          CustomTextInput(
            label: 'Deposit/Prepaid Amount',
            controller: _depositController,
            icon: Icons.account_balance_wallet_outlined,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            enabled: !_isSaving, // Disable if saving
            // Add validator if needed (e.g., ensure numeric)
          ),
          const SizedBox(height: _spacingValue),

          // Notes Input
          CustomTextInput(
            label: 'Additional Notes',
            controller: _notesController,
            icon: Icons.notes_outlined,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            enabled: !_isSaving, // Disable if saving
          ),
        ],
      ),
    );
  }

  /// Builds the action buttons ("Save & New", "Save") at the bottom.
  Widget _buildActionButtons(BuildContext context) {
     double screenWidth = MediaQuery.of(context).size.width;
    // Calculate button widths dynamically, ensuring they don't overlap with padding
    double availableWidth = screenWidth - (2 * _paddingValue); // Account for horizontal padding of the page
    double buttonWidth = (availableWidth * 0.40).clamp(120.0, 150.0) ; // Adjust multiplier and clamp as needed

    return Padding(
      // Padding around the button row itself
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly space the buttons
        children: [
          CustomSubmitButton(
            text: 'Save & New',
            isLoading: _isSaving, // Use loading state
            // Call _saveBooking with false: Controller doesn't navigate back, UI clears form.
            onTap: () => _saveBooking(false),
            width: buttonWidth,
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          CustomSubmitButton(
            text: 'Save',
            isLoading: _isSaving, // Use loading state
            // Call _saveBooking with true: Controller handles navigation back.
            onTap: () => _saveBooking(true),
            width: buttonWidth,
            // backgroundColor will use default (likely primary color)
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          'Create New Booking',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 19),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          // Overall horizontal padding for the page content
          padding: const EdgeInsets.symmetric(horizontal: _paddingValue),
          child: Column( // Main layout: Form scrolls, buttons stay at bottom
            children: [
              // This makes the form area take up available space and become scrollable
              Expanded(
                child: _buildFormFields(context),
              ),
              // This widget stays fixed at the bottom, outside the scroll view
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }
}