import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({
    super.key,
    required this.label,
    required this.initialDate,
    required this.onDateSelected,
    this.validator, // Made optional, but type is now correct
  });

  final String label;
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final String? Function(String?)? validator; // Changed to match TextField

  @override
  CustomDatePickerState createState() =>
      CustomDatePickerState();
}

class CustomDatePickerState
    extends State<CustomDatePicker> {
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    // _dateController.text = widget.initialDate.toString().split(' ')[0];/
    _dateController.text = _dateFormat.format(widget.initialDate);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _showDatePickerDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: DatePicker(
            initialDate: widget.initialDate,
            minDate: DateTime(2000, 10, 10),
            maxDate: DateTime(2050, 10, 30),
            currentDate: DateTime.now(),
            selectedDate: _selectedDate,
            slidersColor: Colors.lightBlue,
            highlightColor: Colors.redAccent,
            slidersSize: 20,
            splashColor: Colors.lightBlueAccent,
            splashRadius: 40,
            centerLeadingDate: true,
            padding: const EdgeInsets.all(15),
            selectedCellTextStyle: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Colors.white),
            enabledCellsTextStyle: Theme.of(context).textTheme.labelMedium,
            currentDateTextStyle: Theme.of(context).textTheme.labelMedium,
            currentDateDecoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
                // _dateController.text = date.toString().split(' ')[0];
                _dateController.text = _dateFormat.format(date); // Format as dd-MM-yyyy
              });
              widget.onDateSelected(date); // Pass the DateTime to the callback
              Get.back(result: date);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: _showDatePickerDialog,
      style: Theme.of(context).textTheme.labelMedium,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: Theme.of(context).textTheme.labelSmall,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 0.5,
          ),
        ),
        prefixIcon: Icon(
          Icons.calendar_today,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        enabledBorder: OutlineInputBorder(
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
      validator: widget.validator, // Pass the validator to TextField
    );
  }
}