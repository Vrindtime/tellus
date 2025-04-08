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

  Party({
    required this.documentId,
    required this.name,
    required this.phoneNumber,
    this.gstin,
  });
}

class PartyController extends GetxController {
  final Databases databases = Get.find<Databases>();
  final AuthService authService = Get.find<AuthService>();

  var parties = <Party>[].obs;
  var filteredParties = <Party>[].obs;

  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchParties();
    searchController.addListener(() {
      filterParties(searchController.text);
    });
  }  

  Future<void> fetchParties() async {
    try {
      final orgId = authService.orgId.value;
      debugPrint('Fetching parties for organization ID: $orgId');
      if (orgId.isEmpty) {
        debugPrint('Organization ID is not set. Please log in again.');
        throw Exception('Organization ID is not set. Please log in again.');
      }

      var response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.partyCollectionId,
        queries: [Query.equal('organizationId', orgId)],
      );

      debugPrint('Fetched parties: ${response.documents}');

      parties.assignAll(
        response.documents.map(
          (doc) => Party(
            documentId: doc.$id,
            name: doc.data['name'],
            phoneNumber: doc.data['phoneNumber'],
            gstin: doc.data['gstin'],
          ),
        ),
      );
      filterParties('');
    } catch (e) {
      debugPrint('Error fetching parties: $e');
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

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
