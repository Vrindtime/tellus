import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:tellus/services/auth/login_controller.dart';
import 'package:tellus/services/admin/organization_controller.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/phone_input_widget.dart';
import 'package:tellus/views/widgets/submit_button.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController loginController = Get.put(LoginController());

  final TextEditingController phoneController = TextEditingController();

  String selectedCountryCode = '+91';

  List<String> countryCodeList = ['+91', '+1', '+971', '+968', '+44', '+49'];

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
              // Expanded(child:
              CustomDropdown(
                label: 'Country Code',
                selectedValue: selectedCountryCode,
                items: countryCodeList,
                onChanged: (value) {
                  setState(() {
                    selectedCountryCode = value!;
                  });
                },
              ),
              PhoneValidInput(inputController: phoneController),
              Obx(
                () => SubmitButton(
                  text: 'Send OTP',
                  isLoading: loginController.isLoading.value,
                  onTap: () {
                    // TODO: Add more country codes
                    final raw = phoneController.text.trim();
                    if (raw.isEmpty) {
                      Get.snackbar('Error', 'Please enter a phone number');
                      return;
                    }
                    // Basic numeric validation (10+ digits) before prefixing
                    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
                    if (digitsOnly.length < 10) {
                      Get.snackbar(
                        'Error',
                        'Please enter a valid phone number',
                      );
                      return;
                    }
                    // Build full number and let controller/service normalize further
                    loginController.phoneNumber.value =
                        '$selectedCountryCode$digitsOnly';
                    String selectedOrg =
                        Get.find<OrganizationController>().selectedOrg.value;
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
