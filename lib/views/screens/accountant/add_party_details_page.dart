import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/helper/helper.dart';
import 'package:tellus/services/accountant/general_controller.dart';
import 'package:tellus/services/accountant/party_controller.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';
import 'package:image_picker/image_picker.dart';

class AddPartyDetailsPage extends StatefulWidget {
  const AddPartyDetailsPage({super.key, this.party});

  final Party? party;

  @override
  State<AddPartyDetailsPage> createState() => _AddPartyDetailsPageState();
}

class _AddPartyDetailsPageState extends State<AddPartyDetailsPage> {
  final ImagePicker _picker = ImagePicker();
  final GeneralController _generalController = Get.find<GeneralController>();
  String newPfpUrl = '';
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final PartyController partyController = Get.find<PartyController>();

    // Initialize fields only once
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.party != null) {
          partyController.setPartyForEdit(widget.party!);
          newPfpUrl = widget.party!.pfp ?? '';
        } else {
          partyController.resetState();
          newPfpUrl = '';
        }
        _isInitialized = true;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.party == null ? 'Add Party Details' : 'Edit Party Details',
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
        actions: widget.party == null
            ? null
            : [
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () async {
                    try {
                      await partyController.deleteParty(widget.party!.documentId);
                      _generalController.refreshData();
                      Navigator.pop(context);
                    } catch (e) {
                      Get.snackbar('Error', 'Failed to delete party: $e');
                    }
                  },
                ),
              ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    partyController.isLoading.value = true;
                    final url = await saveImageAndGetUrl(
                      file: XFile(pickedFile.path),
                      bucketId: CId.partyPfpBucketId,
                    );
                    if (url != null) {
                      setState(() {
                        newPfpUrl = url;
                      });
                    }
                    partyController.isLoading.value = false;
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
                  child: newPfpUrl.isEmpty
                      ? Icon(Icons.camera_alt, size: 48)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            newPfpUrl,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image, size: 48),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                label: 'Full Name',
                controller: partyController.nameController,
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    height: 50,
                    width: 100,
                    child: Obx(
                      () => CustomDropdown(
                        label: 'Country Code',
                        selectedValue: partyController.selectedCountryCode.value,
                        items: partyController.countryCodeList,
                        onChanged: (value) {
                          partyController.selectedCountryCode.value = value!;
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.64,
                    child: CustomTextInput(
                      controller: partyController.phoneController,
                      icon: Icons.phone,
                      label: 'Enter Phone Number (1234567890)',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                label: 'GSTIN (Optional)',
                controller: partyController.gstinController,
                icon: Icons.business,
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                label: 'Company Name (Optional)',
                controller: partyController.companyNameController,
                icon: Icons.business,
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                label: 'Location',
                controller: partyController.locationController,
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Obx(
                () => CustomSubmitButton(
                  text: 'Save',
                  isLoading: partyController.isLoading.value,
                  onTap: () async {
                    final party = Party(
                      documentId: widget.party?.documentId ?? 'unique()',
                      name: partyController.nameController.text,
                      phoneNumber: '${partyController.selectedCountryCode.value}${partyController.phoneController.text}',
                      gstin: partyController.gstinController.text.isEmpty
                          ? null
                          : partyController.gstinController.text,
                      companyName: partyController.companyNameController.text.isEmpty
                          ? null
                          : partyController.companyNameController.text,
                      location: partyController.locationController.text,
                      pfp: newPfpUrl.isEmpty ? null : newPfpUrl,
                    );

                    try {
                      if (widget.party == null) {
                        await partyController.addParty(party);
                      } else {
                        await partyController.updateParty(
                          widget.party!.documentId,
                          party,
                        );
                      }
                      _generalController.refreshData();
                      Navigator.pop(context);
                    } catch (e) {
                      // Do not pop or reset form, just show error
                      Get.snackbar('Error', 'Failed to save party: $e');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}