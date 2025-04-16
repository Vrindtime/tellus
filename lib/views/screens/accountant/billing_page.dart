import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/services/accountant/emw_controller.dart';
import 'package:tellus/views/screens/accountant/payment_in_page.dart';
import 'package:tellus/views/screens/accountant/quotation_page.dart';
import 'package:tellus/views/screens/accountant/sales_invoice_page.dart';
import 'package:tellus/views/screens/admin/task/assign_task_page.dart';
import 'package:tellus/views/screens/admin/task/finished_task_page.dart';
import 'package:tellus/views/screens/admin/task/new_task_page.dart';
import 'package:tellus/views/screens/common/common_page_name.dart';
import 'package:tellus/views/widgets/extras/custom_list_tile_widget.dart';
import 'package:tellus/views/screens/common/quick_link_widget.dart';
import 'package:tellus/views/widgets/extras/transcation_list_tile_widget.dart';

class BillingPage extends StatelessWidget {
  BillingPage({super.key});
  final EMWBookingController _emwBookingController = Get.put(
    EMWBookingController(),
  );
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 0.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick Links",
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
                  icon: Icons.money_off,
                  label: "Expenses Sales",
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.topToBottom,
                        child: const SalesInvoicePage(),
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
                  child: Text(
                    "See More >",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const AssignTaskPage(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Obx(
              () => ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _emwBookingController.bookings.length,
                itemBuilder: (context, index) {
                  final booking = _emwBookingController.bookings[index];
                  return TransactionListTileWidget(
                    title: booking.partyId,
                    startdate: booking.startDate.toString().split(' ')[0] ,
                    enddate: booking.endDate.toString().split(' ')[0],
                    status: booking.status,
                    total: '${booking.netAmount} Rs',
                    onTap: () {
                      // Optionally, show invoice details
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: CreateFinishedTaskPage(
                            booking:booking
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
