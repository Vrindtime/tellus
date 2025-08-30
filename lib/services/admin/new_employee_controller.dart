import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tellus/helper/helper.dart';
import 'package:tellus/core/id.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tellus/models/employee_model.dart';
import 'package:tellus/services/auth/auth_service.dart';

class UserEmployeeWithName {
  final EmployeeModel employee;
  final String userName;
  final String userRole;
  UserEmployeeWithName({
    required this.employee,
    required this.userName,
    required this.userRole,
  });
}

class UserEmployeeController extends GetxController {
  final RxList<UserEmployeeWithName> userEmployeeList =
      <UserEmployeeWithName>[].obs;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();
  final fixedSalaryController = TextEditingController();
  final hourlyRateController = TextEditingController();
  final noteController = TextEditingController();
  final perWorkRateController = TextEditingController();

  final RxString selectedCountryCode = '+91'.obs;
  final RxString selectedRole = 'driver'.obs;
  final RxString salaryType = 'Fixed'.obs;
  final RxString profilePicPath = ''.obs; // image url after upload
  final RxList<String> docsPaths = <String>[].obs; // uploaded document urls/ids

  final List<String> roles = ['admin', 'accountant', 'driver'];
  final List<String> countryCodeList = [
    '+1',
    '+44',
    '+49',
    '+91',
    '+971',
    '+968',
    '+33',
    '+81',
    '+86',
    '+61',
  ];

  final RxBool isLoading = false.obs;

  final Databases databases = Get.find<Databases>();
  final AuthService authService = Get.find<AuthService>();

  void resetForm() {
    nameController.clear();
    phoneController.clear();
    addressController.clear();
    dobController.clear();
    fixedSalaryController.clear();
    hourlyRateController.clear();
    perWorkRateController.clear();
    noteController.clear();
    selectedCountryCode.value = '+91';
    selectedRole.value = 'driver';
    salaryType.value = 'Fixed';
    profilePicPath.value = '';
    docsPaths.clear();
  }

  Future<void> pickDob(BuildContext context) async {
    final res = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (res != null) {
      // Only show date part, not time
      dobController.text = DateFormat('dd-MM-yyyy').format(res);
    }
  }

  Future<void> pickProfilePic() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final url = await saveImageAndGetUrl(
        file: picked,
        bucketId: CId.userPfpBucketId,
      );
      if (url != null) profilePicPath.value = url;
    }
  }

  Future<void> pickDocuments() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      for (var picked in pickedFiles) {
        final url = await saveImageAndGetUrl(
          file: picked,
          bucketId: CId.userPfpBucketId,
        );
        if (url != null) docsPaths.add(url);
      }
    }
  }

  Future<void> handleCreate() async {
    isLoading.value = true;
    try {
      final orgId = authService.orgId.value;
      if (orgId.isEmpty) throw Exception("Organization ID not set");
      final fullPhone =
          "${selectedCountryCode.value}${phoneController.text.trim()}";

      // 1. Create user
      final resUser = await databases.createDocument(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        documentId: 'unique()',
        data: {
          'name': nameController.text.trim(),
          'phoneNumber': fullPhone,
          'address': addressController.text.trim(),
          'dob': dobController.text,
          'role': selectedRole.value,
          'pfp': profilePicPath.value,
          'organizationId': orgId,
          'documents': docsPaths,
        },
      );

      // 2. Create linked employee
      await databases.createDocument(
        databaseId: CId.databaseId,
        collectionId: CId.employeeCollectionId,
        documentId: 'unique()',
        data: {
          'userId': resUser.$id,
          'organizationId': orgId,
          'paymentType': salaryType.value,
          'fixedSalary':
              fixedSalaryController.text.isNotEmpty
                  ? double.tryParse(fixedSalaryController.text)
                  : null,
          'hourlyRate':
              hourlyRateController.text.isNotEmpty
                  ? double.tryParse(hourlyRateController.text)
                  : null,
          'perWorkRate':
              perWorkRateController.text.isNotEmpty
                  ? double.tryParse(perWorkRateController.text)
                  : null,
          'status': 'Active',
          'joinedDate': DateTime.now().toIso8601String(),
          'note': noteController.text,
        },
      );
      Get.back();
      Get.snackbar('Success', 'User & Employee created');
      resetForm();
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleUpdate(String userId) async {
    isLoading.value = true;
    try {
      final fullPhone =
          "${selectedCountryCode.value}${phoneController.text.trim()}";
      // 1. Update user
      await databases.updateDocument(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        documentId: userId,
        data: {
          'name': nameController.text.trim(),
          'phoneNumber': fullPhone,
          'address': addressController.text.trim(),
          'dob': dobController.text,
          'role': selectedRole.value,
          'pfp': profilePicPath.value,
          'documents': docsPaths,
        },
      );
      // 2. Update employee by userId+orgId
      final orgId = authService.orgId.value;
      final empDocs = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.employeeCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('organizationId', orgId),
        ],
      );
      if (empDocs.documents.isNotEmpty) {
        final emp = empDocs.documents.first;
        await databases.updateDocument(
          databaseId: CId.databaseId,
          collectionId: CId.employeeCollectionId,
          documentId: emp.$id,
          data: {
            'paymentType': salaryType.value,
            'fixedSalary':
                fixedSalaryController.text.isNotEmpty
                    ? double.tryParse(fixedSalaryController.text)
                    : null,
            'hourlyRate':
                hourlyRateController.text.isNotEmpty
                    ? double.tryParse(hourlyRateController.text)
                    : null,
            'perWorkRate':
                perWorkRateController.text.isNotEmpty
                    ? double.tryParse(perWorkRateController.text)
                    : null,
            'status': 'Active',
            'note': noteController.text,
          },
        );
      }
      Get.back();
      Get.snackbar('Success', 'User & Employee updated');
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserAndEmployee(String userId) async {
    isLoading.value = true;
    try {
      // load user doc
      final userRes = await databases.getDocument(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        documentId: userId,
      );
      nameController.text = userRes.data['name'] ?? '';
      addressController.text = userRes.data['address'] ?? '';
      dobController.text = userRes.data['dob'] ?? '';
      selectedRole.value = userRes.data['role'] ?? 'driver';
      profilePicPath.value = userRes.data['pfp'] ?? '';
      docsPaths.value = (userRes.data['documents'] ?? []).cast<String>();

      // parse phone/country code
      final phoneNumber = userRes.data['phoneNumber'] ?? '';
      final codeMatch =
          countryCodeList.firstWhereOrNull((c) => phoneNumber.startsWith(c)) ??
          '+91';
      selectedCountryCode.value = codeMatch;
      phoneController.text = phoneNumber.replaceFirst(codeMatch, '');

      // load employee doc
      final orgId = authService.orgId.value;
      final empDocs = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.employeeCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('organizationId', orgId),
        ],
      );
      if (empDocs.documents.isNotEmpty) {
        var emp = empDocs.documents.first.data;
        salaryType.value = emp['paymentType'] ?? 'Fixed';
        fixedSalaryController.text = (emp['fixedSalary'] ?? '').toString();
        hourlyRateController.text = (emp['hourlyRate'] ?? '').toString();
        noteController.text = emp['note'] ?? '';
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserEmployeeList() async {
    isLoading.value = true;
    try {
      final orgId = authService.orgId.value;
      if (orgId.isEmpty) throw Exception("Organization ID not set");

      // Fetch employees for this org
      final employeeResponse = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.employeeCollectionId,
        queries: [Query.equal('organizationId', orgId)],
      );

      // Fetch users for this org
      final userResponse = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        queries: [Query.equal('organizationId', orgId)],
      );

      final employees = employeeResponse.documents;
      final users = userResponse.documents;

      // Create a map for quick user lookup by ID
      final userMap = {for (var u in users) u.$id: u.data};

      // Clear existing list
      userEmployeeList.clear();

      // Build combined list
      for (var empDoc in employees) {
        final empData = empDoc.data;
        final userId = empData['userId'];
        final userData = userMap[userId];

        if (userData != null) {
          final employeeModel = EmployeeModel.fromJson(empData);
          final userName = userData['name'] ?? 'Unknown';
          final userRole = userData['role'] ?? 'Unknown';
          userEmployeeList.add(
            UserEmployeeWithName(
              employee: employeeModel,
              userName: userName,
              userRole: userRole,
            ),
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load employees: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String userId) async {
    isLoading.value = true;
    try {
      // Delete user document
      await databases.deleteDocument(
        databaseId: CId.databaseId,
        collectionId: CId.userCollectionId,
        documentId: userId,
      );

      // Delete linked employee document(s) for this user in this org
      final orgId = authService.orgId.value;
      final empDocs = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.employeeCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('organizationId', orgId),
        ],
      );
      for (var emp in empDocs.documents) {
        await databases.deleteDocument(
          databaseId: CId.databaseId,
          collectionId: CId.employeeCollectionId,
          documentId: emp.$id,
        );
      }
      Get.back();
      Get.snackbar('Success', 'User & Employee deleted');
      resetForm();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    dobController.dispose();
    fixedSalaryController.dispose();
    hourlyRateController.dispose();
    perWorkRateController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
