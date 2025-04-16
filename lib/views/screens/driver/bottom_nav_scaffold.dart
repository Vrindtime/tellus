// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/views/screens/common/common_page_name.dart';
import 'package:tellus/views/screens/driver/settings/settings_page.dart';
import 'package:tellus/views/widgets/list_tile_widget.dart';
import 'package:tellus/views/screens/common/notification_page.dart';
import 'package:tellus/views/screens/driver/settings/profile_settings_page.dart';
import 'package:tellus/views/screens/driver/settings/vehicle_settings_page.dart';

class DriverBottomNavigationMenuPage extends StatefulWidget {
  const DriverBottomNavigationMenuPage({super.key});
  @override
  State<DriverBottomNavigationMenuPage> createState() =>
      _DriverBottomNavigationMenuPageState();
}

class _DriverBottomNavigationMenuPageState
    extends State<DriverBottomNavigationMenuPage> {
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text("Driver", style: Theme.of(context).textTheme.titleMedium),
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
            CommonPage(pagename: "Driver Dashboard"),
            CommonPage(
              pagename:
                  "Proof Submission\n(ODO, Fuel Receipt, Maintenance Reports)",
            ),
            // CommonPage(pagename: "Route\n&\nAssignment Details"),
            DriverSettingPage()
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
            Icons.file_copy,
            color:
                _currentPage == 1
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.white.withOpacity(0.4),
          ),
          // Icon(
          //   Icons.map,
          //   color:
          //       _currentPage == 2
          //           ? Theme.of(context).colorScheme.onSurface
          //           : Colors.white.withOpacity(0.4),
          // ),
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
