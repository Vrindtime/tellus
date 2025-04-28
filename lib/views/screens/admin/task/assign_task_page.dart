import 'package:flutter/material.dart';
import 'package:tellus/services/accountant/party_controller.dart';
import 'package:tellus/services/accountant/emw_controller.dart';
import 'package:tellus/views/widgets/extras/date_picker_widget.dart';
import 'package:tellus/views/widgets/search_text_field_widget.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/extras/custom_list_tile_widget.dart';
import 'package:get/get.dart';

class AssignTaskPage extends StatefulWidget {
  const AssignTaskPage({super.key});

  @override
  State<AssignTaskPage> createState() => _AssignTaskPageState();
}

class _AssignTaskPageState extends State<AssignTaskPage> {
  final TextEditingController _searchController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TextEditingController dateController = TextEditingController();
  final PartyController _partyController = PartyController();
  final EMWBookingController _emwBookingController = Get.put(
    EMWBookingController(),
  );

  @override
  void initState() {
    super.initState();
    _emwBookingController.fetchEWF();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assign Task',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchTextField(
                label: 'Search Client Name',
                controller: _searchController,
                suggestionsCallback: _partyController.getPartySuggestions,
                onSuggestionSelected: (suggestion) {
                  _searchController.text = suggestion['name']!;
                },
              ),
              SizedBox(height: height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomDropdown(
                      label: 'Status',
                      selectedValue: 'Book',
                      items: ['Book', 'Started', 'Finished'],
                      onChanged: (value) {
                        // fitering
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomDatePicker(
                      label: 'Date',
                      initialDate: selectedDate,
                      onDateSelected: (selectedDate) {
                        setState(() {
                          selectedDate = selectedDate;
                        });
                        Navigator.pop(context);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.02),

              Text('Invoices', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: height * 0.02),
              Obx(
                () => ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _emwBookingController.bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _emwBookingController.bookings[index];
                    return UserListTileWidget(
                      title: booking.partyId,
                      subtitle:
                          booking.startDate.toString().split(' ')[0] +
                          ' To ' +
                          booking.endDate.toString().split(' ')[0],
                      avatarUrl: null,
                      onTap: () {
                        // Optionally, show invoice details
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
