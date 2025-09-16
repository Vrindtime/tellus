import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/services/auth/auth_service.dart';

class OrganizationController extends GetxController {
  final Account account = Get.find<Account>();
  final Databases databases = Get.find<Databases>();
  final AuthService authService = Get.find<AuthService>();

  String databaseId = CId.databaseId;
  String orgsCollectionId = CId.orgsCollectionId;

  RxString selectedOrg = ''.obs;
  RxBool isLoading = false.obs;

  TextEditingController orgTextController = TextEditingController();
  TextEditingController phoneLookupController = TextEditingController();

  /// Adds a new organization document to the organizations collection.
  /// [orgName] is the name of the organization and [phoneNumbers] is the list of associated phone numbers.
  /// Once the organization is created, it uses the returned organization ID (orgDocument.$id) to create a new user document in your user collection.
  Future<Document?> addOrganization(
    String orgName,
    String phoneNumbers,
    String userName,
  ) async {
    try {
      // Create the organization document
      final Document orgDocument = await databases.createDocument(
        databaseId: databaseId,
        collectionId: orgsCollectionId,
        documentId: 'unique()', // auto-generate document ID
        data: {
          'orgName': orgName,
          'phoneNumbers': phoneNumbers, // storing as string; adjust if needed
        },
      );
      debugPrint('Organization created successfully: ${orgDocument.$id}');

      // Create a new user document with admin role linked to the organization
      final Document userDocument = await databases.createDocument(
        databaseId: databaseId,
        collectionId: CId.userCollectionId,
        documentId: 'unique()', // auto-generate document ID
        data: {
          'name': userName,
          'phoneNumber': phoneNumbers, // using the same phone number for admin
          'organizationId': orgDocument.$id,
          'role': 'admin',
        },
      );
      debugPrint(
        'Admin user created successfully for New Org: ${userDocument.$id}',
      );
      return orgDocument;
    } catch (e) {
      debugPrint('Error creating organization and admin user: $e');
      return null;
    }
  }

  /// each containing organization data (orgId, orgName, and phoneNumbers).
  Future<List<Map<String, dynamic>>> getOrgs() async {
    List<Map<String, dynamic>> orgList = [];
    debugPrint('------ GET ORGANIZATION LIST ------');
    isLoading.value = true;
    try {
      debugPrint('Fetching organization documents...');
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: orgsCollectionId,
      );
      debugPrint(
        'Fetched ${response.documents.length} organization documents.',
      );
      for (Document doc in response.documents) {
        // Build a map for each organization document.
        Map<String, dynamic> orgData = {
          'orgId': doc.$id,
          'orgName': doc.data['orgName'],
          'phoneNumbers': doc.data['phoneNumbers'],
        };
        orgList.add(orgData);
      }
    } catch (e) {
      debugPrint('Error fetching organizations: $e');
    } finally {
      isLoading.value = false;
    }
    return orgList;
  }

  Future<List<Map<String, String>>> getOrgSuggestions(String query) async {
    try {
      // Fetch organizations from the Appwrite database
      final documents = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: orgsCollectionId,
      );

      // Extract organization names
      List<Map<String, String>> orgList =
          documents.documents
              .map((doc) => {'name': doc.data['orgName'].toString()})
              .toList();

      // Filter based on query
      return orgList
          .where(
            (org) => org['name']!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      print('Error fetching organizations: $e');
      return [];
    }
  }

  /// Finds organizations linked to a given phone number by querying the users collection.
  /// Returns a list of maps with `orgId` and `orgName`.
  Future<List<Map<String, String>>> findOrganizationsByPhone(
    String phone,
  ) async {
    try {
      final normalized = authService.normalizePhoneNumber(phone);
      // First, find users with this phone number
      final users = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: CId.userCollectionId,
        queries: [
          Query.equal('phoneNumber', [normalized]),
        ],
      );

      List<String> orgIds =
          users.documents
              .map((doc) => doc.data['organizationId'].toString())
              .toSet()
              .toList();

      // If none found, try legacy without '+91'
      if (orgIds.isEmpty) {
        final legacy =
            normalized.startsWith('+91') ? normalized.substring(3) : normalized;
        final usersLegacy = await databases.listDocuments(
          databaseId: databaseId,
          collectionId: CId.userCollectionId,
          queries: [
            Query.equal('phoneNumber', [legacy]),
          ],
        );
        orgIds =
            usersLegacy.documents
                .map((doc) => doc.data['organizationId'].toString())
                .toSet()
                .toList();
      }

      if (orgIds.isEmpty) return [];

      // Fetch organization names for the distinct orgIds
      List<Map<String, String>> results = [];
      for (final id in orgIds) {
        try {
          final org = await databases.getDocument(
            databaseId: databaseId,
            collectionId: orgsCollectionId,
            documentId: id,
          );
          results.add({'orgId': id, 'orgName': org.data['orgName'].toString()});
        } catch (_) {
          // skip bad ids
        }
      }
      return results;
    } catch (e) {
      debugPrint('Error finding organizations by phone: $e');
      return [];
    }
  }

  Future<void> selectOrgAndNavigate(
    TextEditingController orgTextController,
  ) async {
    isLoading.value = true;
    debugPrint('----- phone value: ${orgTextController.value} -----');
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: orgsCollectionId,
        queries: [Query.equal('orgName', orgTextController.text)],
      );

      if (response.documents.isNotEmpty) {
        // Organization found, navigate to login
        final orgId = response.documents.first.$id;
        if (orgId.isEmpty) {
          throw Exception('Organization ID is missing. Please try again.');
        }
        selectedOrg.value = orgId;
        Get.toNamed('/login');
      } else {
        // No matching organization found
        Get.snackbar('Error', 'Organization not found');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> fetchOrgById(String orgId) async {
    try {
      final doc = await databases.getDocument(
        databaseId: databaseId,
        collectionId: orgsCollectionId,
        documentId: orgId,
      );
      return {
        'orgLogo': doc.data['orgLogo'],
        'orgName': doc.data['orgName'],
        'orgAddress': doc.data['orgAddress'],
        'phoneNumber': doc.data['phoneNumbers'],
        'orgUPI': doc.data['orgUPI'],
        'accountHolderName': doc.data['accountHolderName'],
        'accountNumber': doc.data['accountNumber'],
        'accountIFSC': doc.data['accountIFSC'],
      };
    } catch (e) {
      debugPrint('Error fetching organization by ID: $e');
      return null;
    }
  }

  Future<bool> editOrganization(String orgId, Map<String, dynamic> data) async {
    try {
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: orgsCollectionId,
        documentId: orgId,
        data: data,
      );
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update organization: $e');
      debugPrint('Error updating organization: $e');
      return false;
    }
  }

  Future<bool> deleteOrganization(String orgId) async {
    try {
      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: orgsCollectionId,
        documentId: orgId,
      );
      return true;
    } catch (e) {
      debugPrint('Error deleting organization: $e');
      return false;
    }
  }
}
