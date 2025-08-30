import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tellus/helper/helper.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/services/auth/auth_service.dart';
import 'package:intl/intl.dart';

class Vehicle {
  String documentId;
  String registrationNumber;
  String vehicleType;
  DateTime ageOfVehicle;
  int meter;
  int modelYear;
  String companyName;

  Vehicle({
    required this.documentId,
    required this.registrationNumber,
    required this.vehicleType,
    required this.ageOfVehicle,
    required this.meter,
    required this.modelYear,
    required this.companyName,
  });
}

class VehicleController extends GetxController {
  final Account account = Get.find<Account>();
  final Databases databases = Get.find<Databases>();
  final AuthService authService = Get.find<AuthService>();

  var vehicles = <Vehicle>[].obs;
  var filteredVehicles = <Vehicle>[].obs;

  TextEditingController controller = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchVehicles();
  }

  Future<void> onRefresh() async {
    await fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    debugPrint('Fetching vehicles...');
    try {
      final orgId = authService.orgId.value;
      if (orgId.isEmpty) {
        throw Exception('Organization ID is not set. Please log in again.');
      }

      var response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.vehiclesCollectionId,
        queries: [Query.equal('organizationId', orgId)],
      );
      debugPrint('Vehicle Response Doc: ${response.documents.first}');
      vehicles.assignAll(
        response.documents.map(
          (doc) {
            try {
              debugPrint('Parsing ageOfVehicle: ${doc.data['ageOfVehicle']}');
              final dateFormat = DateFormat('dd-MM-yyyy');
              return Vehicle(
                documentId: doc.$id,
                registrationNumber: doc.data['registrationNumber'],
                vehicleType: doc.data['vehicleType'],
                // ageOfVehicle: DateTime.now(),
                ageOfVehicle: customParseDate(doc.data['ageOfVehicle']),
                meter: doc.data['meter'] ?? 0, // Default to 0 if null
                modelYear: doc.data['modelYear'] ?? 0,
                companyName: doc.data['companyName'] ?? '',
              );
            } catch (e) {
              debugPrint('Error parsing ageOfVehicle for document ${doc.$id}: $e');
              throw Exception('Invalid ageOfVehicle format');
            }
          },
        ),
      );
      filterVehicles('');
      filteredVehicles.assignAll(vehicles);
      print('Vehicles: $vehicles');
    } catch (e) {
      print('Error fetching vehicles: $e');
    }
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      final orgId = authService.orgId.value;
      if (orgId.isEmpty) {
        throw Exception('Organization ID is not set. Please log in again.');
      }

      await databases.createDocument(
        databaseId: CId.databaseId,
        collectionId: CId.vehiclesCollectionId,
        documentId: 'unique()',
        data: {
          'registrationNumber': vehicle.registrationNumber,
          'vehicleType': vehicle.vehicleType,
          'ageOfVehicle': vehicle.ageOfVehicle.toIso8601String(), // Convert to ISO 8601 format
          'meter': vehicle.meter,
          'modelYear': vehicle.modelYear,
          'companyName': vehicle.companyName,
          'organizationId': orgId,
        },
      );
      fetchVehicles();
      Get.snackbar('Success', 'Vehicle added successfully', snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add vehicle: ${e.toString()}', snackPosition: SnackPosition.TOP);
      debugPrint('Error adding vehicle: $e');
    }
  }

  Future<void> updateVehicle(String documentId, Vehicle updatedVehicle) async {
    debugPrint('Updating Vehicle: $documentId');
    debugPrint('Updated Vehicle Data: ${updatedVehicle.toString()}');
    try {
      await databases.updateDocument(
        databaseId: CId.databaseId,
        collectionId: CId.vehiclesCollectionId,
        documentId: documentId,
        data: {
          'registrationNumber': updatedVehicle.registrationNumber,
          'vehicleType': updatedVehicle.vehicleType,
          'ageOfVehicle': updatedVehicle.ageOfVehicle.toIso8601String(),
          'meter': updatedVehicle.meter,
          'modelYear': updatedVehicle.modelYear,
          'companyName': updatedVehicle.companyName,
        },
      );
      debugPrint('Vehicle updated successfully');
      Get.back();
      Get.snackbar('Success', 'Vehicle updated successfully');
      fetchVehicles();
    } catch (e) {
      debugPrint('Error updating vehicle: $e');
      Get.snackbar('Error', 'Failed to update vehicle: ${e.toString()}');
    }
  }

  Future<void> deleteVehicle(String documentId) async {
    try {
      await databases.deleteDocument(
        databaseId: CId.databaseId,
        collectionId: CId.vehiclesCollectionId,
        documentId: documentId,
      );
      Get.back();
      fetchVehicles();
      Get.snackbar('Success', 'Vehicle deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete vehicle: ${e.toString()}');
    }
  }

  void filterVehicles(String query) {
    if (query.isEmpty) {
      filteredVehicles.assignAll(vehicles);
    } else {
      filteredVehicles.assignAll(
        vehicles.where(
          (vehicle) => vehicle.registrationNumber.toLowerCase().contains(
            query.toLowerCase(),
          ),
        ),
      );
    }
  }

  Future<List<Map<String, String>>> getVehicleSuggestions(String query) async {
    try {
      final orgId = authService.orgId.value;
      if (orgId.isEmpty) {
        throw Exception('Organization ID is not set. Please log in again.');
      }

      final response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.vehiclesCollectionId,
        queries: [Query.equal('organizationId', orgId)],
      );

      List<Map<String, String>> vehicleList = response.documents
          .map((doc) => {'name': doc.data['registrationNumber'].toString(),'id': doc.$id})
          .toList();

      return vehicleList
          .where((vehicle) => vehicle['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching vehicle suggestions: $e');
      return [];
    }
  }

  Future<List<Map<String, String>>> getAccessorySuggestions(String query) async {
    try {
      // Mocked data for accessories (Bucket/Breaker)
      List<Map<String, String>> accessories = [
        {'name': 'Bucket'},
        {'name': 'Breaker'},
      ];

      return accessories
          .where((accessory) =>
              accessory['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching accessory suggestions: $e');
      return [];
    }
  }
  
}
