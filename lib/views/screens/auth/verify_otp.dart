import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:tellus/services/auth/otp_verfication_controller.dart';
import 'package:tellus/views/widgets/submit_button.dart';
import '../../widgets/pinput_widget.dart';

class OtpPage extends StatelessWidget {
  OtpPage({super.key});

  final OtpVerificationController otpVerificationController = Get.put(
    OtpVerificationController(),
  );
  final TextEditingController pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(26.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              width: MediaQuery.of(context).size.height * 0.9,
              child: Center(
                child: Column(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.height * 0.4,
                      child: Lottie.asset('assets/lotties/otp.json'),
                    ),
                    Text(
                      'VERIFY OTP',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'We send a verification code to your number, Enter the code below',
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.center,
                    ),
                    PinputInput(pinController: pinController, isComplete: true),
                    Obx(
                      () => SubmitButton(
                        text: "Verify",
                        isLoading: otpVerificationController.isLoading.value,
                        onTap: () async {
                          otpVerificationController.otp.value =
                              pinController.text;
                          try {
                            otpVerificationController.verifyOTP();
                          } catch (e) {
                            Get.snackbar('Error', e.toString());
                          }
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap:() => otpVerificationController.resendOTP(),
                      child: Text(
                        'Didn\'t receive the code? Resend',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
