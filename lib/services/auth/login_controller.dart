import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tellus/services/auth/auth_service.dart';

class LoginController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  
  RxString phoneNumber = ''.obs;
  RxBool isLoading = false.obs;
  // RxString? selectedOrg = Get.find<OrganizationController>().selectedOrg;

  Future<void> sendOTP(String selectedOrg) async {
    isLoading.value = true;
    try {
      
      String? fetchedUserId = await authService.validatePhoneNumber(
          selectedOrg, phoneNumber.value);
      if (fetchedUserId != null) {
        // Store the fetched user ID in the authService
        authService.userId.value = fetchedUserId;
        // await authService.createPhoneSession(fetchedOrgId,phoneNumber.value);

        Get.snackbar('Success', 'OTP sent to $phoneNumber');
        Get.toNamed('/otp');
      } else {
        Get.snackbar('Error', 'Organization not found');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      debugPrint('----- Error: $e -----');
    }
    isLoading.value = false;
  }
}