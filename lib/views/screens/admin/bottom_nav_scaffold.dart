// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/views/screens/accountant/billing_page.dart';
import 'package:tellus/views/screens/admin/admin_dashboard_page.dart';
import 'package:tellus/views/screens/admin/admin_setting_page.dart';
import 'package:tellus/views/screens/admin/vehicle_managment_page.dart';
import 'package:tellus/views/screens/common/notification_page.dart';

class AdminBottomNavigationMenuPage extends StatefulWidget {
  const AdminBottomNavigationMenuPage({super.key});
  @override
  State<AdminBottomNavigationMenuPage> createState() =>
      AdminBottomNavigationMenuPageState();
}

class AdminBottomNavigationMenuPageState
    extends State<AdminBottomNavigationMenuPage> {
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Admin", style: Theme.of(context).textTheme.titleLarge),
            Text(
              "This is a demo app and will be live\n as a subscription-based app on 21st May 2025",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 10
              ),
            ),
          ],
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
            BillingPage(),
            VehicleManagementPage(),
            AdminDashboardPage(),
            AdminSettingPage(),
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
          Icon(
            Icons.home,
            color:
                _currentPage == 0
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.white.withOpacity(0.4),
          ),
          Icon(
            Icons.car_rental,
            color:
                _currentPage == 1
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.white.withOpacity(0.4),
          ),
          Icon(
            Icons.person,
            color:
                _currentPage == 2
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.white.withOpacity(0.4),
          ),
          Icon(
            Icons.settings,
            color:
                _currentPage == 3
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.white.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}
