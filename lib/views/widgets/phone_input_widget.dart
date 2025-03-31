import 'package:flutter/material.dart';

class PhoneValidInput extends StatelessWidget {
  final TextEditingController inputController;
   PhoneValidInput({super.key, required this.inputController});
  final TextEditingController test = TextEditingController();
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    // Check if the entered value is exactly 10 digits
    if (value.length != 10 || int.tryParse(value) == null) {
      return 'Phone number must be 10 digits';
    }
    return null; // Return null if the validation succeeds
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
          child: TextFormField(
            controller: inputController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              label: const Text("Phone"),
              labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              prefixIcon: Icon(
                Icons.phone,
                color: Theme.of(context).primaryColor,
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              hintText: '1234567890',
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 15.0,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.0,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.0,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.0,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
            ),
            validator: _validatePhoneNumber,
          ),
        ),
      ],
    );
  }
}
