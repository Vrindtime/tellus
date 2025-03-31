import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/services/auth/auth_service.dart';

class Vehicle {
  String documentId;
  String registrationNumber;
  String vehicleType;
  DateTime ageOfVehicle;
  int odo;
  double rentAmount;
  String rentType;

  Vehicle({
    required this.documentId,
    required this.registrationNumber,
    required this.vehicleType,
    required this.ageOfVehicle,
    required this.odo,
    required this.rentAmount,
    required this.rentType,
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
            debugPrint('Vehicle Data: ${doc.data}');
            double rentAmount = (doc.data['rentAmount'] as num).toDouble();
            return Vehicle(
            documentId: doc.$id,
            registrationNumber: doc.data['registrationNumber'],
            vehicleType: doc.data['vehicleType'],
            ageOfVehicle: DateTime.parse('${doc.data['ageOfVehicle']}'),
            odo: doc.data['odo'],
            rentAmount: rentAmount,
            rentType: doc.data['rentType'],
            );
          }
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
          'ageOfVehicle': vehicle.ageOfVehicle.toIso8601String(), // Convert DateTime to String
          'odo': vehicle.odo,
          'rentAmount': vehicle.rentAmount,
          'rentType': vehicle.rentType,
          'organizationId': orgId,
        },
      );
      fetchVehicles();
      Get.snackbar('Success', 'Vehicle added successfully', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add vehicle: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
      debugPrint('Error adding vehicle: $e');
    }
  }

  Future<void> updateVehicle(String documentId, Vehicle updatedVehicle) async {
    print('Update Vehicle Called: $documentId');
    print('Updated Vehicle: ${updatedVehicle.toString()}');
    try {
      await databases.updateDocument(
        databaseId: CId.databaseId,
        collectionId: CId.vehiclesCollectionId,
        documentId: documentId,
        data: {
          'registrationNumber': updatedVehicle.registrationNumber,
          'vehicleType': updatedVehicle.vehicleType,
          'ageOfVehicle': updatedVehicle.ageOfVehicle.toIso8601String(), // Convert DateTime to String
          'odo': updatedVehicle.odo,
          'rentAmount': updatedVehicle.rentAmount,
          'rentType': updatedVehicle.rentType,
        },
      );
      Get.back();
      Get.snackbar('Success', 'Vehicle updated successfully');
      fetchVehicles();
    } catch (e) {
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
}
