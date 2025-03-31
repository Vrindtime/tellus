import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  const CustomTextInput({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.onSaved,
    this.onChanged,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final FormFieldSetter<String>? onSaved;
  final FormFieldSetter<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.008,),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: Theme.of(context).textTheme.labelMedium,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: Theme.of(context).textTheme.labelSmall,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 0.5,
                ),
              ),
              prefixIcon: Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              enabledBorder:OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 0.5,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 0.5,
                ),
              ),
            ),
            onSaved: onSaved,
            validator: validator,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
