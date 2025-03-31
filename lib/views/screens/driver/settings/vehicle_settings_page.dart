import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _formKey = GlobalKey<FormState>();
  final VehicleController _vehicleController = Get.find<VehicleController>();

  File? _image;
  String? vehicleType;
  String? registrationNumber;
  DateTime? ageOfVehicle;
  int? odo;
  double? rentAmount;
  String? rentType;

  bool isLoading = false;

  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _odoController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _registrationController.text = widget.vehicle!.registrationNumber;
      _ageController.text = widget.vehicle!.ageOfVehicle.toIso8601String();
      _odoController.text = widget.vehicle!.odo.toString();
      _rentController.text = widget.vehicle!.rentAmount.toString();
      rentType = widget.vehicle!.rentType;
      vehicleType = widget.vehicle!.vehicleType;
    }
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _ageController.dispose();
    _odoController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Update Vehicle'),
        actions: widget.vehicle != null
            ? [
                IconButton(
                  icon: Icon(Icons.delete,color: Theme.of(context).colorScheme.error,),
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
                SizedBox(height: 12,),
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
                    radius: 80,
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
                    if (value == null || value.isEmpty) {
                      return 'Please enter the registration number';
                    }
                    return null;
                  },
                ),
                VehicleDatePickerTextField(
                  label: "Age of Vehicle",
                  initialDate: widget.vehicle != null
                      ? widget.vehicle!.ageOfVehicle
                      : DateTime.now(),
                  onDateSelected: (selectedDate) {
                    setState(() {
                      ageOfVehicle = selectedDate;
                    });
                    Get.back(); // Close the dialog and pass the date
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select the age of the vehicle';
                    }
                    return null;
                  },
                ),
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
                    if (value == null) {
                      return 'Please select a vehicle type';
                    }
                    return null;
                  },
                ),
                CustomTextInput(
                  icon: Icons.speed,
                  label: "ODO Reading",
                  controller: _odoController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the ODO reading';
                    }
                    return null;
                  },
                ),
                CustomTextInput(
                  icon: Icons.attach_money,
                  label: "Rent Amount",
                  controller: _rentController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the rent amount';
                    }
                    return null;
                  },
                ),
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
                SubmitButton(
                  isLoading: isLoading,
                  text: widget.vehicle == null ? "Add Vehicle" : "Update Vehicle",
                  onTap: () {
                    print('clicked 1');
                    if (_formKey.currentState!.validate()||widget.vehicle!=null) {
                      _formKey.currentState!.save();
                      print('clicked 2');
                      try {
                        Vehicle vehicle = Vehicle(
                          documentId: widget.vehicle?.documentId ?? '', // Assuming you have a documentId field
                          registrationNumber: _registrationController.text,
                          vehicleType: vehicleType!,
                          ageOfVehicle: ageOfVehicle ?? DateTime.now(), // Ensure age is not null
                          odo: int.tryParse(_odoController.text) ?? 0, // Handle invalid input
                          rentAmount: double.tryParse(_rentController.text) ?? 0.0, // Handle invalid input
                          rentType: rentType!,
                        );
                        print('clicked 3');
                        if (widget.vehicle == null) {
                          print('clicked 4');
                          _vehicleController.addVehicle(vehicle);
                        } else {
                          // Assuming `widget.vehicle` has a `documentId` field
                          print('Else part of updatevehicle ');
                          _vehicleController.updateVehicle(widget.vehicle!.documentId, vehicle);
                        }
                        Navigator.pop(context);
                      } catch (e) {
                        Get.snackbar('Error', 'Invalid input: ${e.toString()}');
                      }
                    }else{
                      Get.snackbar('Error', 'Fill All Fields');
                    }
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

