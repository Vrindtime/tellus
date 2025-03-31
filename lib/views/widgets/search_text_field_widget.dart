import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Future<List<Map<String, String>>> Function(String) suggestionsCallback;
  final ValueChanged<Map<String, String>> onSuggestionSelected;

  const SearchTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.suggestionsCallback,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Map<String, String>>(
      builder: (context, _ , focusNode) {
        return SizedBox(
          height: 60,
          width: double.infinity,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: false,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 0.5,
                ),
              ),
            ),
          ),
        );
      },
      hideWithKeyboard:false,
      suggestionsCallback: suggestionsCallback,
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(
            suggestion['name']!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          subtitle: Text(suggestion['category'] ?? ''),
        );
      },
      onSelected: (suggestion) {
        controller.text = suggestion['name']!;
        onSuggestionSelected(suggestion);
      },
      hideKeyboardOnDrag: true,
    );
  }
}


/// HOW TO USE THIS WIDGET:
///   Widget _buildSearchTextField() {
///     return SearchTextField(
///       label: 'Your Label',
///       controller: _yourController,
///       suggestionsCallback: _getController.getSuggestions,
///       onSuggestionSelected: (suggestion) {
///         _yourController.text = suggestion['name']!;
///         FocusScope.of(context).unfocus();
///       },
///     );
///   }

///   Widget _buildSubmitButton() {
///     return Obx(() => SubmitButton(
///           text: "Submit",
///           isLoading: _getController.isLoading.value,
///           onTap: () {
///             _getController.selected.value = _yourController.text;
///             /// _orgController.selectOrgAndNavigate(_orgTextController);
///             debugPrint('----- Selected value: ${_getController.selected.value} -----');
///             _yourController.clear();
///           },
///     ));
///   }