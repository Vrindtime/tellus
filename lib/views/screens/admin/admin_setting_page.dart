import 'package:flutter/material.dart';
import 'package:tellus/views/screens/accountant/bottom_nav_scaffold.dart';
import 'package:tellus/views/screens/admin/organization_edit_page.dart';
import 'package:tellus/views/screens/common/profile_settings_page.dart';
import 'package:tellus/views/screens/common/subscription_page.dart';
import 'package:tellus/views/screens/driver/bottom_nav_scaffold.dart';
import 'package:tellus/views/widgets/list_tile_widget.dart';

class AdminSettingPage extends StatelessWidget {
  const AdminSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTileWidget(
        items: [
          {'title': "Profile Settings", "page": AdminProfileSettingsPage()},
          {'title': "Organization Settings", "page": OrganizationEditPage()},
          {'title': "Subscription Settings", "page": SubscriptionPage()},
          // {'title': "Accountant View", "page": AccountantBottomNavigationMenuPage()},
          // {'title': "Driver View", "page": DriverBottomNavigationMenuPage()},
          {'title': "Logout", "page": Placeholder()},
        ],
      ),
    );
  }
}
