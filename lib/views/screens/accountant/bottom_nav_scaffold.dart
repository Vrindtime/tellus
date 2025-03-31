// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/views/screens/accountant/billing_page.dart';
import 'package:tellus/views/screens/accountant/party_details_page.dart';
import 'package:tellus/views/screens/accountant/settings_page.dart';
import 'package:tellus/views/screens/common/common_page_name.dart';
import 'package:tellus/views/screens/common/notification_page.dart';

class AccountantBottomNavigationMenuPage extends StatefulWidget {
  const AccountantBottomNavigationMenuPage({super.key});
  @override
  State<AccountantBottomNavigationMenuPage> createState() =>
      _AccountantBottomNavigationMenuPageState();
}

class _AccountantBottomNavigationMenuPageState
    extends State<AccountantBottomNavigationMenuPage> {
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Accountant",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.topToBottom,
                  child: const NotificationPage(),
                ),
              );
            },
            icon: Icon(
              Icons.notifications,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body:
          [
            // CommonPage(pagename: "Finance Dashboard"),
            // CommonPage(pagename: "Sales & Billing\n(Invoices, Returns, Delivery Challans)",),
            BillingPage(),
            PartyDetailsPage(),
            AccountSettingPage()
          ][_currentPage],
      bottomNavigationBar: DotCurvedBottomNav(
        scrollController: _scrollController,
        hideOnScroll: true,
        indicatorColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.ease,
        // margin: const EdgeInsets.all(0),
        selectedIndex: _currentPage,
        indicatorSize: 5,
        borderRadius: 10,
        height: 60,
        onTap: (index) {
          setState(() => _currentPage = index);
        },
        items: [
          // Icon(
          //   Icons.home,
          //   color:
          //       _currentPage == 0
          //           ? Theme.of(context).colorScheme.onSurface
          //           : Colors.white.withOpacity(0.4),
          // ),
          Icon(
            Icons.home,
            color:
                _currentPage == 0
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.white.withOpacity(0.4),
          ),
          Icon(
            Icons.person,
            color:
                _currentPage == 1
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.white.withOpacity(0.4),
          ),
          Icon(
            Icons.settings,
            color:
                _currentPage == 2
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.white.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}
