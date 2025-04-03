import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tellus/core/id.dart';
import 'package:tellus/services/auth/otp_verfication_controller.dart';

class AuthService extends GetxService {
  final box = GetStorage();

  late Client client;
  late Account account;
  late Databases databases;

  RxString authToken =''.obs;
  RxString orgId = ''.obs;
  RxString userId = ''.obs;
  RxString role = ''.obs;

  Future<AuthService> init() async {
    authToken.value = CId.authToken;
    try {
      client = Get.find<Client>();
      account = Get.find<Account>();
      databases = Get.find<Databases>();
    } catch (e) {
      debugPrint('AuthService init failed: $e');
      rethrow;
    }
    userId.value = box.read('userId') ?? '';
    orgId.value = box.read('orgId') ?? '';
    role.value = box.read('role') ?? '';
    return this;
  }

  bool isLoggedIn() {
    if (orgId.value.isEmpty || userId.value.isEmpty || role.value.isEmpty) {
      debugPrint(
        'isLoggedIn() MSG: Login details are incomplete. Please ensure orgId, userId, and role are set.',
      );
      return false;
    } else {
      debugPrint('isLoggedIn() MSG: Login details are complete');
      return true;
    }
  }

  Future<void> setUserId(String newUserId) async {
    userId.value = newUserId;
    await box.write('userId', newUserId);
  }

  Future<void> setRole(String newRole) async {
    role.value = newRole;
    await box.write('role', newRole);
  }

  Future<void> setOrgId(String newOrgId) async {
    orgId.value = newOrgId;
    await box.write('orgId', newOrgId);
  }

  void saveToMemory(String key, dynamic value) {
    box.write(key, value);
  }

  dynamic getFromMemory(String key) {
    return box.read(key);
  }

  Future<void> clearCache() async {
    await box.erase();
  }

  Future<String?> validatePhoneNumber(
    String orgName,
    String phoneNumber,
  ) async {
    debugPrint('----- org value: $orgName in validatePhoneNumber()-----');
    debugPrint('----- phone value: $phoneNumber in validatePhoneNumber()-----');
    try {
      final response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        queries: [
          Query.equal('organizationId', orgName),
          Query.equal('phoneNumber', phoneNumber),
        ],
      );
      debugPrint(
        '----- User response found: ${response.documents.isNotEmpty} -----',
      );
      if (response.documents.isNotEmpty) {
        final userId = response.documents.first;

        if (userId.$id.isNotEmpty) {
          debugPrint('----- User Found: ${userId.$id} -----');
          createPhoneSession(userId.$id, phoneNumber);
          return userId.$id;
        } else {
          debugPrint('----- phoneNumber is null -----');
        }
      }
      return null;
    } catch (e) {
      debugPrint(
        '----- validatePhoneNumber() Error validating phone number: $e ----',
      );
      return null;
    }
  }

  Future<String?> validateUser(String orgId, String phoneNumber) async {
    debugPrint('----- orgId: $orgId in validateUser()-----');
    debugPrint('----- phoneNumber: $phoneNumber in validateUser()-----');
    try {
      final response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        queries: [
          Query.equal('organizationId', orgId),
          Query.equal('phoneNumber', phoneNumber),
        ],
      );

      if (response.documents.isNotEmpty) {
        final user = response.documents.first;
        debugPrint('----- User found: ${user.data} -----');

        // Set user details in AuthService
        await setUserId(user.$id);
        await setRole(user.data['role']);
        await setOrgId(orgId);

        return user.$id; // Return the user ID
      } else {
        debugPrint(
          '----- No user found matching the organization and phone number. validateUser()',
        );
        debugPrint(
          '----- validateUser() values ; \nresponse: No documents found -----',
        );
        debugPrint(
          '----- Values in cache: ----- userId:${box.read('userId')} ----- orgId: ${box.read('orgId')} ---- role: ${box.read('role')}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('----- validateUser() Error validating user: $e ----');
      return null;
    }
  }

  Future<String> generateToken() async {
    final url = 'https://cpaas.messagecentral.com/auth/v1/authentication/token';
    String password = CId.messageCentralPassword;
    String base64Encoded = base64Encode(utf8.encode(password));
    debugPrint('Base64 Encoded Password: $base64Encoded');
    final queryParams = {
      'customerId': 'C-63EB48296DE2413',
      'key': base64Encoded,
      'scope': 'NEW',
      'country': '91',
    };

    try {
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: queryParams),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['token'];
      } else {
        debugPrint('Failed to generate token: ${response.statusCode}');
        throw Exception('Failed to generate token');
      }
    } catch (e) {
      debugPrint('Exception generating token: $e');
      rethrow;
    }
  }

  Future<bool> createPhoneSession(String userID, String phoneNumber) async {
    OtpVerificationController otpController = Get.put(
      OtpVerificationController(),
    );
    final url = 'https://cpaas.messagecentral.com/verification/v3/send';

    final queryParams = {
      'countryCode': '91',
      'flowType': 'WHATSAPP',
      'mobileNumber': phoneNumber,
    };

    debugPrint('-----createPhoneSession()-----Auth token: ${authToken.value}');
    debugPrint('-----createPhoneSession()-----Phone Number: $phoneNumber');

    try {
      final response = await http.post(
        Uri.parse(url).replace(queryParameters: queryParams),
        headers: {'authToken': authToken.value},
      );
      debugPrint('--createPhoneSession()--Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        debugPrint('--createPhoneSession()--Response: $jsonResponse');

        if (jsonResponse['responseCode'] == 200 &&
            jsonResponse['message'] == 'SUCCESS') {
          otpController.verificationId.value =
              jsonResponse['data']['verificationId'].toString();
          debugPrint(
            "--createPhoneSession()--OTP Sent Successfully to $phoneNumber",
          );
          debugPrint(
            "--createPhoneSession()--Verification ID: ${otpController.verificationId.value}",
          );
          debugPrint(
            "--createPhoneSession()--Transaction ID: ${jsonResponse['data']['transactionId']}",
          );
          return true; // Success
        } else {
          debugPrint(
            "--createPhoneSession()--Failed to send OTP: ${jsonResponse['remark'] ?? 'Unknown error'}",
          );
          return false; // API-level failure
        }
      } else {
        debugPrint(
          "--createPhoneSession()--HTTP request failed with status: ${response.statusCode}",
        );
        debugPrint("--createPhoneSession()--Response body: ${response.body}");
        return false; // HTTP failure
      }
    } catch (e) {
      debugPrint('-----createPhoneSession()-----Exception in sending OTP: $e');
      return false; // Exception occurred
    }
  }

  /// Function to verify the user entered OTP.
  /// This first compares the OTP against our stored value and then
  /// optionally calls an account API to update the phone session.
  Future<bool> verifyOTP(String docId, String otp) async {
    debugPrint("-----verifyOTP()-----User Entered OTP: $otp");
    String authT = authToken.value;
    if (authT.isEmpty) {
      debugPrint("-----verifyOTP()-----Auth token is empty. Generating a new one.");
      authT = await generateToken();
    }

    String verificationId =
        Get.find<OtpVerificationController>().verificationId.value;
    debugPrint("-----verifyOTP()-----Verification ID: $verificationId");

    if (verificationId.isEmpty) {
      debugPrint("-----verifyOTP()-----Verification ID is empty, cannot proceed.");
      return false;
    }

    String url = 'https://cpaas.messagecentral.com/verification/v3/validateOtp';
    final queryParams = {'verificationId': verificationId, 'code': otp};

    try {
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: queryParams),
        headers: {'authToken': authT},
      );
      debugPrint("--verifyOTP()--Verify OTP Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['responseCode'] == 200 &&
            responseData['message'] == 'SUCCESS' &&
            responseData['data']['verificationStatus'] ==
                'VERIFICATION_COMPLETED') {
          debugPrint('--verifyOTP()--OTP verified successfully.');
          return true;
        } else {
          debugPrint(
            '--verifyOTP()--OTP verification failed: ${responseData['data']['errorMessage'] ?? "Unknown error"}',
          );
          return false;
        }
      } else {
        debugPrint(
          '--verifyOTP()--Failed to verify OTP. Status code: ${response.statusCode}',
        );
        debugPrint('--verifyOTP()--Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('--verifyOTP()--Exception verifying OTP: $e');
      return false;
    }
  }

  Future<void> resendOTP(String userId) async {
    try {
      await account.createPhoneToken(userId: userId, phone: userId);
    } catch (e) {
      debugPrint('Appwrite Exception: $e');
      rethrow; // rethrow the exception
    }
  }

  Future<void> logout() async {
    orgId.value = '';
    userId.value = '';
    role.value = '';
    await box.remove('userId');
    await box.remove('orgId');
    await box.remove('role');
    clearCache(); //remove everyting from the cache
    debugPrint('User logged out and cache cleared.');
  }
}
