import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tellus/services/accountant/party_controller.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';

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

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.party != null) {
      _nameController.text = widget.party!.name;
      _phoneController.text = widget.party!.phoneNumber;
      _gstinController.text = widget.party!.gstin ?? '';
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
        actions: (widget.party == null)?null:[
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
                await partyController.deleteParty(widget.party!.documentId);
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
            const Spacer(),
            CustomSubmitButton(
              text: 'Save',
              isLoading: isLoading,
              onTap: () async {
                if (_nameController.text.isEmpty ||
                    _phoneController.text.isEmpty) {
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
    );
  }
}
