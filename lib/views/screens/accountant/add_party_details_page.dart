import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tellus/core/id.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? selectedImage;
  String? newPfpId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.party != null) {
      _nameController.text = widget.party!.name;
      _phoneController.text = widget.party!.phoneNumber;
      _gstinController.text = widget.party!.gstin ?? '';
      _companyNameController.text = widget.party!.companyName ?? '';
      _locationController.text = widget.party!.location?? '';
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
      try {
        final storage = Get.find<Storage>();
        final file = await storage.createFile(
          bucketId: CId.partyPfpBucketId, // Replace with your bucket ID
          fileId: 'unique()',
          file: InputFile.fromPath(path: pickedFile.path),
        );
        setState(() {
          newPfpId = file.$id;
        });
      } catch (e) {
        Get.snackbar('Error', 'Failed to upload image: $e');
      }
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile Picture', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildPfpWidget(),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: pickAndUploadImage,
                    child: Text('Upload Image'),
                  ),
                ],
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
                    pfp: newPfpId ?? widget.party?.pfp,
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

  Widget _buildPfpWidget() {
    if (selectedImage != null) {
      return Image.file(selectedImage!, fit: BoxFit.cover);
    } else if (widget.party?.pfp != null) {
      final partyController = Get.find<PartyController>();
      final previewUrl = partyController.getPreviewUrl(widget.party!.pfp!);
      return Image.network(previewUrl, fit: BoxFit.cover);
    } else {
      return Icon(Icons.person, size: 50, color: Colors.grey);
    }
  }

}
