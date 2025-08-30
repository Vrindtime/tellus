import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/services/auth/auth_service.dart';

class AdminUserController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final RxString selectedRole = 'admin'.obs;
  final RxString selectedCountryCode = '+91'.obs;
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  final List<String> roles = ['admin', 'accountant', 'driver'];
  final List<String> countryCodeList = [
    '+1', // United States
    '+44', // United Kingdom
    '+49', // Germany
    '+91', // India
    '+971', // United Arab Emirates
    '+968', // Oman
    '+33', // France
    '+81', // Japan
    '+86', // China
    '+61', // Australia
  ];

  final Databases databases = Get.find<Databases>();
  final AuthService authService = Get.find<AuthService>();

  // Note: Thistypically used to ensure a single instance is created.
  // Initialize this controller at the app's entry point or a parent widget, e.g.:
  // void main() {
  //   Get.put(AdminUserController());
  //   runApp(MyApp());
  // }

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  void resetState() {
    nameController.clear();
    phoneController.clear();
    locationController.clear();
    selectedRole.value = 'admin';
    selectedCountryCode.value = '+91';
    isLoading.value = false;
  }

  // Future<void> createUser() async {
  //   isLoading.value = true;
  //   final String name = nameController.text.trim();
  //   final String phone = phoneController.text.trim();
  //   final String location = locationController.text.trim();
  //   final String role = selectedRole.value;
  //   final String countryCode = selectedCountryCode.value;

  //   if (name.isEmpty || phone.isEmpty || location.isEmpty || role.isEmpty) {
  //     Get.snackbar(
  //       'Error',
  //       'All fields are required',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     isLoading.value = false;
  //     return;
  //   }

  //   // Validate phone number: numeric and length
  //   if (!RegExp(r'^\d+$').hasMatch(phone)) {
  //     Get.snackbar(
  //       'Error',
  //       'Phone number must contain only digits',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     isLoading.value = false;
  //     return;
  //   }

  //   // Country-specific length validation (example for +91)
  //   if (countryCode == '+91' && phone.length != 10) {
  //     Get.snackbar(
  //       'Error',
  //       'Indian phone numbers must be 10 digits',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     isLoading.value = false;
  //     return;
  //   }

  //   // General length validation
  //   if (phone.length < 7 || phone.length > 15) {
  //     Get.snackbar(
  //       'Error',
  //       'Phone number must be between 7 and 15 digits',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     isLoading.value = false;
  //     return;
  //   }

  //   final String fullPhoneNumber = '$countryCode$phone';

  //   try {
  //     final orgId = authService.orgId.value;
  //     if (orgId.isEmpty) {
  //       throw Exception('Organization ID is not set. Please log in again.');
  //     }

  //     final userDocument = await databases.createDocument(
  //       databaseId: CId.databaseId,
  //       collectionId: CId.userCollectionId,
  //       documentId: 'unique()',
  //       data: {
  //         'name': name,
  //         'phoneNumber': fullPhoneNumber,
  //         'location': location,
  //         'role': role,
  //         'organizationId': orgId,
  //       },
  //     );

      // EmployeeController employeeController = Get.find<EmployeeController>();
      // await employeeController.createEmployeeForUser(
      //   userId: userDocument.$id, // Use the Appwrite document ID
      //   organizationId: orgId,
      //   role: role,
      // );
      // if (employeeController.error.isNotEmpty) {
      //   debugPrint('Employee creation error: ${employeeController.error.value}');
      // }

  //     Get.back();
  //     resetState();
  //     await fetchUsers(); // Ensure the user list is refreshed after creating a user
  //     Get.snackbar(
  //       'Success',
  //       'User ${userDocument.data['name']} created successfully',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Failed to create user: $e',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> fetchUsers() async {
    print('Fetching users...');
    try {
      final orgId = authService.orgId.value;
      if (orgId.isEmpty) {
        throw Exception('Organization ID is not set. Please log in again.');
      }

      final response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        queries: [Query.equal('organizationId', orgId)],
      );
      print('Response: ${response.documents.map( (doc) => doc.data)}');
      users.clear();
      users.addAll(
        response.documents
            .map(
              (doc) => {
                'id': doc.$id,
                'name': doc.data['name'],
                'role': doc.data['role'],
                'phoneNumber': doc.data['phoneNumber'],
                'location': doc.data['location'],
                'pfp': doc.data['pfp'],
              },
            )
            .toList(),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch users: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> updateUser(String userId) async {
  //   isLoading.value = true;
  //   if (userId.isEmpty) {
  //     Get.snackbar(
  //       'Error',
  //       'User ID is required to update user',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     isLoading.value = false;
  //     return;
  //   }

  //   final String name = nameController.text.trim();
  //   final String phone = phoneController.text.trim();
  //   final String location = locationController.text.trim();
  //   final String role = selectedRole.value;
  //   final String countryCode = selectedCountryCode.value;

  //   if (name.isEmpty || phone.isEmpty || location.isEmpty || role.isEmpty) {
  //     Get.snackbar(
  //       'Error',
  //       'All fields are required',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     isLoading.value = false;
  //     return;
  //   }

  //   // Validate phone number: numeric and length
  //   if (!RegExp(r'^\d+$').hasMatch(phone)) {
  //     Get.snackbar(
  //       'Error',
  //       'Phone number must contain only digits',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     isLoading.value = false;
  //     return;
  //   }

  //   // Country-specific length validation (example for +91)
  //   if (countryCode == '+91' && phone.length != 10) {
  //     Get.snackbar(
  //       'Error',
  //       'Indian phone numbers must be 10 digits',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     isLoading.value = false;
  //     return;
  //   }

  //   // General length validation
  //   if (phone.length < 7 || phone.length > 15) {
  //     Get.snackbar(
  //       'Error',
  //       'Phone number must be between 7 and 15 digits',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     isLoading.value = false;
  //     return;
  //   }

  //   final String fullPhoneNumber = '$countryCode$phone';

  //   try {
  //     await databases.updateDocument(
  //       databaseId: CId.databaseId,
  //       collectionId: CId.userCollectionId,
  //       documentId: userId,
  //       data: {
  //         'name': name,
  //         'phoneNumber': fullPhoneNumber,
  //         'location': location,
  //         'role': role,
  //       },
  //     );

  //     Get.back();
  //     fetchUsers();
  //     Get.snackbar(
  //       'Success',
  //       'User updated successfully',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     debugPrint('User updated successfully');
  //     resetState();
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Failed to update user: $e',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<void> deleteUser(String userId) async {
  //   isLoading.value = true;
  //   if (userId.isEmpty) {
  //     Get.snackbar(
  //       'Error',
  //       'User ID is required to delete user',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     isLoading.value = false;
  //     return;
  //   }

  //   try {
  //     await databases.deleteDocument(
  //       databaseId: CId.databaseId,
  //       collectionId: CId.userCollectionId,
  //       documentId: userId,
  //     );

  //     Get.back();
  //     Get.snackbar(
  //       'Success',
  //       'User deleted successfully',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     debugPrint('User deleted successfully');
  //     fetchUsers();
  //     resetState();
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Failed to delete user: $e',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<Map<String, dynamic>?> fetchUserById(String userId) async {
    try {
      final response = await databases.getDocument(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        documentId: userId,
      );
      return {
        'id': response.$id,
        'name': response.data['name'],
        'dob': response.data['dob'],
        'phoneNumber': response.data['phoneNumber'],
        'location': response.data['location'],
        'role': response.data['role'],
        'pfp': response.data['pfp'],
      };
    } catch (e) {
      debugPrint('Error fetching user by ID: $e');
      return null;
    }
  }

  Future<void> saveUser(String userId, Map<String, dynamic> updatedData) async {
    isLoading.value = true;
    try {
      await databases.updateDocument(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        documentId: userId,
        data: updatedData,
      );
      Get.back();
      Get.snackbar(
        'Success',
        'User details updated successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save user details: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

//   void setUserForEdit(Map<String, dynamic> user) {
//     nameController.text = user['name'] ?? '';
//     locationController.text = user['location'] ?? '';
//     selectedRole.value = user['role'] ?? 'admin';
//     final String phoneNumber = user['phoneNumber'] ?? '';
//     // Extract country code and phone number
//     for (String code in countryCodeList) {
//       if (phoneNumber.startsWith(code)) {
//         selectedCountryCode.value = code;
//         phoneController.text = phoneNumber.substring(code.length);
//         return;
//       }
//     }
//     // Fallback for unrecognized country code
//     Get.snackbar(
//       'Warning',
//       'Unrecognized country code. Defaulting to +91.',
//       snackPosition: SnackPosition.TOP,
//     );
//     selectedCountryCode.value = '+91';
//     phoneController.text = phoneNumber;
//   }

//   @override
//   void onClose() {
//     nameController.dispose();
//     phoneController.dispose();
//     locationController.dispose();
//     isLoading.value = false;
//     resetState();
//     super.onClose();
//   }
// }

// // Extension to simplify country code matching
// extension StringListExtension on String {
//   bool startsWithAny(List<String> prefixes) {
//     return prefixes.any((prefix) => startsWith(prefix));
//   }
// }
}