import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tellus/views/widgets/submit_button.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';

class DriverProfileSettingsPage extends StatefulWidget {
  const DriverProfileSettingsPage({super.key});

  @override
  Driver_ProfileSettingsPageState createState() => Driver_ProfileSettingsPageState();
}

class Driver_ProfileSettingsPageState extends State<DriverProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  File? _licenseImage;
  String? fullName;
  String? dob;
  String? phoneNumber;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  var isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Profile Settings',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    setState(() {
                      _profileImage =
                          pickedFile != null ? File(pickedFile.path) : null;
                    });
                  },
                  child: _profileImage == null
                      ? CircleAvatar(
                          radius: 80,
                          child: Icon(Icons.camera_alt),
                        )
                      : CircleAvatar(
                          radius: 80,
                          backgroundImage: FileImage(File(_profileImage!.path)),
                        ),
                ),
                CustomTextInput(
                  label: "Full Name",
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  icon: Icons.person,
                  onSaved: (value) {
                    fullName = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                CustomTextInput(
                  label: "Date of Birth",
                  controller: _dobController,
                  keyboardType: TextInputType.datetime,
                  icon: Icons.calendar_today,
                  onSaved: (value) {
                    dob = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your date of birth';
                    }
                    return null;
                  },
                ),
                CustomTextInput(
                  label: "Phone Number",
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  icon: Icons.phone,
                  onSaved: (value) {
                    phoneNumber = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length != 10 || int.tryParse(value) == null) {
                      return 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                ),
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    setState(() {
                      _licenseImage =
                          pickedFile != null ? File(pickedFile.path) : null;
                    });
                  },
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: _licenseImage == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 40),
                                Text("Add Driving License"),
                              ],
                            ),
                          )
                        : Image.file(
                            File(_licenseImage!.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SubmitButton(
                  text: "Save",
                  isLoading: isLoading,
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Save the form data
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
