import 'package:flutter/material.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';

class AddPartyDetailsPage extends StatefulWidget {
  const AddPartyDetailsPage({super.key});

  @override
  State<AddPartyDetailsPage> createState() => _AddPartyDetailsPageState();
}

class _AddPartyDetailsPageState extends State<AddPartyDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Party Details'), centerTitle: true),
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
              onTap: () async{
                setState(() {
                  isLoading = true;
                });
                await Future.delayed(const Duration(seconds: 1));
                Navigator.pop(context);
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
