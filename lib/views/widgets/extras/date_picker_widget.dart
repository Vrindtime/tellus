import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:date_picker_plus/date_picker_plus.dart';

class VehicleDatePickerTextField extends StatefulWidget {
  const VehicleDatePickerTextField({
    super.key,
    required this.label,
    required this.initialDate,
    required this.onDateSelected, required this.validator,
  });

  final String label;
  final DateTime initialDate;
  final Function(DateTime) validator;
  final Function(DateTime) onDateSelected;

  @override
  Vehicle_DatePickerTextFieldState createState() =>
      Vehicle_DatePickerTextFieldState();
}

class Vehicle_DatePickerTextFieldState
    extends State<VehicleDatePickerTextField> {
  DateTime? _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dateController.text = _selectedDate.toString().split(' ')[0];
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  void _showDatePickerDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: DatePicker(
            initialDate: widget.initialDate,
            minDate: DateTime(2020, 10, 10),
            maxDate: DateTime(2050, 10, 30),
            currentDate: DateTime.now(),
            selectedDate: _selectedDate,
            slidersColor: Colors.lightBlue,
            highlightColor: Colors.redAccent,
            slidersSize: 20,
            splashColor: Colors.lightBlueAccent,
            splashRadius: 40,
            centerLeadingDate: true,
            padding: EdgeInsets.all(15),
            selectedCellTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
            enabledCellsTextStyle: Theme.of(context).textTheme.labelMedium,
            currentDateDecoration: const BoxDecoration(
              color: Colors.lightBlueAccent,
              shape: BoxShape.circle,
            ),
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
                _dateController.text = date.toString().split(' ')[0];
              });
              Get.back(result: date);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _dateController,
      readOnly: true, // Prevent manual editing
      onTap: _showDatePickerDialog, // Show dialog on tap
      style: Theme.of(context).textTheme.labelMedium,
      decoration: InputDecoration(
        labelText: 'Select Date',
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
    );
  }
}
