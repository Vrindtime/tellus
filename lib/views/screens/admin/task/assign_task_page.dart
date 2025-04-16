import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/services/accountant/party_controller.dart';
import 'package:tellus/services/accountant/emw_controller.dart';
import 'package:tellus/views/screens/admin/task/finished_task_page.dart';
import 'package:tellus/views/screens/admin/task/new_task_page.dart';
import 'package:tellus/views/widgets/extras/date_picker_widget.dart';
import 'package:tellus/views/widgets/search_text_field_widget.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/extras/custom_list_tile_widget.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';
import 'package:get/get.dart';

class AssignTaskPage extends StatefulWidget {
  const AssignTaskPage({super.key});

  @override
  State<AssignTaskPage> createState() => _AssignTaskPageState();
}

class _AssignTaskPageState extends State<AssignTaskPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _history = [
    {'name': 'Client A', 'date': '2023-10-01'},
    {'name': 'Client B', 'date': '2023-10-02'},
    {'name': 'Client C', 'date': '2023-10-03'},
    {'name': 'Client D', 'date': '2023-10-03'},
    {'name': 'Client E', 'date': '2023-10-03'},
    {'name': 'Client F', 'date': '2023-10-03'},
    {'name': 'Client G', 'date': '2023-10-03'},
    {'name': 'Client H', 'date': '2023-10-03'},
    {'name': 'Client I', 'date': '2023-10-03'},
    {'name': 'Client J', 'date': '2023-10-03'},
  ];
  DateTime selectedDate = DateTime.now();
  TextEditingController dateController = TextEditingController();
  final PartyController _partyController = PartyController();
  final EMWBookingController _emwBookingController = Get.put(EMWBookingController());

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
                    child: VehicleDatePickerTextField(
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
              
              Text(
                'Invoices',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: height * 0.02),
              Obx(() => ListView.builder(
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
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomSubmitButton(
                      text: 'Finished',
                      isLoading: false,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeftJoined,
                            child: CreateFinishedTaskPage(),
                            childCurrent: AssignTaskPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: CustomSubmitButton(
                      text: 'New',
                      isLoading: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeftJoined,
                            child: CreateTaskPage(),
                            childCurrent: AssignTaskPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
