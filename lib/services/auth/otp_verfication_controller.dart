import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tellus/services/auth/auth_gate.dart';
import 'package:tellus/services/auth/auth_service.dart';
import 'package:tellus/services/auth/login_controller.dart';
import 'package:tellus/services/auth/organization_controller.dart';

class OtpVerificationController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final box = GetStorage();

  RxString otp = ''.obs;
  RxBool isLoading = false.obs;

  String phoneNumber = Get.find<LoginController>().phoneNumber.value;
  String orgId = Get.find<OrganizationController>().selectedOrg.value;
  String isValid = '';

  Future<void> verifyOTP() async {
    isLoading.value = true;

    try {
      // Ensure orgId, userId, and role are set before proceeding
      isValid = await authService.validateUser(orgId, phoneNumber) ?? '';

      if (isValid.isEmpty) {
        Get.snackbar('Error', 'Invalid OTP or phone number.');
        throw Exception('Invalid OTP or phone number.');
      } else {
        // Navigate to the appropriate module based on user role
        await AuthGate.checkRoleAndNavigate();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      print('Error verifyOTP: $e');
      print('Error verifyOTP: values in orgId:$orgId, phoneNumber:$phoneNumber');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOTP() async {
    isLoading.value = true;
    try {
      await authService.resendOTP(phoneNumber);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
    isLoading.value = false;
  }
}
