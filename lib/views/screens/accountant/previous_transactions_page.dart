/*
  Page to display previous transactions
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tellus/helper/consumer_invoice.dart';
import 'package:tellus/services/accountant/consumer_controller.dart';
import 'package:tellus/services/accountant/emw_controller.dart';
import 'package:tellus/services/accountant/general_controller.dart';
import 'package:tellus/services/accountant/party_controller.dart';
import 'package:tellus/services/accountant/payment_in_controller.dart';
import 'package:tellus/services/admin/organization_controller.dart';
import 'package:tellus/views/screens/accountant/payment_in_page.dart';
import 'package:tellus/views/screens/admin/task/consumer_task_page.dart';
import 'package:tellus/views/screens/admin/task/finished_task_page.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/extras/date_picker_widget.dart';
import 'package:tellus/views/widgets/extras/transcation_list_tile_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';

class PreviousTransactionsPage extends StatefulWidget {
  const PreviousTransactionsPage({super.key});

  @override
  State<PreviousTransactionsPage> createState() =>
      _PreviousTransactionsPageState();
}

class _PreviousTransactionsPageState extends State<PreviousTransactionsPage> {
  final TextEditingController _searchController = TextEditingController();
  final GeneralController generalController = Get.put(GeneralController());

  final OrganizationController organizationController = Get.put(OrganizationController());
  final PartyController partyController = Get.put(PartyController());

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedType = 'All';

  final List<String> _types = [
    'All',
    'Payment-In',
    'New Booking',
    'Completed Booking',
    'Consumer Booking',
  ];

  // Placeholder for filtered transactions
  List<Map<String, dynamic>> filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await generalController.fetchCombinedList();
  }

  List<dynamic> _getFilteredTransactions() {
    final allTransactions = generalController.combinedList;

    return allTransactions.where((item) {
      // Search filter
      if (_searchController.text.isNotEmpty) {
        final searchText = _searchController.text.toLowerCase();
        final name = _getNameFromItem(item).toLowerCase();
        if (!name.contains(searchText)) return false;
      }

      // Date filter
      final itemDate = _getDateFromItem(item);
      if (_startDate != null && itemDate.isBefore(_startDate!)) return false;
      if (_endDate != null &&
          itemDate.isAfter(_endDate!.add(Duration(days: 1))))
        return false;

      // Type filter
      if (_selectedType != 'All') {
        final itemType = _getTypeFromItem(item);
        if (itemType != _selectedType) return false;
      }

      return true;
    }).toList();
  }

  String _getNameFromItem(dynamic item) {
    if (item is ConsumerModel) return item.partyName;
    if (item is PaymentInModel) return item.customerName;
    if (item is EMWBooking) return item.partyName;
    return '';
  }

  DateTime _getDateFromItem(dynamic item) {
    if (item is ConsumerModel) return item.workDate;
    if (item is PaymentInModel) return item.date;
    if (item is EMWBooking) return item.startDate;
    return DateTime(1970);
  }

  String _getTypeFromItem(dynamic item) {
    if (item is ConsumerModel) return 'Consumer Booking';
    if (item is PaymentInModel) return 'Payment-In';
    if (item is EMWBooking) return 'Completed Booking';
    return 'All';
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double scaleFactor = width / 360;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction History',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 18 * scaleFactor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0 * scaleFactor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Your existing UI widgets...
              CustomTextInput(
                label: 'Search by user or party',
                controller: _searchController,
                icon: Icons.search,
                onChanged: (value) {
                  setState(() {}); // Trigger filter
                },
              ),
              SizedBox(height: 12 * scaleFactor),
              
              // Date pickers (your existing code)
              Row(
                children: [
                  Expanded(
                    child: CustomDatePicker(
                      label: 'Start Date',
                      initialDate: _startDate ?? DateTime(DateTime.now().year, 1, 1),
                      onDateSelected: (date) {
                        setState(() {
                          _startDate = date;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12 * scaleFactor),
                  Expanded(
                    child: CustomDatePicker(
                      label: 'End Date',
                      initialDate: _endDate ?? DateTime.now(),
                      onDateSelected: (date) {
                        setState(() {
                          _endDate = date;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16 * scaleFactor),
              
              // Header row with dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Previous Transactions',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 35 * scaleFactor,
                    width: 120 * scaleFactor,
                    child: CustomDropdown(
                      label: 'Transaction Type',
                      selectedValue: _selectedType,
                      items: _types,
                      onChanged: (val) {
                        setState(() {
                          _selectedType = val!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12 * scaleFactor),
              
              // Transactions list
              Expanded(
                child: Obx(() {
                  final filteredTransactions = _getFilteredTransactions();
                  
                  if (generalController.combinedList.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }
                  
                  if (filteredTransactions.isEmpty) {
                    return Center(
                      child: Text(
                        'No transactions found.',
                        style: TextStyle(
                          fontSize: 14 * scaleFactor,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final item = filteredTransactions[index];
                      final status = _getTypeFromItem(item);

                      return TransactionListTileWidget(
                        title: _getNameFromItem(item),
                        startdate: _getDateFromItem(item).toString().split(' ')[0],
                        enddate: item is EMWBooking 
                          ? item.endDate.toString().split(' ')[0] 
                          : '',
                        status: status,
                        total: '${_getAmountFromItem(item)} Rs',
                        onTap: () => _handleItemTap(item),
                        pay: () => _handlePay(item),
                        share: () => _handleShare(item),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getAmountFromItem(dynamic item) {
    if (item is ConsumerModel) return item.netAmount ?? 0;
    if (item is PaymentInModel) return item.receivedAmount;
    if (item is EMWBooking) return item.netAmount ?? 0;
    return 0;
  }

  void _handleItemTap(dynamic item) {
    // Copy the logic from your BillingPage
    if (item is ConsumerModel) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: ConsumerTaskPage(consumerModel: item),
        ),
      );
    } else if (item is PaymentInModel) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: PaymentInPage(paymentInModel: item),
        ),
      );
    } else if (item is EMWBooking) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: CreateFinishedTaskPage(booking: item),
        ),
      );
    }
  }

  void _handlePay(dynamic item) async{
    final organization = await organizationController.fetchOrgById(
      item.organizationId,
    );

    final upiData =
        'upi://pay'
        '?pa=${Uri.encodeComponent(organization?['orgUPI'] ?? '')}'
        '&pn=${Uri.encodeComponent(organization?['orgName'] ?? 'Unknown Organization')}'
        '&am=${item.receivedAmount.toStringAsFixed(2)}'
        '&cu=INR';

    await Share.share(
      'Payment for: ${item.customerName}\n'
      'Payment ID: ${item.id}\n'
      'Organization: ${organization?['orgName'] ?? 'Org Name'}\n'
      'UPI Payment Link:\n$upiData\n'
      'Amount: ${item.receivedAmount} Rs\n',
    );
  }

  void _handleShare(dynamic item) async{
    final organization = await organizationController.fetchOrgById(
      item.organizationId,
    );
    final party = await partyController.fetchPartyById(item.customerId);

    final Map<String, dynamic> invoiceData = {
      'organizationName': organization?['orgName'] ?? 'Company Name',
      'organizationAddress': organization?['orgAddress'] ?? 'orgAddress',
      'organizationPhone': organization?['phoneNumber'] ?? 'Phone Number',
      'invoiceNumber':
          item.id?.toString() ?? 'PAY-${DateTime.now().millisecondsSinceEpoch}',
      'clientName': party?['name'] ?? item.customerName,
      'clientPhone': party?['phone'] ?? '',
      'workDate': item.date,
      'workLocation': 'N/A',
      'items': [
        {
          'name': 'Payment Received',
          'unit': 'N/A',
          'quantity': 1,
          'sellPrice': item.receivedAmount,
          'taxOption': 'Without Tax',
        },
      ],
      'amountPaid': item.receivedAmount,
      'paymentNotes': 'Payment via ${item.paymentType}',
    };

    Get.dialog(const Center(child: CircularProgressIndicator()));
    await PdfConsumerInvoice.generateAndSharePdf(
      invoiceData: invoiceData,
      logo: organization?['orgLogo'],
      clientLogo: party?['pfp'],
    );
    Get.back();
  }

}