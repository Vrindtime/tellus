import 'package:flutter/material.dart';

class PhoneInput extends StatelessWidget {
  const PhoneInput({
    super.key,
    required this.phoneController,
  });

  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: TextField(
        keyboardType: TextInputType.phone,
        controller: phoneController,
        style: Theme.of(context).textTheme.labelMedium,
        decoration: InputDecoration(
          label: const Text("Phone Number"),
          labelStyle: Theme.of(context).textTheme.labelSmall,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.0),
              borderSide: const BorderSide(color: Colors.white, width: 0.5)),
          prefixIcon: Icon(
            Icons.phone,
            color: Theme.of(context).primaryColor,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color:
                  Theme.of(context).primaryColor, // Border color when focused
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}