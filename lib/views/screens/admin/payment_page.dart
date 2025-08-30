import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tellus/models/payroll_model.dart';
import 'package:tellus/services/admin/new_employee_controller.dart';
import 'package:tellus/services/admin/payroll_controller.dart';
import 'package:tellus/views/screens/admin/payment_history_page.dart';

class PaymentPage extends StatefulWidget {
  final UserEmployeeWithName userEmployee; // Pass employee + user info here

  const PaymentPage({Key? key, required this.userEmployee}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  void _openHistoryPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PaymentHistoryPage(
              employeeId: widget.userEmployee.employee.id!,
              organizationId: widget.userEmployee.employee.organizationId,
              userName: widget.userEmployee.userName,
            ),
      ),
    );
  }

  final PayrollController payrollController = Get.find<PayrollController>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController grossSalaryController = TextEditingController();
  final TextEditingController deductionsController = TextEditingController();
  final TextEditingController netSalaryController = TextEditingController();
  final TextEditingController amountPaidController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  DateTime selectedSalaryDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  String paymentStatus = "Pending"; // or Paid, Partial, etc.

  @override
  void initState() {
    super.initState();
    // 1) Preload from employee
    final emp = widget.userEmployee.employee;
    if (emp.paymentType == 'Fixed' && emp.fixedSalary != null) {
      grossSalaryController.text = emp.fixedSalary!.toStringAsFixed(2);
      deductionsController.text = '0';
      calculateNetSalary(); // sets netSalary = gross - deductions
      amountPaidController.text = netSalaryController.text; // default full pay
      paymentStatus = 'Paid';
    }

    // 2) Ensure payrolls are loaded for history display everywhere
    payrollController.fetchPayrolls();
  }

  void calculateNetSalary() {
    final gross = double.tryParse(grossSalaryController.text) ?? 0.0;
    final deductions = double.tryParse(deductionsController.text) ?? 0.0;
    final net = (gross - deductions).clamp(0, double.infinity);
    netSalaryController.text = net.toStringAsFixed(2);

    // If user hasn’t typed amountPaid yet or it equals old net, keep it in sync
    final currentPaid = double.tryParse(amountPaidController.text) ?? 0.0;
    if (currentPaid == 0 || (currentPaid - net).abs() < 0.01) {
      amountPaidController.text = net.toStringAsFixed(2);
      paymentStatus = 'Paid';
      setState(() {});
    }
  }

  Future<void> _selectSalaryDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedSalaryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        selectedSalaryDate = DateTime(picked.year, picked.month);
      });
    }
  }

  void _savePayroll() async {
    if (_formKey.currentState!.validate()) {
      final payroll = Payroll(
        employeeId: widget.userEmployee.employee.id!, // EMP DOC ID
        organizationId: widget.userEmployee.employee.organizationId,
        salaryDate: DateTime(selectedSalaryDate.year, selectedSalaryDate.month),
        grossSalary: double.tryParse(grossSalaryController.text) ?? 0.0,
        deductions: double.tryParse(deductionsController.text) ?? 0.0,
        netSalary: double.tryParse(netSalaryController.text) ?? 0.0,
        amountPaid: double.tryParse(amountPaidController.text) ?? 0.0,
        paymentStatus: paymentStatus,
        notes: notesController.text,
      );
      await Get.find<PayrollController>().createPayroll(payroll);
      Get.snackbar('Success', 'Payroll record saved');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double scaleFactor = width / 360;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Payment for ${widget.userEmployee.userName}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontSize: 18 * scaleFactor),
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0 * scaleFactor,
            right: 16.0 * scaleFactor,
            top: 8.0 * scaleFactor,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + 8.0 * scaleFactor,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Salary Month:',
                          style: TextStyle(
                            fontSize: 14 * scaleFactor,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        SizedBox(width: 8 * scaleFactor),
                        Text(
                          DateFormat('yyyy-MM').format(selectedSalaryDate),
                          style: TextStyle(
                            fontSize: 14 * scaleFactor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.calendar_today,
                            size: 18 * scaleFactor,
                          ),
                          onPressed: () => _selectSalaryDate(context),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _openHistoryPage,
                      icon: Icon(
                        Icons.history,
                        size: 18 * scaleFactor,
                        color: Theme.of(context).primaryColor,
                      ),
                      label: Text(
                        'History',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13 * scaleFactor,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8 * scaleFactor,
                          vertical: 4 * scaleFactor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8 * scaleFactor),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * scaleFactor),
                TextFormField(
                  controller: grossSalaryController,
                  readOnly: widget.userEmployee.employee.paymentType == 'Fixed',
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 14 * scaleFactor,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Gross Salary',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13 * scaleFactor,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                    ),
                  ),
                  onChanged: (_) => calculateNetSalary(),
                  validator:
                      (val) => (val == null || val.isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 10 * scaleFactor),
                TextFormField(
                  controller: deductionsController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 14 * scaleFactor,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Deductions',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13 * scaleFactor,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                    ),
                  ),
                  onChanged: (_) => calculateNetSalary(),
                ),
                SizedBox(height: 10 * scaleFactor),
                TextFormField(
                  controller: netSalaryController,
                  readOnly: true,
                  style: TextStyle(
                    fontSize: 14 * scaleFactor,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Net Salary',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13 * scaleFactor,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                    ),
                  ),
                ),
                SizedBox(height: 10 * scaleFactor),
                TextFormField(
                  controller: amountPaidController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 14 * scaleFactor,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount Paid',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13 * scaleFactor,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                    ),
                  ),
                ),
                SizedBox(height: 10 * scaleFactor),
                DropdownButtonFormField<String>(
                  value: paymentStatus,
                  onChanged:
                      (val) => setState(() => paymentStatus = val ?? 'Pending'),
                  items:
                      ['Pending', 'Paid', 'Partial']
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13 * scaleFactor,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  decoration: InputDecoration(
                    labelText: 'Payment Status',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13 * scaleFactor,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                    ),
                  ),
                ),
                SizedBox(height: 10 * scaleFactor),
                TextFormField(
                  controller: notesController,
                  style: TextStyle(
                    fontSize: 14 * scaleFactor,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13 * scaleFactor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                    ),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 18 * scaleFactor),
                SizedBox(
                  width: width * 0.6,
                  height: 42 * scaleFactor,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0 * scaleFactor),
                      ),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15 * scaleFactor,
                      ),
                    ),
                    onPressed: _savePayroll,
                    child: const Text(
                      'Save Payment',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
