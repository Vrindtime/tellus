// Define your routes using GetPage
import 'package:get/get.dart';
import 'package:tellus/services/auth/auth_gate.dart';
import 'package:tellus/views/screens/accountant/bottom_nav_scaffold.dart';
import 'package:tellus/views/screens/admin/bottom_nav_scaffold.dart';
import 'package:tellus/views/screens/auth/login_page.dart';
import 'package:tellus/views/screens/auth/organization.dart';
import 'package:tellus/views/screens/auth/verify_otp.dart';
import 'package:tellus/views/screens/driver/bottom_nav_scaffold.dart';

List<GetPage> getPages = [
  GetPage(
    name: '/gate',
    page: () => AuthLoadingPage(),
  ),
  GetPage(
    name: '/login',
    page: () => LoginPage(),
  ),
  GetPage(
    name: '/otp',
    page: () => OtpPage(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 200),
  ),
  GetPage(
    name: '/organization',
    page: () => OrganizationPage(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 200),
  ),
  GetPage(
    name: '/adminDashboard',
    page: () => const AdminBottomNavigationMenuPage(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 200),
  ),
  GetPage(
    name: '/accountantDashboard',
    page: () => const AccountantBottomNavigationMenuPage(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 200),
  ),
  GetPage(
    name: '/driverDashboard',
    page: () => const DriverBottomNavigationMenuPage(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 200),
  ),
];