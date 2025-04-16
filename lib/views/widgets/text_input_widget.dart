import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Keep for potential input formatters

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
    this.readOnly = false, // Kept for semantic difference if needed, but 'enabled' handles interaction blocking
    this.hintText,
    this.maxLength,
    this.maxLines = 1, // <-- New: Default to 1 line
    this.textInputAction, // <-- New: Default is null (platform decides)
    this.enabled = true, // <-- New: Default to enabled
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final FormFieldSetter<String>? onSaved;
  final FormFieldSetter<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool readOnly; // Can be useful if you want non-editable but selectable/copyable text when enabled=true
  final String? hintText;
  final int? maxLength;
  final int maxLines; // <-- Declaration (no longer nullable due to default)
  final TextInputAction? textInputAction; // <-- Declaration
  final bool enabled; // <-- Declaration (no longer nullable due to default)


  @override
  Widget build(BuildContext context) {
    // Removed the fixed-height SizedBox and Column to allow flexible height,
    // especially needed for multi-line inputs or when error text appears.
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        // Use grey if disabled OR if enabled but readOnly
        color: (!enabled || readOnly) ? Colors.grey : null,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              // Also grey out label if disabled
              color: !enabled ? Colors.grey : null,
            ),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
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
          // Grey out icon if disabled
          color: enabled
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            width: 0.5,
          ),
        ),
        // The disabled border is used when enabled = false
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.4), // Use a grey border when disabled
            width: 0.5,
          ),
        ),
        filled: true,
        // Adjust fillColor when disabled for better visual feedback
        fillColor: enabled
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.grey.withOpacity(0.05),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.0,
          ),
        ),
        // counterText: "", // Uncomment to hide counter if maxLength is used
      ),
      onSaved: onSaved,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly, // Field can be readOnly even if enabled
      maxLength: maxLength,
      maxLines: maxLines, // <-- Pass maxLines
      textInputAction: textInputAction, // <-- Pass textInputAction
      enabled: enabled, // <-- Pass enabled state
      // inputFormatters: maxLength != null
      //     ? [LengthLimitingTextInputFormatter(maxLength)]
      //     : null,
      // maxLengthEnforcement: MaxLengthEnforcement.enforced,
    );
  }
}