import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/services/auth/auth_service.dart';

class AdminUserController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final RxString selectedRole = 'admin'.obs;
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs; // common loading state

  final List<String> roles = ['admin', 'accountant', 'driver'];

  final Databases databases = Get.find<Databases>();
  final AuthService authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  void resetState() {
    nameController.clear();
    phoneController.clear();
    selectedRole.value = 'admin';
    users.clear();
    isLoading.value = false;
  }

  Future<void> createUser() async {
    final String name = nameController.text.trim();
    final String phone = phoneController.text.trim();
    final String role = selectedRole.value;

    if (name.isEmpty || phone.isEmpty || role.isEmpty) {
      Get.snackbar('Error', 'All fields are required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      // Ensure orgId is set before creating a user
      final orgId = authService.orgId.value;
      if (orgId.isEmpty) {
        throw Exception('Organization ID is not set. Please log in again.');
      }

      final userDocument = await databases.createDocument(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        documentId: 'unique()',
        data: {
          'name': name,
          'phoneNumber': phone,
          'role': role,
          'organizationId': orgId, // Fetch actual organization ID
        },
      );
      Get.back();
      resetState();
      Get.snackbar('Success', 'User ${userDocument.data['name']} created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create user: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> fetchUsers() async {
    print('Fetching users...');
    isLoading.value = true; // Set loading to true
    try {
      final orgId = authService.orgId.value;
      if (orgId.isEmpty) {
        throw Exception('Organization ID is not set. Please log in again.');
      }

      final response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        queries: [
          Query.equal('organizationId', orgId),
        ],
      );
      print('Response: ${response.documents}');
      users.clear();
      users.addAll(response.documents.map((doc) => {
        'id': doc.$id,
        'name': doc.data['name'],
        'role': doc.data['role'],
        'phoneNumber': doc.data['phoneNumber'],
      }).toList());
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false; // Set loading to false
    }
  }

  Future<void> updateUser(String userId) async {
    if (userId.isEmpty) {
      Get.snackbar('Error', 'User ID is required to update user',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final String name = nameController.text.trim();
    final String phone = phoneController.text.trim();
    final String role = selectedRole.value;

    if (name.isEmpty || phone.isEmpty || role.isEmpty) {
      Get.snackbar('Error', 'All fields are required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      await databases.updateDocument(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        documentId: userId,
        data: {
          'name': name,
          'phoneNumber': phone,
          'role': role,
        },
      );

      Get.back();
      fetchUsers(); // Refresh the user list
      Get.snackbar('Success', 'User updated successfully',
          snackPosition: SnackPosition.BOTTOM);
      debugPrint('User updated successfully');

      // Reset state after successful update
      resetState();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user: $e',
          snackPosition: SnackPosition.BOTTOM,);
    }
  }

  Future<void> deleteUser(String userId) async {
    if (userId.isEmpty) {
      Get.snackbar('Error', 'User ID is required to delete user',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      await databases.deleteDocument(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        documentId: userId,
      );

      Get.back();
      Get.snackbar('Success', 'User deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
      debugPrint('User deleted successfully');
      fetchUsers(); // Refresh the user list
      resetState(); // Reset state after use
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

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
        'role': response.data['role'],
      };
    } catch (e) {
      debugPrint('Error fetching user by ID: $e');
      return null;
    }
  }

  Future<void> saveUser(String userId, Map<String, dynamic> updatedData) async {
    try {
      await databases.updateDocument(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        documentId: userId,
        data: updatedData,
      );
      Get.back();
      Get.snackbar('Success', 'User details updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save user details: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    resetState(); // Ensure state is reset on close
    super.onClose();
  }
}
