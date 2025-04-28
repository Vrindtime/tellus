import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/helper/helper.dart';
import 'package:tellus/services/admin/organization_controller.dart';
import 'package:tellus/views/widgets/submit_button.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';
import 'package:get/get.dart';
import 'package:tellus/services/auth/auth_service.dart';

class OrganizationEditPage extends StatefulWidget {
  const OrganizationEditPage({super.key});

  @override
  OrganizationEditPageState createState() => OrganizationEditPageState();
}

class OrganizationEditPageState extends State<OrganizationEditPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String get orgId => _authService.orgId.value;

  String? orgName;
  String? phoneNumber;
  String? orgUPI;
  String? accountHolderName;
  String? accountNumber;
  String? accountIFSC;
  File? selectedImage;
  String newPfpUrl = '';
  var isLoading = false;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _orgAddressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _orgUPIController = TextEditingController();
  final TextEditingController _accountHolderNameController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountIFSCController = TextEditingController();


  final AuthService _authService = Get.find<AuthService>();
  final OrganizationController _orgController = Get.put(
    OrganizationController(),
  );
  

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (orgId.isNotEmpty) {
      final org = await _orgController.fetchOrgById(orgId);
      if (org != null) {
        setState(() {
          _idController.text = orgId;
          _nameController.text = org['orgName'] ?? '';
          _orgAddressController.text = org['orgAddress'] ?? '';
          _phoneController.text = org['phoneNumber'] ?? '';
          _orgUPIController.text = org['orgUPI'] ?? '';
          _accountHolderNameController.text = org['accountHolderName'] ?? '';
          _accountNumberController.text = org['accountNumber'] ?? '';
          _accountIFSCController.text = org['accountIFSC'] ?? '';
          newPfpUrl = org['orgLogo'];
        });
        debugPrint('DEBUG : Org Logo: $newPfpUrl');
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _orgUPIController.dispose();
    _accountHolderNameController.dispose();
    _accountNumberController.dispose();
    _accountIFSCController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Organization Settings',
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        isLoading = true;
                      });
                      final url = await saveImageAndGetUrl(
                        file: XFile(pickedFile.path),
                        bucketId: CId.orgLogoBucketId,
                      );
                      if (url != null) {
                        setState(() {
                          // _orgLogo = File(pickedFile.path);
                          newPfpUrl = url;
                          isLoading = false;
                        });
                      }
                    }
                  },
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey, width: 2),
                      color: Colors.grey[200],
                    ),
                    child:
                        newPfpUrl!.isEmpty
                            ? Icon(Icons.camera_alt, size: 48)
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.network(
                                newPfpUrl,
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                  ),
                ),
                CustomTextInput(
                  label: "Org ID",
                  controller: _idController,
                  keyboardType: TextInputType.text,
                  icon: Icons.perm_identity,
                  readOnly: true,
                  hintText: "This field is not editable",
                ),
                CustomTextInput(
                  label: "Organization Name",
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  icon: Icons.business,
                  onSaved: (value) {
                    orgName = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter organization name';
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
                  label: "Adress",
                  controller: _orgAddressController,
                  keyboardType: TextInputType.streetAddress,
                  icon: Icons.location_on_rounded,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your adresss';
                    }
                    return null;
                  },
                ),
                CustomTextInput(
                  label: "UPI ID",
                  controller: _orgUPIController,
                  keyboardType: TextInputType.text,
                  icon: Icons.person,
                  onSaved: (value) {
                    orgUPI = value;
                  },
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      // Simple UPI ID validation: must contain '@' and at least 3 chars before and after
                      final parts = value.split('@');
                      if (parts.length != 2 ||
                          parts[0].length < 3 ||
                          parts[1].length < 3) {
                        return 'Enter a valid UPI ID';
                      }
                    }
                    return null;
                  },
                ),
                CustomTextInput(
                  label: "Account Holder Name",
                  controller: _accountHolderNameController,
                  keyboardType: TextInputType.text,
                  icon: Icons.person,
                  onSaved: (value) {
                    accountHolderName = value;
                  },
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length < 3) {
                        return 'Name too short';
                      }
                    }
                    return null;
                  },
                ),
                CustomTextInput(
                  label: "Account Number",
                  controller: _accountNumberController,
                  keyboardType: TextInputType.number,
                  icon: Icons.numbers,
                  onSaved: (value) {
                    accountNumber = value;
                  },
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length < 6) {
                        return 'Account number too short';
                      }
                    }
                    return null;
                  },
                ),
                CustomTextInput(
                  label: "Account IFSC",
                  controller: _accountIFSCController,
                  keyboardType: TextInputType.text,
                  icon: Icons.code,
                  onSaved: (value) {
                    accountIFSC = value;
                  },
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      // IFSC validation: 4 letters + 7 alphanumeric
                      final regex = RegExp(r'^[A-Za-z]{4}[a-zA-Z0-9]{7}$');
                      if (!regex.hasMatch(value)) {
                        return 'Invalid IFSC code';
                      }
                    }
                    return null;
                  },
                ),
                SubmitButton(
                  text: "Save",
                  isLoading: isLoading,
                  onTap: () async {
                    
                      setState(() {
                        isLoading = true;
                      });
                      final data = {
                        'orgName': _nameController.text,
                        'orgAddress': _orgAddressController.text,
                        'phoneNumbers': _phoneController.text,
                        'orgUPI': _orgUPIController.text,
                        'accountHolderName': _accountHolderNameController.text,
                        'accountNumber': _accountNumberController.text,
                        'accountIFSC': _accountIFSCController.text,
                        'orgLogo': newPfpUrl,
                      };
                      await _orgController.editOrganization(orgId, data);
                      setState(() {
                        isLoading = false;
                      });
                    }
                ),
                SizedBox(height: 10,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
