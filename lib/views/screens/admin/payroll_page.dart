import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tellus/services/admin/new_employee_controller.dart';
import 'package:tellus/services/admin/payroll_controller.dart';
import 'package:tellus/views/screens/admin/payment_page.dart';
import 'package:tellus/views/widgets/payroll_list_tile.dart';


class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  final UserEmployeeController userEmployeeController = Get.put(UserEmployeeController());
  final PayrollController payrollController = Get.put(PayrollController());
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  Map<String, String> userNames = {};
  Map<String, String> userRoles = {};
  Map<String, String> joinedDates = {};

  @override
  void initState(){
    super.initState();
    fetchEmployees();
  }

  void fetchEmployees()async{
    await userEmployeeController.loadUserEmployeeList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Payroll Management",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Text('Month:', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedMonth,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDatePickerMode: DatePickerMode.year,
                      );
                      if (picked != null) {
                        setState(() {
                          selectedMonth = DateTime(picked.year, picked.month);
                        });
                      }
                    },
                    child: Text('${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (userEmployeeController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (userEmployeeController.userEmployeeList.isEmpty) {
                  return Center(child: Text('No employees found.', style: Theme.of(context).textTheme.bodyMedium));
                }
                return ListView.builder(
                  itemCount: userEmployeeController.userEmployeeList.length,
                  // separatorBuilder: (_, __) => const SizedBox.shrink(),
                  itemBuilder: (context, index) {
                    final item = userEmployeeController.userEmployeeList[index];
                    return PayrollListTileWidget(
                      title: item.userName,
                      paymentType: item.employee.paymentType,
                      joinedDate: item.employee.joinedDate,
                      onTap:(){
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => PaymentPage(userEmployee: item),
                        ));
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}