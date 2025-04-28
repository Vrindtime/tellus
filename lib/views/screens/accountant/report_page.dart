import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tellus/helper/helper.dart';
import 'package:tellus/services/accountant/report_controller.dart';
import 'package:tellus/views/widgets/extras/date_picker_widget.dart';

class ReportPage extends StatelessWidget {
  ReportPage({super.key});

  final ReportController controller = Get.put(ReportController());

  @override
  Widget build(BuildContext context) {
    // Calculate week boundaries once per build
    final now = DateTime.now();
    final startOfWeek = startOfDay(
      now.subtract(Duration(days: now.weekday - 1)),
    );
    final endOfWeek = endOfDay(now.add(Duration(days: 7 - now.weekday)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        centerTitle: true,
        forceMaterialTransparency: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchReportData(
                controller.startDate.value,
                controller.endDate.value,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          double netProfit =
              controller.totalEarnings.value - controller.totalExpenses.value;
          bool isProfit = netProfit >= 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomDatePicker(
                      label: 'Start Date',
                      initialDate: controller.startDate.value,
                      onDateSelected: (selectedDate) {
                        controller.setDateRange(
                          selectedDate,
                          controller.endDate.value,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                  Expanded(
                    child: CustomDatePicker(
                      label: 'End Date',
                      initialDate: controller.endDate.value,
                      onDateSelected: (selectedDate) {
                        controller.setDateRange(
                          controller.startDate.value,
                          selectedDate,
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _DateFilterButton(
                        label: 'Today',
                        onPressed: () {
                          final today = DateTime.now();
                          controller.setDateRange(
                            startOfDay(today),
                            endOfDay(today),
                          );
                        },
                        isSelected:
                            controller.startDate.value.isSameDate(
                              startOfDay(DateTime.now()),
                            ) &&
                            controller.endDate.value.isSameDate(
                              endOfDay(DateTime.now()),
                            ),
                      ),
                      _DateFilterButton(
                        label: 'This Week',
                        onPressed: () {
                          final now = DateTime.now();
                          final weekStart = startOfDay(
                            now.subtract(Duration(days: now.weekday - 1)),
                          );
                          final weekEnd = endOfDay(
                            now.add(Duration(days: 7 - now.weekday)),
                          );
                          controller.setDateRange(weekStart, weekEnd);
                        },
                        isSelected:
                            controller.startDate.value.isSameDate(
                              startOfWeek,
                            ) &&
                            controller.endDate.value.isSameDate(endOfWeek),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _DateFilterButton(
                        label: 'This Month',
                        onPressed: () {
                          final now = DateTime.now();
                          final startOfMonth = startOfDay(
                            DateTime(now.year, now.month, 1),
                          );
                          final endOfMonth = endOfDay(
                            DateTime(now.year, now.month + 1, 0),
                          );
                          controller.setDateRange(startOfMonth, endOfMonth);
                        },
                        isSelected:
                            controller.startDate.value.isSameDate(
                              DateTime(now.year, now.month, 1),
                            ) &&
                            controller.endDate.value.isSameDate(
                              DateTime(now.year, now.month + 1, 0),
                            ),
                      ),
                      _DateFilterButton(
                        label: 'This Year',
                        onPressed: () {
                          final now = DateTime.now();
                          final startOfYear = startOfDay(
                            DateTime(now.year, 1, 1),
                          );
                          final endOfYear = endOfDay(
                            DateTime(now.year, 12, 31),
                          );
                          controller.setDateRange(startOfYear, endOfYear);
                        },
                        isSelected:
                            controller.startDate.value.isSameDate(
                              DateTime(now.year, 1, 1),
                            ) &&
                            controller.endDate.value.isSameDate(
                              DateTime(now.year, 12, 31),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Earnings vs Expenses',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Total Earnings',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₹${controller.totalEarnings.value.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'Total Expenses',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₹${controller.totalExpenses.value.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(color: Colors.grey.shade400),
                      const SizedBox(height: 20),
                      Text(
                        isProfit ? 'Profit' : 'Loss',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isProfit ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${netProfit.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isProfit ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

extension DateExtensions on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

// Updated _DateFilterButton class
class _DateFilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  const _DateFilterButton({
    required this.label,
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: isSelected
            ? Colors.white
            : Theme.of(context).colorScheme.primary,
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : null,
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}