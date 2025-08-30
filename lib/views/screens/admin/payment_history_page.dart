import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tellus/services/admin/payroll_controller.dart';

class PaymentHistoryPage extends StatelessWidget {
  final String employeeId;
  final String organizationId;
  final String userName;

  const PaymentHistoryPage({
    super.key,
    required this.employeeId,
    required this.organizationId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final PayrollController payrollController = Get.find<PayrollController>();
    final double width = MediaQuery.of(context).size.width;
    final double scaleFactor = width / 360;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment History - $userName',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18 * scaleFactor),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: payrollController.fetchPayrollsByEmployeeAndOrg(
          employeeId: employeeId,
          organizationId: organizationId,
        ),
        builder: (context, snapshot) {
          debugPrint('\n Snapshot Data: ${snapshot.data}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 14 * scaleFactor)),
            );
          }
          final payrolls = snapshot.data as List<dynamic>?;
          if (payrolls == null || payrolls.isEmpty) {
            return Center(
              child: Text(
                'No payment history found.',
                style: TextStyle(fontSize: 14 * scaleFactor),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(16 * scaleFactor),
            itemCount: payrolls.length,
            separatorBuilder: (_, __) => SizedBox(height: 10 * scaleFactor),
            itemBuilder: (context, i) {
              final p = payrolls[i];
              return Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0 * scaleFactor),
                ),
                child: ListTile(
                  title: Text(
                    '${DateFormat('yyyy-MM').format(p.salaryDate)} - ₹${p.grossSalary.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14 * scaleFactor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Net Salary: ₹${p.netSalary.toStringAsFixed(2)}', style: TextStyle(fontSize: 13 * scaleFactor)),
                      Text('Amount Paid: ₹${p.amountPaid.toStringAsFixed(2)}', style: TextStyle(fontSize: 13 * scaleFactor)),
                      Text('Status: ${p.paymentStatus}', style: TextStyle(fontSize: 13 * scaleFactor)),
                      if (p.notes != null && p.notes!.isNotEmpty)
                        Text('Notes: ${p.notes}', style: TextStyle(fontSize: 12 * scaleFactor)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}