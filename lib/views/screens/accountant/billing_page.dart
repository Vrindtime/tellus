import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tellus/helper/consumer_invoice.dart';
import 'package:tellus/helper/pdf_emw_invoice.dart';
import 'package:tellus/services/accountant/consumer_controller.dart';
import 'package:tellus/services/accountant/emw_controller.dart';
import 'package:tellus/services/accountant/general_controller.dart';
import 'package:tellus/services/accountant/party_controller.dart';
import 'package:tellus/services/accountant/payment_in_controller.dart';
import 'package:tellus/services/admin/organization_controller.dart';
import 'package:tellus/views/screens/accountant/payment_in_page.dart';
import 'package:tellus/views/screens/accountant/previous_transactions_page.dart';
import 'package:tellus/views/screens/admin/task/consumer_task_page.dart';
import 'package:tellus/views/screens/admin/task/finished_task_page.dart';
import 'package:tellus/views/screens/admin/task/new_task_page.dart';
import 'package:tellus/views/widgets/extras/transcation_list_tile_widget.dart';
import 'package:tellus/views/screens/common/quick_link_widget.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final OrganizationController organizationController = Get.put(
    OrganizationController(),
  );

  final PartyController partyController = Get.put(PartyController());

  final GeneralController generalController = Get.put(GeneralController());

  @override
  void initState() {
    super.initState();
    // Initialize the combined list
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await generalController.fetchCombinedList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quick Links", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              QuickLinkWidget(
                icon: Icons.receipt_long,
                label: "New Booking",
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.topToBottom,
                      child: const CreateTaskPage(),
                    ),
                  );
                },
              ),
              QuickLinkWidget(
                icon: Icons.money_off,
                label: "Consumer Booking",
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.topToBottom,
                      child: const ConsumerTaskPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              QuickLinkWidget(
                icon: Icons.done_all,
                label: "Finished Booking",
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.topToBottom,
                      child: CreateFinishedTaskPage(),
                    ),
                  );
                },
              ),
              QuickLinkWidget(
                icon: Icons.payment,
                label: "Payment-In",
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.topToBottom,
                      child: const PaymentInPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Previous Transactions",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const PreviousTransactionsPage(),
                    ),
                  );
                },
                child: Text(
                  "History",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: CustomRefreshIndicator(
              onRefresh: () async {
                try {
                  debugPrint("Refresh started");
                  await generalController.fetchCombinedList();
                  debugPrint("Refresh completed");
                } catch (e) {
                  debugPrint("Refresh failed: $e");
                  Get.snackbar("Error", "Failed to refresh transactions.");
                }
              },
              onStateChanged: (state) {
                debugPrint("Refresh state: $state");
              },
              builder: (
                BuildContext context,
                Widget child,
                IndicatorController indicatorController,
              ) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    if (indicatorController.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                    Transform.translate(
                      offset: Offset(0, indicatorController.value * 100),
                      child: child,
                    ),
                  ],
                );
              },
              child: Obx(() {
                final combinedList = generalController.combinedList;

                if (combinedList.isEmpty) {
                  return const Center(child: Text('No bookings found.'));
                }

                return ListView.builder(
                  itemCount: combinedList.length,
                  itemBuilder: (context, index) {
                    final item = combinedList[index];
                    final status =
                        item is ConsumerModel
                            ? 'Consumer'
                            : item is PaymentInModel
                            ? 'Payment-In'
                            : 'EMW';

                    return TransactionListTileWidget(
                      title:
                          item is ConsumerModel
                              ? item.partyName
                              : item is PaymentInModel
                              ? item.customerName
                              : (item as EMWBooking).partyName,
                      startdate:
                          item is ConsumerModel
                              ? item.workDate.toString().split(' ')[0]
                              : item is PaymentInModel
                              ? item.date.toString().split(' ')[0]
                              : item.startDate.toString().split(' ')[0],
                      enddate:
                          item is ConsumerModel
                              ? ''
                              : item is PaymentInModel
                              ? ''
                              : item.endDate.toString().split(' ')[0],
                      status: status,
                      total:
                          item is ConsumerModel
                              ? '${item.netAmount ?? 0} Rs'
                              : item is PaymentInModel
                              ? '${item.receivedAmount} Rs'
                              : '${item.netAmount ?? 0} Rs',
                      onTap: () {
                        if (item is ConsumerModel) {
                          consumerOnTap(context, item);
                        } else if (item is PaymentInModel) {
                          paymentInOnTap(context, item);
                        } else {
                          emwOnTap(context, item);
                        }
                      },
                      pay: () {
                        if (item is ConsumerModel) {
                          consumerPay(item, organizationController);
                        } else if (item is PaymentInModel) {
                          paymentInPay(item, organizationController);
                        } else {
                          // emwPay(item, false, organizationController);
                          emwPayQuick(item, organizationController);
                        }
                      },
                      share: () {
                        if (item is ConsumerModel) {
                          consumerShare(
                            item,
                            organizationController,
                            partyController,
                          );
                        } else if (item is PaymentInModel) {
                          paymentInShare(
                            item,
                            organizationController,
                            partyController,
                          );
                        } else {
                          emwShare(
                            item,
                            false,
                            organizationController,
                            partyController,
                          );
                        }
                      },
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void paymentInOnTap(BuildContext context, PaymentInModel item) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: PaymentInPage(paymentInModel: item),
      ),
    );
  }

  void paymentInPay(
    PaymentInModel item,
    OrganizationController organizationController,
  ) async {
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

  void paymentInShare(
    PaymentInModel item,
    OrganizationController organizationController,
    PartyController partyController,
  ) async {
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

  void emwShare(
    dynamic item,
    bool isConsumer,
    OrganizationController organizationController,
    PartyController partyController,
  ) async {
    final organization = await organizationController.fetchOrgById(
      item.organizationId,
    );
    final party = await partyController.fetchPartyById(item.partyId);

    final Map<String, dynamic> invoiceData = {
      'organizationName': organization?['orgName'] ?? 'Company Name',
      'organizationAddress': organization?['orgAddress'] ?? 'orgAddress',
      'organizationPhone': organization?['phoneNumber'] ?? 'Phone Number',
      'upiId': organization?['orgUPI'] ?? 'orgUPI',
      'bankAccountName':
          organization?['accountHolderName'] ?? 'Account Holder Name',
      'bankAccountNumber': organization?['accountNumber'] ?? 'Account Number',
      'bankIfscCode': organization?['accountIFSC'] ?? 'Account IFSC',
      'invoiceNumber': item.id,
      'clientName': party?['partyName'] ?? 'Client Name',
      'vehicleName': isConsumer ? '' : item.vehicleName,
      'startDate': isConsumer ? item.workDate : item.startDate,
      'endDate': isConsumer ? '' : item.endDate,
      'workLocation': item.workLocation,
      'notes': isConsumer ? '' : item.notes,
      'rentType': isConsumer ? '' : item.rentType,
      'rate': isConsumer ? '' : item.rate,
      'quantity': isConsumer ? '' : item.quantity,
      'startMeter': isConsumer ? '' : item.startMeter,
      'endMeter': isConsumer ? '' : item.endMeter,
      'shiftingVehicle': item.shiftingVehicle,
      'shiftingVehicleCharge': item.shiftingVehicleCharge,
      'operatorBata': isConsumer ? '' : item.operatorBata,
      'taxPercent': item.tax,
      'discount': item.discount,
      'discountType': (item.discountType == '%') ? 'Percentage' : 'Flat',
      'amountDeposited': isConsumer ? '' : item.amountDeposited,
      'amountPaid': item.amountPaid,
      'netAmount': item.netAmount,
    };

    Get.dialog(const Center(child: CircularProgressIndicator()));
    await PdfEarthMovingInvoice.generateAndSharePdf(
      invoiceData: invoiceData,
      logo: organization?['orgLogo'] ?? 'orgLogo',
      clientLogo: party?['pfp'] ?? 'Logo',
    );
    Get.back();
  }

  void emwPayQuick(
    dynamic item,
    OrganizationController organizationController,
  ) async {
    final organization = await organizationController.fetchOrgById(
      item.organizationId,
    );
    final upiId = organization?['orgUPI'] ?? '';

    // Simple message clients can't mess up
    final quickMessage = '''
Pay ₹${(item.netAmount ?? 0).toStringAsFixed(2)} to:

UPI: $upiId

Invoice: ${item.id}
${organization?['orgName']}
''';

    await Share.share(quickMessage);
  }

  void emwPay(
    dynamic item,
    bool isConsumer,
    OrganizationController organizationController,
  ) async {
    final organization = await organizationController.fetchOrgById(
      isConsumer ? item.organizationId : item.organizationId,
    );

    final upiData =
        'upi://pay'
        '?pa=${Uri.encodeComponent(organization?['orgUPI'] ?? '')}'
        '&pn=${Uri.encodeComponent(organization?['orgName'] ?? 'Unknown Organization')}'
        '&am=${(item.netAmount ?? 0).toStringAsFixed(2)}'
        '&cu=INR';

    await Share.share(
      'Invoice for: ${isConsumer ? item.partyName : item.partyName}\n'
      'Invoice No: ${isConsumer ? item.id : item.id}\n'
      'Organization: ${organization?['orgName'] ?? 'Org Name'}\n'
      'UPI Payment Link:\n$upiData\n'
      'Amount: ${item.netAmount} Rs\n',
    );
  }

  void emwOnTap(BuildContext context, dynamic item) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: CreateFinishedTaskPage(booking: item),
      ),
    );
  }

  void consumerShare(
    dynamic item,
    OrganizationController organizationController,
    PartyController partyController,
  ) async {
    final organization = await organizationController.fetchOrgById(
      item.organizationId,
    );
    final party = await partyController.fetchPartyById(item.partyId);

    final Map<String, dynamic> invoiceData = {
      'organizationName': organization?['orgName'] ?? 'Company Name',
      'organizationAddress': organization?['orgAddress'] ?? 'orgAddress',
      'organizationPhone': organization?['phoneNumber'] ?? 'Phone Number',
      'upiId': organization?['orgUPI'] ?? 'orgUPI',
      'invoiceNumber': item.id,
      'clientName': party?['name'] ?? 'Client Name',
      'workDate': item.workDate,
      'workLocation': item.workLocation,
      'items': item.items,
      'shiftingVehicle': item.shiftingVehicle,
      'shiftingVehicleCharge': item.shiftingVehicleCharge,
      'taxPercent': item.tax,
      'discount': item.discount,
      'discountType': (item.discountType == '%') ? 'Percentage' : 'Flat',
      'amountPaid': item.amountPaid,
      'netAmount': item.netAmount,
    };

    Get.dialog(const Center(child: CircularProgressIndicator()));
    await PdfConsumerInvoice.generateAndSharePdf(
      invoiceData: invoiceData,
      logo: organization?['orgLogo'],
      clientLogo: party?['pfp'],
    );
    Get.back();
  }

  void consumerPay(
    dynamic item,
    OrganizationController organizationController,
  ) async {
    final organization = await organizationController.fetchOrgById(
      item.organizationId,
    );

    final upiData =
        'upi://pay'
        '?pa=${Uri.encodeComponent(organization?['orgUPI'] ?? '')}'
        '&pn=${Uri.encodeComponent(organization?['orgName'] ?? 'Unknown Organization')}'
        '&am=${(item.netAmount ?? 0).toStringAsFixed(2)}'
        '&cu=INR';

    await Share.share(
      'Invoice for: ${item.partyName}\n'
      'Invoice No: ${item.id}\n'
      'Organization: ${organization?['orgName'] ?? 'Org Name'}\n'
      'UPI Payment Link:\n$upiData\n'
      'Amount: ${item.netAmount} Rs\n',
    );
  }

  void consumerOnTap(BuildContext context, dynamic item) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: ConsumerTaskPage(consumerModel: item),
      ),
    );
  }
}
