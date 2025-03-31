import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:tellus/services/auth/login_controller.dart';
import 'package:tellus/services/auth/organization_controller.dart';
import 'package:tellus/views/widgets/phone_input_widget.dart';
import 'package:tellus/views/widgets/submit_button.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginController loginController = Get.put(LoginController());
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Center(
                child: Lottie.asset(
                  'assets/lotties/job.json',
                  width: width * 0.8,
                  height: height * 0.35,
                ),
              ),
              Text(
                "Welcome to Tellus!",
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              Text(
                "Sign in with phone number",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              PhoneValidInput(inputController: phoneController),
              Obx(
                () => SubmitButton(
                  text: 'Send OTP',
                  isLoading: loginController.isLoading.value,
                  onTap: () {
                    // TODO: Add more country codes
                    if (phoneController.text.isEmpty) {
                      Get.snackbar('Error', 'Please enter a phone number');
                      return;
                    }
                    loginController.phoneNumber.value = '+91${phoneController.text}';
                    String selectedOrg = Get.find<OrganizationController>().selectedOrg.value;
                    loginController.sendOTP(selectedOrg);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}