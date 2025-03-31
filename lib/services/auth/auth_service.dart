import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/services/auth/login_controller.dart';
import 'package:tellus/services/auth/organization_controller.dart';

class AuthService extends GetxService {
  final box = GetStorage();

  late Client client;
  late Account account;
  late Databases databases;

  RxString orgId = ''.obs;
  RxString userId = ''.obs;
  RxString role = ''.obs;

  Future<AuthService> init() async {
    client = Get.find<Client>();
    account = Get.find<Account>();
    databases = Get.find<Databases>();

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
    print('----- org value: $orgName in validatePhoneNumber()-----');
    print('----- phone value: $phoneNumber in validatePhoneNumber()-----');
    try {
      final response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        queries: [Query.equal('organizationId', orgName),Query.equal('phoneNumber', phoneNumber)],
      );
      print(
        '----- User response found: ${response.documents.isNotEmpty} -----',
      );
      if (response.documents.isNotEmpty) {
        
        final userId = response.documents.first;

        if (userId.$id.isNotEmpty) {
          print('----- User Found: ${userId.$id} -----');
          return userId.$id;
        } else {
          print('----- phoneNumber is null -----');
        }

      }
      return null;
    } catch (e) {
      print(
        '----- validatePhoneNumber() Error validating phone number: $e ----',
      );
      return null;
    }
  }

  Future<String?> validateUser(String orgId, String phoneNumber) async {
    print('----- orgId: $orgId in validateUser()-----');
    print('----- phoneNumber: $phoneNumber in validateUser()-----');
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
        print('----- User found: ${user.data} -----');

        // Set user details in AuthService
        await setUserId(user.$id);
        await setRole(user.data['role']);
        await setOrgId(orgId);

        return user.$id; // Return the user ID
      } else {
        print('----- No user found matching the organization and phone number. validateUser()');
        print('----- validateUser() values ; \nresponse: No documents found -----');
        print('----- Values in cache: ----- userId:${box.read('userId')} ----- orgId: ${box.read('orgId')} ---- role: ${box.read('role')}');
        return null;
      }
    } catch (e) {
      print('----- validateUser() Error validating user: $e ----');
      return null;
    }
  }

  // Future<void> createPhoneSession(String userID, String phoneNumber) async {
  //   try {
  //     await account.createPhoneToken(userId: userID, phone: phoneNumber);
  //   } catch (e) {
  //     print('Appwrite Exception: $e');
  //     rethrow; // rethrow the exception
  //   }
  // }

  Future<void> verifyPhoneSession(String orgId, String secret) async {
    try {
      await account.updatePhoneSession(userId: orgId, secret: secret);
    } catch (e) {
      print('Appwrite Exception: $e');
      rethrow; // rethrow the exception
    }
  }

  Future<void> resendOTP(String userId) async {
    try {
      await account.createPhoneToken(userId: userId, phone: userId);
    } catch (e) {
      print('Appwrite Exception: $e');
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
    print('User logged out and cache cleared.');
  }
}
