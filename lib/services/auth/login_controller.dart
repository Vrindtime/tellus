import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tellus/services/auth/auth_service.dart';

class LoginController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  RxString phoneNumber = ''.obs;
  RxBool isLoading = false.obs;
  RxString fetchedUserId = ''.obs;
  // RxString? selectedOrg = Get.find<OrganizationController>().selectedOrg;

  String normalizeWithDefault(String raw) {
    return authService.normalizePhoneNumber(raw, defaultCountryCode: '+91');
  }

  String removeCountryCode(String phone) {
    // Check if the phone number starts with '+91'
    if (phone.startsWith('+91')) {
      // Remove the first 3 characters ('+91') and return the rest
      return phone.substring(3);
    }
    // Return the original phone number if it doesn't start with '+91'
    return phone;
  }

  Future<void> sendOTP(String selectedOrg) async {
    isLoading.value = true;

    /// The OTP is send after the app makes sures that the user exists in the system
    try {
      final normalizedForLookup = normalizeWithDefault(phoneNumber.value);
      String? fetchedUserId = await authService.validatePhoneNumber(
        selectedOrg,
        normalizedForLookup,
      );
      if (fetchedUserId != null) {
        try {
          // to send OTP to the phone number
          // String phoneNumberWithoutCountryCode = removeCountryCode(
          //   normalizedForLookup,
          // );
          bool otpSent = await authService.createPhoneSession(
            fetchedUserId,
            normalizedForLookup,
          );

          if (otpSent) {
            // Store the fetched user ID in the authService
            authService.userId.value = fetchedUserId;
            Get.snackbar('Success', 'OTP sent to $phoneNumber');
            Get.toNamed('/otp');
          } else {
            Get.snackbar('Error', 'Failed to send OTP');
            debugPrint('Send OTP Failed: OTP sending unsuccessful');
          }
        } catch (e) {
          Get.snackbar('Error', e.toString());
          debugPrint('Send OTP Failed: $e');
        }
      } else {
        Get.snackbar('Error', 'Organization not found that matches this phone');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      debugPrint('----- Error: $e -----');
    }
    isLoading.value = false;
  }
}
