import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/helper/helper.dart';
import 'package:tellus/services/accountant/general_controller.dart';
import 'package:tellus/services/accountant/party_controller.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final GeneralController _generalController = Get.put(GeneralController());

  String newPfpUrl = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.party != null) {
      _nameController.text = widget.party!.name;
      _phoneController.text = widget.party!.phoneNumber;
      _gstinController.text = widget.party!.gstin ?? '';
      _companyNameController.text = widget.party!.companyName ?? '';
      _locationController.text = widget.party!.location ?? '';
      newPfpUrl = widget.party!.pfp ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.party == null ? 'Add Party Details' : 'Edit Party Details',
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
        actions:
            (widget.party == null)
                ? null
                : [
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        final partyController = Get.find<PartyController>();
                        await partyController.deleteParty(
                          widget.party!.documentId,
                        );
                        _generalController.refreshData();
                        Navigator.pop(context);
                      } catch (e) {
                        Get.snackbar('Error', 'Failed to delete party: $e');
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
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
                    setState(() {
                      isLoading = true;
                    });
                    // Use the pickedFile.path directly,
                    final url = await saveImageAndGetUrl(
                      file: XFile(pickedFile.path),
                      bucketId: CId.partyPfpBucketId,
                    );
                    if (url != null) {
                      setState(() {
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
                      newPfpUrl.isEmpty
                          ? Icon(Icons.camera_alt, size: 48)
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.network(
                              newPfpUrl,
                              width: 160,
                              height: 160,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      Icon(Icons.broken_image, size: 48),
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                label: 'Full Name',
                controller: _nameController,
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                label: 'Phone Number',
                controller: _phoneController,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  }
                  if (value.length != 10 || int.tryParse(value) == null) {
                    return 'Enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                label: 'GSTIN (Optional)',
                controller: _gstinController,
                icon: Icons.business,
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                label: 'Company Name (Optional)',
                controller: _companyNameController,
                icon: Icons.business,
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                label: 'Location',
                controller: _locationController,
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomSubmitButton(
                text: 'Save',
                isLoading: isLoading,
                onTap: () async {
                  if (_nameController.text.isEmpty ||
                      _phoneController.text.isEmpty ||
                      _locationController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all required fields'),
                      ),
                    );
                    return;
                  }

                  final party = Party(
                    documentId: widget.party?.documentId ?? 'unique()',
                    name: _nameController.text,
                    phoneNumber: _phoneController.text,
                    gstin:
                        _gstinController.text.isEmpty
                            ? null
                            : _gstinController.text,
                    companyName:
                        _companyNameController.text.isEmpty
                            ? null
                            : _companyNameController.text,
                    location: _locationController.text,
                    pfp:
                        newPfpUrl.isEmpty
                            ? null
                            : newPfpUrl, // Save only fileId
                  );

                  setState(() {
                    isLoading = true;
                  });

                  try {
                    final partyController = Get.find<PartyController>();
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
                    Get.snackbar('Error', 'Failed to save party: $e');
                  } finally {
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
    );
  }
}
