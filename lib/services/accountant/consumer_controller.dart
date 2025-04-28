import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/services/auth/auth_service.dart';

class ConsumerModel {
  final String? id; // Document ID for update/delete

  // Client Details
  final String organizationId; // ID of the organization managing the booking
  final String partyId; // ID of the client (party) associated with the booking
  final String partyName; // Name of the client (party) associated with the booking
  final DateTime workDate; // Date of the work
  final String workLocation; // Location of the customer

  // Shifting Details
  final String? shiftingVehicle; // Name of the shifting vehicle
  final String? shiftingVehicleId; // ID of the shifting vehicle
  final double? shiftingVehicleCharge; // Charge for the shifting vehicle

  // Charges Details
  final List<Map<String, dynamic>> items; // List of items associated with the booking

  // Payment Details
  final double? tax; // Tax amount applied to the booking
  final double? discount; // Discount amount or percentage
  final String? discountType; // Type of discount (e.g., %, Rs)
  final double? netAmount; // Net amount after all calculations
  final double? amountPaid; // Amount paid by the client

  ConsumerModel({
    this.id,
    required this.organizationId,
    required this.partyId,
    required this.partyName,
    required this.workDate,
    required this.workLocation,
    this.shiftingVehicle,
    this.shiftingVehicleId,
    this.shiftingVehicleCharge,
    required this.items,
    this.tax,
    this.discount,
    this.discountType,
    this.netAmount,
    this.amountPaid,
  });

  Map<String, dynamic> toJson() {
    return {
      'organizationId': organizationId,
      'partyId': partyId,
      'partyName': partyName,
      'workDate': workDate.toIso8601String(),
      'workLocation': workLocation,
      'shiftingVehicle': shiftingVehicle,
      'shiftingVehicleId': shiftingVehicleId,
      'shiftingVehicleCharge': shiftingVehicleCharge,
      'items': jsonEncode(items), // Convert list to JSON string for Appwrite
      'tax': tax,
      'discount': discount,
      'discountType': discountType,
      'netAmount': netAmount,
      'amountPaid': amountPaid,
    };
  }

  factory ConsumerModel.fromJson(Map<String, dynamic> json) {
    return ConsumerModel(
      id: json['\$id'],
      organizationId: json['organizationId'],
      partyId: json['partyId'],
      partyName: json['partyName'],
      workDate: DateTime.parse(json['workDate']),
      workLocation: json['workLocation'],
      shiftingVehicle: json['shiftingVehicle'],
      shiftingVehicleId: json['shiftingVehicleId'],
      shiftingVehicleCharge: (json['shiftingVehicleCharge'] is int)
          ? (json['shiftingVehicleCharge'] as int).toDouble()
          : json['shiftingVehicleCharge'] as double?,
      items: List<Map<String, dynamic>>.from(jsonDecode(json['items'])),
      tax: (json['tax'] is int)
          ? (json['tax'] as int).toDouble()
          : json['tax'] as double?,
      discount: (json['discount'] is int)
          ? (json['discount'] as int).toDouble()
          : json['discount'] as double?,
      discountType: json['discountType'],
      netAmount: (json['netAmount'] is int)
          ? (json['netAmount'] as int).toDouble()
          : json['netAmount'] as double?,
      amountPaid: (json['amountPaid'] is int)
          ? (json['amountPaid'] as int).toDouble()
          : json['amountPaid'] as double?,
    );
  }
}

class ConsumerController extends GetxController {
  final Databases databases = Get.find<Databases>();
  final AuthService authService = Get.find<AuthService>();

  var consumerBookings = <ConsumerModel>[].obs;
  Function? onDataChanged; // Callback for data changes

  // Fetch all bookings for the current organization
  Future<void> fetchAllBookings() async {
    try {
      final organizationId = authService.orgId.value; // Assuming this exists
      final response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.consumerBookingCollectionId,
        queries: [
          Query.equal('organizationId', organizationId),
        ],
      );
      consumerBookings.value = response.documents.map((doc) {
        return ConsumerModel.fromJson({
          ...doc.data,
          '\$id': doc.$id, // Ensure $id is included
        });
      }).toList();
      onDataChanged?.call(); // Trigger callback
    } catch (e) {
      print('Error fetching Consumer bookings: $e');
    }
  }

  // Create a new booking
  Future<void> createBooking(ConsumerModel booking) async {
    try {
      final data = booking.toJson();
      await databases.createDocument(
        databaseId: CId.databaseId,
        collectionId: CId.consumerBookingCollectionId,
        documentId: ID.unique(),
        data: data,
      );
      onDataChanged?.call(); // Trigger callback
    } catch (e) {
      print('Error creating booking: $e');
    }
  }

  // Edit an existing booking
  Future<void> editBooking(ConsumerModel booking, String bookingId) async {
    try {
      final data = booking.toJson();
      await databases.updateDocument(
        databaseId: CId.databaseId,
        collectionId: CId.consumerBookingCollectionId,
        documentId: bookingId,
        data: data,
      );
      onDataChanged?.call(); // Trigger callback
    } catch (e) {
      print('Error editing booking: $e');
    }
  }

  // Delete a booking
  Future<void> deleteBooking(String id) async {
    try {
      await databases.deleteDocument(
        databaseId: CId.databaseId,
        collectionId: CId.consumerBookingCollectionId,
        documentId: id,
      );
      onDataChanged?.call(); // Trigger callback
    } catch (e) {
      print('Error deleting booking: $e');
    }
  }
}
