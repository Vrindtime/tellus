import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tellus/views/screens/accountant/vehicle_profit_report_page.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/extras/date_picker_widget.dart';
import 'package:tellus/views/widgets/submit_button.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';
import 'package:get/get.dart';
import 'package:tellus/services/vehicle/vehicle_controller.dart';

class VehicleSettingsPage extends StatefulWidget {
  final Vehicle? vehicle;

  VehicleSettingsPage({this.vehicle});

  @override
  _VehicleSettingsPageState createState() => _VehicleSettingsPageState();
}

class _VehicleSettingsPageState extends State<VehicleSettingsPage> {
  final VehicleController _vehicleController = Get.find<VehicleController>();

  File? _image;
  String? vehicleType;
  String? registrationNumber;
  DateTime? ageOfVehicle;
  int? odo;
  double? rentAmount;
  int? modelYear;
  String? companyName;

  bool isLoading = false;

  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _meterController = TextEditingController();
  final TextEditingController _modelYearController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _registrationController.text = widget.vehicle!.registrationNumber;
      ageOfVehicle = widget.vehicle!.ageOfVehicle; // Directly assign DateTime
      _ageController.text = ageOfVehicle!.toIso8601String(); // For display
      debugPrint('Vehicle Age: ${_ageController.text}');
      _meterController.text = widget.vehicle!.meter.toString();
      _modelYearController.text = widget.vehicle!.modelYear.toString();
      _companyNameController.text = widget.vehicle!.companyName;
      vehicleType = widget.vehicle!.vehicleType;
    }
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _ageController.dispose();
    _meterController.dispose();
    _modelYearController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Update Vehicle'),
        centerTitle: true,
        forceMaterialTransparency: true,
        actions: widget.vehicle != null
            ? [
                IconButton(
                  icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                  onPressed: () async {
                    bool? confirmDelete = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Vehicle'),
                        content: Text('Are you sure you want to delete this vehicle?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmDelete == true) {
                      try {
                        await _vehicleController.deleteVehicle(widget.vehicle!.documentId);
                      } catch (e) {
                        Get.snackbar('Error', 'Failed to delete vehicle: ${e.toString()}');
                      }
                    }
                  },
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              spacing: 15,
              children: [
                SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    setState(() {
                      _image = pickedFile != null ? File(pickedFile.path) : null;
                    });
                  },
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null ? Icon(Icons.camera_alt) : null,
                  ),
                ),
                CustomTextInput(
                  icon: Icons.numbers,
                  label: "Registration Number",
                  controller: _registrationController,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      debugPrint('Validation failed: Registration Number is required');
                      return 'Please enter the registration number';
                    }
                    return null;
                  },
                ),
                CustomDatePicker(
                  label: "Age of Vehicle",
                  initialDate: widget.vehicle != null
                      ? widget.vehicle!.ageOfVehicle
                      : DateTime.now(),
                  onDateSelected: (selectedDate) {
                    setState(() {
                      ageOfVehicle = selectedDate;
                    });
                  },
                  validator: (value) {
                    if (ageOfVehicle == null) {
                      debugPrint('Validation failed: Age of Vehicle is required');
                      return 'Please select the age of the vehicle';
                    }
                    return null;
                  },
                ),
                // Vehicle Type dropdown
                CustomDropdown(
                  label: 'Vehicle Type',
                  items: [
                    'Commercial Vehicle',
                    'Private Vehicle',
                    'Shifting Vehicle',
                    'Excavators',
                    'Backhoe loader',
                    'Wheel loader',
                    'Motor grader',
                    'Skid-steer loader',
                    'Compact Roller',
                    'Dozers',
                    'Articulated dump Truck',
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      vehicleType = newValue;
                    });
                  },
                  selectedValue: vehicleType,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      debugPrint('Validation failed: Vehicle Type is required');
                      return 'Please select a vehicle type';
                    }
                    return null;
                  },
                ),
                CustomTextInput(
                  icon: Icons.speed,
                  label: "Meter Reading",
                  controller: _meterController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the ODO reading';
                    }
                    return null;
                  },
                ),
                CustomTextInput(
                  icon: Icons.calendar_today,
                  label: "Model Year",
                  controller: _modelYearController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the model year';
                    }
                    return null;
                  },
                ),
                CustomTextInput(
                  icon: Icons.business,
                  label: "Company Name",
                  controller: _companyNameController,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the company name';
                    }
                    return null;
                  },
                ),
                SubmitButton(
                  isLoading: isLoading,
                  text: widget.vehicle == null ? "Add Vehicle" : "Update Vehicle",
                  onTap: () {
                    // if (_formKey.currentState!.validate()) {
                      
                      try {
                        Vehicle vehicle = Vehicle(
                          documentId: widget.vehicle?.documentId ?? '',
                          registrationNumber: _registrationController.text,
                          vehicleType: vehicleType!,
                          ageOfVehicle: ageOfVehicle ?? DateTime.now(),
                          meter: int.tryParse(_meterController.text) ?? 0,
                          modelYear: int.tryParse(_modelYearController.text) ?? 0,
                          companyName: _companyNameController.text,
                        );
                        if (widget.vehicle == null) {
                          _vehicleController.addVehicle(vehicle);
                        } else {
                          _vehicleController.updateVehicle(widget.vehicle!.documentId, vehicle);
                        }
                        Navigator.pop(context);
                      } catch (e) {
                        Get.snackbar('Error', 'Invalid input: ${e.toString()}');
                      }
                    // } 
                    // else {
                    //   Get.snackbar('Error', 'Fill All Fields');
                    // }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

