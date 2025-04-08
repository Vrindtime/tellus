import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      builder: (FormFieldState<String> state) {
        return DropdownButtonHideUnderline(
          child: DropdownButton2(
            isExpanded: true,
            hint: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
              overflow: TextOverflow.clip,
            ),
            value: items.contains(selectedValue) ? selectedValue : null, // Ensure value is valid
            buttonStyleData: ButtonStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface, width: 0.5),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              elevation: 0,
            ),
            onChanged: (value) {
              state.didChange(value);
              print(value);
              if (value != null) {
                onChanged(value); // Notify parent widget of the change
              }
            },
            items: items
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.labelMedium,
                        overflow: TextOverflow.clip,
                      ),
                    ))
                .toList(),
            dropdownStyleData: DropdownStyleData(
              maxHeight: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(10),
                thickness: WidgetStateProperty.all(3),
                thumbVisibility: WidgetStateProperty.all(true),
              ),
            ),
          ),
        );
      },
    );
  }
}
