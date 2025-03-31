import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:tellus/services/auth/auth_service.dart';
import 'package:tellus/views/screens/accountant/bottom_nav_scaffold.dart';
import 'package:tellus/views/screens/admin/bottom_nav_scaffold.dart';
import 'package:tellus/views/screens/auth/organization.dart';
import 'package:tellus/views/screens/driver/bottom_nav_scaffold.dart';

class AuthLoadingPage extends StatefulWidget {
  @override
  State<AuthLoadingPage> createState() => _AuthLoadingPageState();
}

class _AuthLoadingPageState extends State<AuthLoadingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthGate.checkRoleAndNavigate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/tellus_logo.png',
          width: MediaQuery.of(context).size.width * 0.8,
        ), // Show loading indicator
      ),
    );
  }
}


class AuthGate {
  static Future<void> checkRoleAndNavigate() async {
    try {
      final authService = Get.find<AuthService>();

      if (authService.isLoggedIn() == false) {
        Get.offAll(() => OrganizationPage());
        throw Exception('User is not logged in');
      }

      String currentRole = authService.role.value;

      switch (currentRole) {
        case 'admin':
          Get.offAll(() => AdminBottomNavigationMenuPage());
          break;
        case 'accountant':
          Get.offAll(() => AccountantBottomNavigationMenuPage());
          break;
        case 'driver':
          Get.offAll(() => DriverBottomNavigationMenuPage());
          break;
        default:
          Get.offAll(() => OrganizationPage());
          break;
      }
    } catch (e) {
      print('Error in checkRoleAndNavigate: $e');
    }
  }
}
