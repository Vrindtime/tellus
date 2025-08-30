import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/services/auth/auth_service.dart';

class Party {
  String documentId;
  String name;
  String phoneNumber;
  String? gstin;
  String? companyName;
  String? location;
  String? pfp;

  Party({
    required this.documentId,
    required this.name,
    required this.phoneNumber,
    this.gstin,
    this.companyName,
    this.location,
    this.pfp,
  });
}

class PartyController extends GetxController {
  final Databases databases = Get.find<Databases>();
  final AuthService authService = Get.find<AuthService>();

  var parties = <Party>[].obs;
  var filteredParties = <Party>[].obs;
  var searchQuery = ''.obs;
  var isLoading = false.obs;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final RxString selectedCountryCode = '+91'.obs;
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

  Function? onDataChanged;

  // Note: Initialize this controller at the app's entry point or a parent widget, e.g.:
  // void main() {
  //   Get.put(PartyController());
  //   runApp(MyApp());
  // }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchParties();
    });
    debounce(searchQuery, (String query) {
      filterParties(query);
    }, time: const Duration(milliseconds: 300));
  }

  void resetState() {
    nameController.clear();
    phoneController.clear();
    gstinController.clear();
    companyNameController.clear();
    locationController.clear();
    selectedCountryCode.value = '+91';
    isLoading.value = false;
  }

  String getPreviewUrl(String fileId) {
    return '${CId.endPoint}/v1/storage/buckets/party_pfps/files/$fileId/preview?project=${CId.project}';
  }

  Future<void> fetchParties() async {
    isLoading.value = true;
    try {
      final orgId = authService.orgId.value;
      if (orgId.isEmpty) {
        throw Exception('Organization ID is not set. Please log in again.');
      }

      var response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.partyCollectionId,
        queries: [Query.equal('organizationId', orgId)],
      );

      parties.assignAll(
        response.documents.map(
          (doc) => Party(
            documentId: doc.$id,
            name: doc.data['name'],
            phoneNumber: doc.data['phoneNumber'],
            gstin: doc.data['gstin'],
            companyName: doc.data['companyName'],
            location: doc.data['location'],
            pfp: doc.data['pfp'],
          ),
        ),
      );
      filterParties(searchQuery.value);
      onDataChanged?.call();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch parties: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterParties(String query) {
    if (query.isEmpty) {
      filteredParties.assignAll(parties);
    } else {
      filteredParties.assignAll(
        parties.where(
          (party) =>
              party.name.toLowerCase().contains(query.toLowerCase()) ||
              party.phoneNumber.contains(query),
        ),
      );
    }
  }

  Future<void> addParty(Party party) async {
    isLoading.value = true;
    final String name = nameController.text.trim();
    final String phone = phoneController.text.trim();
    final String location = locationController.text.trim();
    final String? gstin = gstinController.text.trim().isEmpty ? null : gstinController.text.trim();
    final String? companyName = companyNameController.text.trim().isEmpty ? null : companyNameController.text.trim();
    final String countryCode = selectedCountryCode.value;

    if (name.isEmpty || phone.isEmpty || location.isEmpty) {
      Get.snackbar(
        'Error',
        'Name, phone number, and location are required',
        snackPosition: SnackPosition.TOP,
      );
      isLoading.value = false;
      return;
    }

    // Validate phone number: numeric and length
    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      Get.snackbar(
        'Error',
        'Phone number must contain only digits',
        snackPosition: SnackPosition.TOP,
      );
      isLoading.value = false;
      return;
    }

    // Country-specific length validation (example for +91)
    if (countryCode == '+91' && phone.length != 10) {
      Get.snackbar(
        'Error',
        'Indian phone numbers must be 10 digits',
        snackPosition: SnackPosition.TOP,
      );
      isLoading.value = false;
      return;
    }

    // General length validation
    if (phone.length < 7 || phone.length > 15) {
      Get.snackbar(
        'Error',
        'Phone number must be between 7 and 15 digits',
        snackPosition: SnackPosition.TOP,
      );
      isLoading.value = false;
      return;
    }

    final String fullPhoneNumber = '$countryCode$phone';

    try {
      final orgId = authService.orgId.value;
      if (orgId.isEmpty) {
        throw Exception('Organization ID is not set. Please log in again.');
      }

      await databases.createDocument(
        databaseId: CId.databaseId,
        collectionId: CId.partyCollectionId,
        documentId: 'unique()',
        data: {
          'name': name,
          'phoneNumber': fullPhoneNumber,
          'gstin': gstin,
          'companyName': companyName,
          'location': location,
          'pfp': party.pfp,
          'organizationId': orgId,
        },
      );
      Get.back();
      resetState();
      fetchParties();
      onDataChanged?.call();
      Get.snackbar('Success', 'Party added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add party: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateParty(String documentId, Party updatedParty) async {
    isLoading.value = true;
    final String name = nameController.text.trim();
    final String phone = phoneController.text.trim();
    final String location = locationController.text.trim();
    final String? gstin = gstinController.text.trim().isEmpty ? null : gstinController.text.trim();
    final String? companyName = companyNameController.text.trim().isEmpty ? null : companyNameController.text.trim();
    final String countryCode = selectedCountryCode.value;

    if (name.isEmpty || phone.isEmpty || location.isEmpty) {
      Get.snackbar(
        'Error',
        'Name, phone number, and location are required',
        snackPosition: SnackPosition.TOP,
      );
      isLoading.value = false;
      return;
    }

    // Validate phone number: numeric and length
    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      Get.snackbar(
        'Error',
        'Phone number must contain only digits',
        snackPosition: SnackPosition.TOP,
      );
      isLoading.value = false;
      return;
    }

    // Country-specific length validation (example for +91)
    if (countryCode == '+91' && phone.length != 10) {
      Get.snackbar(
        'Error',
        'Indian phone numbers must be 10 digits',
        snackPosition: SnackPosition.TOP,
      );
      isLoading.value = false;
      return;
    }

    // General length validation
    if (phone.length < 7 || phone.length > 15) {
      Get.snackbar(
        'Error',
        'Phone number must be between 7 and 15 digits',
        snackPosition: SnackPosition.TOP,
      );
      isLoading.value = false;
      return;
    }

    final String fullPhoneNumber = '$countryCode$phone';

    try {
      await databases.updateDocument(
        databaseId: CId.databaseId,
        collectionId: CId.partyCollectionId,
        documentId: documentId,
        data: {
          'name': name,
          'phoneNumber': fullPhoneNumber,
          'gstin': gstin,
          'companyName': companyName,
          'location': location,
          'pfp': updatedParty.pfp,
        },
      );
      Get.back();
      resetState();
      fetchParties();
      onDataChanged?.call();
      Get.snackbar('Success', 'Party updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update party: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteParty(String documentId) async {
    isLoading.value = true;
    try {
      await databases.deleteDocument(
        databaseId: CId.databaseId,
        collectionId: CId.partyCollectionId,
        documentId: documentId,
      );
      Get.back();
      fetchParties();
      onDataChanged?.call();
      Get.snackbar('Success', 'Party deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete party: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, String>>> getPartySuggestions(String query) async {
    try {
      final orgId = authService.orgId.value;
      if (orgId.isEmpty) {
        throw Exception('Organization ID is not set. Please log in again.');
      }

      final response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.partyCollectionId,
        queries: [Query.equal('organizationId', orgId)],
      );

      List<Map<String, String>> partyList = response.documents
          .map((doc) => {'name': doc.data['name'].toString(), 'id': doc.$id})
          .toList();

      return partyList
          .where(
            (party) => party['name']!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching party suggestions: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchPartyById(String partyId) async {
    try {
      final doc = await databases.getDocument(
        databaseId: CId.databaseId,
        collectionId: CId.partyCollectionId,
        documentId: partyId,
      );
      return {
        'name': doc.data['name'],
        'phoneNumber': doc.data['phoneNumber'],
        'gstin': doc.data['gstin'],
        'organizationId': doc.data['organizationId'],
        'companyName': doc.data['companyName'],
        'location': doc.data['location'],
        'pfp': doc.data['pfp'],
      };
    } catch (e) {
      debugPrint('Error fetching party by ID: $e');
      return null;
    }
  }

  void setPartyForEdit(Party party) {
    nameController.text = party.name;
    locationController.text = party.location ?? '';
    gstinController.text = party.gstin ?? '';
    companyNameController.text = party.companyName ?? '';
    final String phoneNumber = party.phoneNumber;
    for (String code in countryCodeList) {
      if (phoneNumber.startsWith(code)) {
        selectedCountryCode.value = code;
        phoneController.text = phoneNumber.substring(code.length);
        return;
      }
    }
    Get.snackbar(
      'Warning',
      'Unrecognized country code. Defaulting to +91.',
      snackPosition: SnackPosition.TOP,
    );
    selectedCountryCode.value = '+91';
    phoneController.text = phoneNumber;
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    phoneController.dispose();
    gstinController.dispose();
    companyNameController.dispose();
    locationController.dispose();
    super.onClose();
  }
}

// Extension to simplify country code matching
extension StringListExtension on String {
  bool startsWithAny(List<String> prefixes) {
    return prefixes.any((prefix) => startsWith(prefix));
  }
}