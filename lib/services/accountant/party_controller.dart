import 'package:flutter/widgets.dart';
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
  String? pfp; // Will store the Appwrite file ID for the profile picture

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
  var searchQuery = ''.obs; // Observable for search input

  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Defer fetch until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchParties();
    });
    // Debounce search updates
    debounce(searchQuery, (String query) {
      filterParties(query);
    }, time: const Duration(milliseconds: 300));
  }

  String getPreviewUrl(String fileId) {
    return '${CId.endPoint}/v1/storage/buckets/party_pfps/files/$fileId/preview?project=${CId.project}';
  }

  Future<void> fetchParties() async {
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
      filterParties(searchQuery.value); // Apply current search query
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch parties: $e');
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
    try {
      final orgId = authService.orgId.value;
      debugPrint('Adding party: ${party.name}, Organization ID: $orgId');
      if (orgId.isEmpty) {
        throw Exception('Organization ID is not set. Please log in again.');
      }

      await databases.createDocument(
        databaseId: CId.databaseId,
        collectionId: CId.partyCollectionId,
        documentId: 'unique()',
        data: {
          'name': party.name,
          'phoneNumber': party.phoneNumber,
          'gstin': party.gstin,
          'companyName': party.companyName,
          'location': party.location,
          'pfp': party.pfp,
          'organizationId': orgId,
        },
      );
      debugPrint('Party added successfully: ${party.name}');
      fetchParties();
      Get.snackbar('Success', 'Party added successfully');
    } catch (e) {
      debugPrint('Error adding party: $e');
      Get.snackbar('Error', 'Failed to add party: $e');
    }
  }

  Future<void> updateParty(String documentId, Party updatedParty) async {
    try {
      debugPrint('Updating party: $documentId with data: ${updatedParty.name}');
      await databases.updateDocument(
        databaseId: CId.databaseId,
        collectionId: CId.partyCollectionId,
        documentId: documentId,
        data: {
          'name': updatedParty.name,
          'phoneNumber': updatedParty.phoneNumber,
          'gstin': updatedParty.gstin,
          'companyName': updatedParty.companyName,
          'location': updatedParty.location,
          'pfp': updatedParty.pfp,
        },
      );
      debugPrint('Party updated successfully: $documentId');
      fetchParties();
      Get.snackbar('Success', 'Party updated successfully');
    } catch (e) {
      debugPrint('Error updating party: $e');
      Get.snackbar('Error', 'Failed to update party: $e');
    }
  }

  Future<void> deleteParty(String documentId) async {
    try {
      debugPrint('Deleting party: $documentId');
      await databases.deleteDocument(
        databaseId: CId.databaseId,
        collectionId: CId.partyCollectionId,
        documentId: documentId,
      );
      debugPrint('Party deleted successfully: $documentId');
      fetchParties();
      Get.snackbar('Success', 'Party deleted successfully');
    } catch (e) {
      debugPrint('Error deleting party: $e');
      Get.snackbar('Error', 'Failed to delete party: $e');
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

      List<Map<String, String>> partyList =
          response.documents
              .map((doc) => {'name': doc.data['name'].toString()})
              .toList();

      return partyList
          .where(
            (party) =>
                party['name']!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching party suggestions: $e');
      return [];
    }
  }


  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
