import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/services/vehicle/vehicle_controller.dart';
import 'package:tellus/views/screens/driver/settings/vehicle_settings_page.dart';
import 'package:tellus/views/widgets/extras/custom_list_tile_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:tellus/views/widgets/list_tile_widget.dart';

class VehicleManagementPage extends StatelessWidget {
  final VehicleController vehicleController = Get.put(VehicleController());

  VehicleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75, 
                  child: CustomTextInput(label: 'Search by Registration Number', 
                  controller: vehicleController.controller, 
                  icon: Icons.search,
                  onChanged: (value) {
                    vehicleController.filterVehicles(value?? '');
                  }),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: VehicleSettingsPage(),
                      ),
                    );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: CustomRefreshIndicator(
                onRefresh: () async {
                  await vehicleController.onRefresh();
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
                child: Obx(
                  () {
                    final vehicles = vehicleController.filteredVehicles;
                    if (vehicles.isEmpty) {
                      return const Center(child: Text('No vehicles found'));
                    }
                    return ListView.builder(
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return UserListTileWidget(
                          title: vehicle.registrationNumber,
                          subtitle: vehicle.vehicleType ?? 'Unknown Model',
                          avatarIcon: 'IMG',
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: VehicleSettingsPage(vehicle: vehicle),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
