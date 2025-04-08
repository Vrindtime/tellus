import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tellus/views/widgets/submit_button.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';
import 'package:get/get.dart';
import 'package:tellus/services/admin/admin_controller.dart';
import 'package:tellus/services/auth/auth_service.dart';

class AdminProfileSettingsPage extends StatefulWidget {
  const AdminProfileSettingsPage({super.key});

  @override
  AdminProfileSettingsPageState createState() => AdminProfileSettingsPageState();
}

class AdminProfileSettingsPageState extends State<AdminProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  String? fullName;
  String? phoneNumber;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  var isLoading = false;

  final AuthService _authService = Get.find<AuthService>();
  final AdminUserController _adminController = Get.find<AdminUserController>();
  String get userId => _authService.userId.value;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (userId.isNotEmpty) {
      final user = await _adminController.fetchUserById(userId);
      if (user != null) {
        setState(() {
          _idController.text = userId;
          _nameController.text = user['name'] ?? '';
          _roleController.text = user['role'] ?? '';
          _phoneController.text = user['phoneNumber'] ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    _idController.dispose();
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
                  label: "User ID",
                  controller: _idController,
                  keyboardType: TextInputType.text,
                  icon: Icons.perm_identity,
                  readOnly: true,
                  hintText: "This field is not editable",
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
                    if (value.length <= 10) {
                      return 'must be more than 10 digits,include "+91"';
                    }
                    return null;
                  },
                ),
                CustomTextInput(
                  label: "Role",
                  controller: _roleController,
                  keyboardType: TextInputType.text,
                  icon: Icons.badge,
                  readOnly: true,
                  hintText: "This field is not editable",
                ),
                SubmitButton(
                  text: "Save",
                  isLoading: isLoading,
                  onTap: () async{
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Save the form data
                      setState(() {
                        isLoading = true;
                      });
                      final data = {
                        'name': _nameController.text,
                        'phoneNumber': _phoneController.text,
                      };
                      await _adminController.saveUser(userId, data);
                      setState(() {
                        isLoading = false;
                      });
                      
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
