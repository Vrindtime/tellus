import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/views/screens/accountant/manage_expense.dart';
import 'package:tellus/views/screens/accountant/party_details_page.dart';
import 'package:tellus/views/screens/accountant/report_page.dart';
import 'package:tellus/views/screens/admin/create_user_page.dart';
import 'package:tellus/views/screens/common/quick_link_widget.dart';
import 'package:get/get.dart';
import 'package:tellus/services/admin/admin_controller.dart';
import 'package:tellus/views/widgets/extras/custom_list_tile_widget.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminUserController controller = Get.put(AdminUserController());

  @override
  void initState() {
    super.initState();
    // Fetch users when the page is initialized
    controller.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quick Links", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                QuickLinkWidget(
                  icon: Icons.person_add,
                  label: "Create User",
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeftJoined,
                        child: CreateUserEmployeePage(),
                        childCurrent: const AdminDashboardPage(),
                      ),
                    );
                  },
                ),
                QuickLinkWidget(
                  icon: Icons.money_off,
                  label: "Manage Expenses",
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeftJoined,
                        child: ExpenseManagementPage(),
                        childCurrent: const AdminDashboardPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                QuickLinkWidget(
                  icon: Icons.business_center,
                  label: "Manage Party",
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeftJoined,
                        child: const PartyDetailsPage(),
                        childCurrent: const AdminDashboardPage(),
                      ),
                    );
                  },
                ),
                QuickLinkWidget(
                  icon: Icons.price_check,
                  label: "Revenue Report",
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeftJoined,
                        child: ReportPage(),
                        childCurrent: const AdminDashboardPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Team Members',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: CustomRefreshIndicator(
                onRefresh: () async {
                  await controller.fetchUsers();
                },
                onStateChanged: (IndicatorStateChange change) {
                  if (change.didChange(
                    from: IndicatorState.dragging,
                    to: IndicatorState.armed,
                  )) {
                    debugPrint('Indicator armed');
                  } else if (change.didChange(to: IndicatorState.idle)) {
                    debugPrint('Indicator idle');
                  } else if (change.didChange(to: IndicatorState.loading)) {
                    debugPrint('Indicator loading');
                  }
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
                  final users = controller.users;
                  if (users.isEmpty && !controller.isLoading.value) {
                    controller.fetchUsers();
                    return const Center(child: Text('No users found'));
                  }
                  if (controller.isLoading.value && users.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final userId = users[index]['id'];
                      final username = users[index]['name'];
                      final role = users[index]['role'];
                      final phone = users[index]['phoneNumber'];
                      final avatarIcon = users[index]['pfp'];
                      final location = users[index]['location'];
                      // debugPrint('--- User Name from Admin DashBaord: $username');
                      // debugPrint('--- User ID from Admin DashBaord: $userId');
                      // debugPrint('--- User phone from Admin DashBaord: $phone');
                      // debugPrint('\n');
                      return UserListTileWidget(
                        title: username,
                        subtitle: role,
                        avatarUrl: avatarIcon,
                        onTap: () {
                          final user = users[index];
                          if (user.isNotEmpty) {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeftWithFade,
                                child: CreateUserEmployeePage(
                                  isEdit: true,
                                  userId:userId,
                                  // name: username,
                                  // phone: phone,
                                  // role: role,
                                  // location: location,
                                ),
                              ),
                            );
                          } else {
                            Get.snackbar('Error', 'Invalid user data', snackPosition: SnackPosition.TOP);
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
      ),
    );
  }
}
