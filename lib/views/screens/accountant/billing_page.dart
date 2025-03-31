import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/views/screens/accountant/payment_in_page.dart';
import 'package:tellus/views/screens/accountant/quotation_page.dart';
import 'package:tellus/views/screens/accountant/sales_invoice_page.dart';
import 'package:tellus/views/screens/common/common_page_name.dart';
import 'package:tellus/views/widgets/list_tile_widget.dart';
import 'package:tellus/views/screens/common/quick_link_widget.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> transactions = List.generate(
      10,
      (index) => {
        'title': "Transaction #${index + 1}",
        'page': CommonPage(pagename: "Transaction #${index + 1}"),
      },
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Links",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              QuickLinkWidget(
                icon: Icons.receipt_long,
                label: "Quotation",
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.topToBottom,
                      child: const QuotationPage(),
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
                icon: Icons.inventory,
                label: "Sale Invoice",
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
              QuickLinkWidget(
                icon: Icons.money_off,
                label: "Expenses",
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.topToBottom,
                      child: const CommonPage(pagename: "Expenses"),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Previous Transactions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListTileWidget(items: transactions),
          ),
        ],
      ),
    );
  }
}