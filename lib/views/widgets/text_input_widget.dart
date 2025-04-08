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
    this.readOnly = false,
    this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final FormFieldSetter<String>? onSaved;
  final FormFieldSetter<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.003,),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: readOnly ? Colors.grey : null,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: Theme.of(context).textTheme.labelSmall,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey),
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
            readOnly: readOnly,
          ),
        ],
      ),
    );
  }
}
