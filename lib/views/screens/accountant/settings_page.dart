import 'package:flutter/material.dart';
import 'package:tellus/views/screens/accountant/accoutant_profile_settings_page.dart';
import 'package:tellus/views/widgets/list_tile_widget.dart';

class AccountSettingPage extends StatelessWidget {
  const AccountSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:  8.0),
      child: ListTileWidget(
        items: [
          {
            'title': "Profile Settings",
            "page": AccountantProfileSettingsPage(),
          },
          {
            'title': "Logout",
            "page": Placeholder(),
          },
        ],
      ),
    );
  }
}
