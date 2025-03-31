import 'package:flutter/material.dart';
import 'package:tellus/views/screens/driver/settings/profile_settings_page.dart';
import 'package:tellus/views/screens/driver/settings/vehicle_settings_page.dart';
import 'package:tellus/views/widgets/list_tile_widget.dart';

class DriverSettingPage extends StatelessWidget {
  const DriverSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTileWidget(
        items: [
          {'title': "Profile Settings", "page": DriverProfileSettingsPage()},
          {'title': "Vehicle Settings", "page": VehicleSettingsPage()},
        ],
      ),
    );
  }
}
