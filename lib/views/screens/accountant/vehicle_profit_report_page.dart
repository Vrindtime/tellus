import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tellus/services/accountant/consumer_controller.dart';
import 'package:tellus/services/accountant/emw_controller.dart';
import 'package:tellus/services/accountant/expense_controller.dart';
import 'package:tellus/services/vehicle/vehicle_controller.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/search_text_field_widget.dart';

class VehicleProfitReportPage extends StatefulWidget {
  const VehicleProfitReportPage({super.key});

  @override
  State<VehicleProfitReportPage> createState() =>
      _VehicleProfitReportPageState();
}

class _VehicleProfitReportPageState extends State<VehicleProfitReportPage> {
  final ExpenseController expenseController = Get.put(ExpenseController());
  final VehicleController vehicleController = Get.put(VehicleController());
  final EMWBookingController emwBookingController = Get.put(
    EMWBookingController(),
  ); // Add this
  final ConsumerController consumerBookingController = Get.put(
    ConsumerController(),
  ); // Add this
  String? selectedVehicleId;
  String? selectedVehicleRegNo;

  @override
  void initState() {
    super.initState();
    expenseController.fetchExpenses();
    vehicleController.fetchVehicles();
    emwBookingController.fetchEWF(); // Use correct method name
    consumerBookingController.fetchAllBookings(); // Use correct method name
  }

  // Calculate vehicle earnings
  double calculateVehicleEarnings(String vehicleId) {
    double totalEarnings = 0;

    // Debug - check if controllers have data
    print('EMW Bookings count: ${emwBookingController.bookings.length}');
    print(
      'Consumer Bookings count: ${consumerBookingController.consumerBookings.length}',
    ); // Note: consumerBookings, not bookings
    print('Selected Vehicle ID: $vehicleId');

    // EMW Bookings - netAmount
    final emwBookings =
        emwBookingController.bookings
            .where((booking) => booking.vehicleId == vehicleId)
            .toList();

    print('Found ${emwBookings.length} EMW bookings for vehicle $vehicleId');

    final emwEarnings = emwBookings.fold<double>(
      0.0,
      (sum, booking) => sum + (booking.netAmount ?? 0.0),
    );

    // Consumer Bookings - shiftingVehicleCharge
    final consumerBookings =
        consumerBookingController
            .consumerBookings // Fixed: consumerBookings
            .where((booking) => booking.shiftingVehicleId == vehicleId)
            .toList();

    print(
      'Found ${consumerBookings.length} Consumer bookings for vehicle $vehicleId',
    );

    final shiftingEarnings = consumerBookings.fold<double>(
      0.0,
      (sum, booking) => sum + (booking.shiftingVehicleCharge ?? 0.0),
    );

    totalEarnings = emwEarnings + shiftingEarnings;

    print('EMW Earnings: ₹$emwEarnings');
    print('Shifting Earnings: ₹$shiftingEarnings');
    print('Total Earnings: ₹$totalEarnings');

    return totalEarnings;
  }

  // Get earnings breakdown for display
  Map<String, dynamic> getEarningsBreakdown(String vehicleId) {
    double emwEarnings = 0;
    double shiftingEarnings = 0;
    List<Map<String, dynamic>> earningsDetails = [];

    // EMW Bookings
    final emwBookings =
        emwBookingController.bookings
            .where((booking) => booking.vehicleId == vehicleId)
            .toList();

    for (var booking in emwBookings) {
      double amount = booking.netAmount ?? 0;
      emwEarnings += amount;
      earningsDetails.add({
        'type': 'EMW Work',
        'client': booking.partyName,
        'location': booking.workLocation,
        'amount': amount,
        'date': booking.startDate,
      });
    }

    // Consumer Bookings (Shifting)
    final consumerBookings =
        consumerBookingController.consumerBookings
            .where((booking) => booking.shiftingVehicleId == vehicleId)
            .toList();

    for (var booking in consumerBookings) {
      double amount = booking.shiftingVehicleCharge ?? 0;
      shiftingEarnings += amount;
      earningsDetails.add({
        'type': 'Material Shifting',
        'client': booking.partyName,
        'location': booking.workLocation,
        'amount': amount,
        'date': booking.workDate,
      });
    }

    return {
      'total': emwEarnings + shiftingEarnings,
      'emwEarnings': emwEarnings,
      'shiftingEarnings': shiftingEarnings,
      'details': earningsDetails,
    };
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double scaleFactor = width / 360;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Profit Report'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0 * scaleFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Vehicle:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            // Obx(() {
            //   final vehicles = vehicleController.vehicles;
            //   return DropdownButton<String>(
            //     value: selectedVehicleId,
            //     hint: const Text('Choose Vehicle'),
            //     isExpanded: true,
            //     items:
            //         vehicles
            //             .map(
            //               (v) => DropdownMenuItem(
            //                 value: v.documentId,
            //                 child: Text(v.registrationNumber),
            //               ),
            //             )
            //             .toList(),
            //     onChanged: (val) {
            //       setState(() {
            //         selectedVehicleId = val;
            //       });
            //     },
            //   );
            // }),
            CustomDropdown(
              label: 'Choose Vehicle',
              selectedValue: selectedVehicleRegNo,
              items: vehicleController.vehicles.map((v) => v.registrationNumber).toList(),
              onChanged: (val) {
                setState(() {
                  selectedVehicleRegNo = val;
                  selectedVehicleId = vehicleController.vehicles.firstWhere((v) => v.registrationNumber == val).documentId;
                });
              },
            ),
            const SizedBox(height: 20),
            if (selectedVehicleId != null)
              Expanded(
                child: Obx(() {
                  final expenses =
                      expenseController.expenses
                          .where((e) => e.vehicleId == selectedVehicleId)
                          .toList();

                  final earningsBreakdown = getEarningsBreakdown(
                    selectedVehicleId!,
                  );
                  final double totalEarnings = earningsBreakdown['total'];
                  final double emwEarnings = earningsBreakdown['emwEarnings'];
                  final double shiftingEarnings =
                      earningsBreakdown['shiftingEarnings'];
                  final List<Map<String, dynamic>> earningsDetails =
                      earningsBreakdown['details'];

                  final double totalExpense = expenses.fold(
                    0.0,
                    (sum, e) => sum + e.amount,
                  );
                  final double netProfit = totalEarnings - totalExpense;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0 * scaleFactor),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Financial Summary',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'EMW Work Earnings:',
                                      style: TextStyle(
                                        fontSize: 14 * scaleFactor,
                                      ),
                                    ),
                                    Text(
                                      '₹${emwEarnings.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Shifting Earnings:',
                                      style: TextStyle(
                                        fontSize: 14 * scaleFactor,
                                      ),
                                    ),
                                    Text(
                                      '₹${shiftingEarnings.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Earnings:',
                                      style: TextStyle(
                                        fontSize: 15 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '₹${totalEarnings.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 15 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Expenses:',
                                      style: TextStyle(
                                        fontSize: 15 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '₹${totalExpense.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 15 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(thickness: 2),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Net Profit:',
                                      style: TextStyle(
                                        fontSize: 16 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '₹${netProfit.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            netProfit >= 0
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Earnings Details
                        Text(
                          'Earnings Details:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        ...earningsDetails.map(
                          (earning) => ListTile(
                            leading: Icon(
                              earning['type'] == 'EMW Work'
                                  ? Icons.construction
                                  : Icons.local_shipping,
                              color: Colors.green,
                            ),
                            title: Text(
                              '${earning['type']} - ₹${earning['amount'].toStringAsFixed(2)}',
                            ),
                            subtitle: Text(
                              '${earning['client']} at ${earning['location']}',
                            ),
                            trailing: Text(
                              DateFormat('yyyy-MM-dd').format(earning['date']),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Expense Details
                        Text(
                          'Expense Details:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        ...expenses.map(
                          (e) => ListTile(
                            leading: const Icon(
                              Icons.money_off,
                              color: Colors.red,
                            ),
                            title: Text(
                              '${e.category} - ₹${e.amount.toStringAsFixed(2)}',
                            ),
                            subtitle: Text(
                              DateFormat('yyyy-MM-dd').format(e.date),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}
